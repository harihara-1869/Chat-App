import User from "../models/user.model.js";
import bcrypt from "bcryptjs";
import { generateToken, generateTempToken, verifyTempToken } from "../lib/utils.js";
import cloudinary from "../lib/cloudinary.js";
import { sendResetPasswordEmail, sendVerificationEmail } from "../lib/mailgun.js";
import crypto from "crypto";
import { env } from "process";

export const signup = async (req, res) => {
  const { fullName, email, password, privacyPolicy, termsAndConditions } = req.body;
  try {
    if (!fullName || !email || !password || !privacyPolicy || !termsAndConditions) {
      return res.status(400).json({ message: "All fields are required." });
    }

    if (!privacyPolicy || !termsAndConditions) {
      return res.status(400).json({ message: "You must accept the privacy policy and terms and conditions." });
    }

    if (/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      // Email is valid
    } else {
      return res.status(400).json({ message: "Invalid email format." });
    }

    if (password.length < 6 || password.length > 20) {
      return res
        .status(400)
        .json({ message: "Password must be at least 6 characters long and at most 20 characters long." });
    }

    const user = await User.findOne({ email });
    if (user) {
      return res
        .status(400)
        .json({ message: "User with this email already exists." });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Generate verification token
    const verificationToken = crypto.randomBytes(32).toString("hex");
    const verificationTokenExpiresAt = Date.now() + 24 * 60 * 60 * 1000; // 24 hours
    const accountExpiresAt = Date.now() + 7 * 24 * 60 * 60 * 1000; // 7 day cleanup

    const newUser = new User({
      fullName,
      email,
      password: hashedPassword,
      verificationToken,
      verificationTokenExpiresAt,
      privacyPolicyAccepted: true,
      termsAndConditionsAccepted: true,
      acceptedPoliciesAt: new Date(),
      accountExpiresAt,
    });

    if (newUser) {
      await newUser.save();

      // Send verification email but no login
      if (env.CHECK_MAIL === "true") {
        await sendVerificationEmail(newUser.email, newUser.verificationToken);
      }

      return res.status(201).json({
        message: "Account created! Please check your email to verify your account.",
        _id: newUser._id,
        fullName: newUser.fullName,
        email: newUser.email,
      });
    } else {
      return res.status(500).json({ message: "Failed to create user." });
    }
  } catch (error) {
    console.error("Error during signup:", error);
    return res.status(500).json({ message: "Server error during signup." });
  }
};

export const login = async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: "Invalid email or password." });
    }

    // Check if user registered via Google (no password set)
    if (user.provider === "google" && !user.password) {
      return res.status(400).json({
        message: "This account uses Google login. Please sign in with Google."
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Invalid email or password." });
    }

    // Check if email is verified (skip for Google OAuth users)
    if (env.CHECK_MAIL === "true") {
      if (!user.emailVerified && user.provider !== "google") {
        return res.status(403).json({
          message: "Please verify your email address before logging in. Check your inbox for the verification link."
        });
      }
    }

    generateToken(user._id, res);
    return res.status(200).json({
      _id: user._id,
      fullName: user.fullName,
      email: user.email,
      profilePic: user.profilePic || null,
    });
  } catch (error) {
    console.error("Error during login:", error);
    return res.status(500).json({ message: "Server error during login." });
  }
};

export const verifyEmail = async (req, res) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({ message: "Verification token is required" });
    }

    const user = await User.findOne({
      verificationToken: token,
      verificationTokenExpiresAt: { $gt: Date.now() },
    });

    if (!user) {
      return res.status(400).json({ message: "Invalid or expired verification token" });
    }

    user.emailVerified = true;
    user.verificationToken = undefined;
    user.verificationTokenExpiresAt = undefined;
    user.accountExpiresAt = null;
    await user.save();

    // Login user immediately after verification
    generateToken(user._id, res);

    return res.status(200).json({
      message: "Email verified successfully",
      _id: user._id,
      fullName: user.fullName,
      email: user.email,
      profilePic: user.profilePic || null,
    });
  } catch (error) {
    console.error("Error verifying email:", error);
    return res.status(500).json({ message: "Server error during email verification" });
  }
};


export const logout = (req, res) => {
  try {
    res.clearCookie("jwt", {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
    });
    return res.status(200).json({ message: "Logged out successfully." });
  } catch (error) {
    console.error("Error during logout:", error);
    return res.status(500).json({ message: "Server error during logout." });
  }
};

// Google OAuth callback handler
export const googleCallback = (req, res) => {
  try {
    const frontendUrl = process.env.FRONTEND_URL || 'http://localhost:5173';

    // User is already processed by Passport at this point (req.user is set)
    if (!req.user) {
      return res.redirect(`${frontendUrl}/login?error=auth_failed`);
    }

    const { user, pendingUser, isNewUser, needsPrivacyAcceptance } = req.user;

    if (isNewUser) {
      // Generate temp token for new user to complete signup
      const tempToken = generateTempToken(pendingUser);
      return res.redirect(`${frontendUrl}/complete-google-signup?token=${tempToken}`);
    }

    if (needsPrivacyAcceptance) {
      // Existing user needs to accept policies
      return res.redirect(`${frontendUrl}/accept-policies?email=${encodeURIComponent(user.email)}`);
    }

    // Existing user with privacy policy accepted - generate JWT and login
    generateToken(user._id, res);
    return res.redirect(frontendUrl);

  } catch (error) {
    console.error("Error during Google OAuth callback:", error);
    const frontendUrl = process.env.FRONTEND_URL || 'http://localhost:5173';
    res.redirect(`${frontendUrl}/login?error=server_error`);
  }
};

export const resetPassword = async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    if (user.resetPasswordToken && user.resetPasswordExpiresAt > Date.now()) {
      return res.status(400).json({ message: "Password reset already in progress" });
    }
    const resetToken = crypto.randomBytes(32).toString("hex");
    user.resetPasswordToken = resetToken;
    user.resetPasswordExpiresAt = Date.now() + 15 * 60 * 1000; //15 minutes for reset tokens
    await user.save();
    await sendResetPasswordEmail(user.email, resetToken);
    return res.status(200).json({ message: "Reset password email sent" });

  } catch (error) {
    console.log("error in reset password:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
}

export const updatePassword = async (req, res) => {
  try {
    const { token, newPassword } = req.body;
    const user = await User.findOne({ resetPasswordToken: token, resetPasswordExpiresAt: { $gt: Date.now() } });
    if (!user) {
      return res.status(400).json({ message: "Invalid or expired token" })
    }
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);
    user.password = hashedPassword;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpiresAt = undefined;
    await user.save();
    return res.status(200).json({ message: "Password updated successfully" })
  } catch (error) {
    console.log("error in update password:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
}

export const completeGoogleSignup = async (req, res) => {
  try {
    const { tempToken, privacyPolicy, termsAndConditions, fullName } = req.body;

    if (!tempToken || !privacyPolicy || !termsAndConditions) {
      return res.status(400).json({
        message: "Temp token and policy acceptance are required."
      });
    }

    if (!privacyPolicy || !termsAndConditions) {
      return res.status(400).json({
        message: "You must accept the privacy policy and terms and conditions to continue."
      });
    }

    // Verify temp token
    const tokenData = verifyTempToken(tempToken);
    if (!tokenData) {
      return res.status(400).json({
        message: "Invalid or expired signup token. Please try signing up with Google again."
      });
    }

    // Check if user already exists (double-check)
    const existingUser = await User.findOne({
      $or: [
        { googleId: tokenData.googleId },
        { email: tokenData.email }
      ]
    });

    if (existingUser) {
      // User already exists - check if they need to accept policies
      if (!existingUser.privacyPolicyAccepted || !existingUser.termsAndConditionsAccepted) {
        existingUser.privacyPolicyAccepted = true;
        existingUser.termsAndConditionsAccepted = true;
        existingUser.acceptedPoliciesAt = new Date();
        await existingUser.save();
      }

      generateToken(existingUser._id, res);
      return res.status(200).json({
        message: "Account linked successfully",
        _id: existingUser._id,
        fullName: existingUser.fullName,
        email: existingUser.email,
        profilePic: existingUser.profilePic || null,
      });
    }

    // Create new user
    const newUser = new User({
      provider: "google",
      googleId: tokenData.googleId,
      email: tokenData.email,
      emailVerified: tokenData.emailVerified,
      fullName: fullName || tokenData.fullName,
      profilePic: tokenData.profilePic || "",
      privacyPolicyAccepted: true,
      termsAndConditionsAccepted: true,
      acceptedPoliciesAt: new Date(),
    });

    await newUser.save();

    // Generate JWT and login
    generateToken(newUser._id, res);
    return res.status(201).json({
      message: "Account created successfully",
      _id: newUser._id,
      fullName: newUser.fullName,
      email: newUser.email,
      profilePic: newUser.profilePic || null,
    });

  } catch (error) {
    console.error("Error completing Google signup:", error);
    return res.status(500).json({ message: "Server error during account creation." });
  }
};

export const acceptPolicies = async (req, res) => {
  try {
    const { email, privacyPolicy, termsAndConditions } = req.body;

    if (!email || !privacyPolicy || !termsAndConditions) {
      return res.status(400).json({
        message: "Email and policy acceptance are required."
      });
    }

    if (!privacyPolicy || !termsAndConditions) {
      return res.status(400).json({
        message: "You must accept the privacy policy and terms and conditions to continue."
      });
    }

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: "User not found." });
    }

    // Update user to accept all policies
    user.privacyPolicyAccepted = true;
    user.termsAndConditionsAccepted = true;
    user.acceptedPoliciesAt = new Date();
    await user.save();

    // Generate JWT and login
    generateToken(user._id, res);
    return res.status(200).json({
      message: "Policies accepted successfully",
      _id: user._id,
      fullName: user.fullName,
      email: user.email,
      profilePic: user.profilePic || null,
    });

  } catch (error) {
    console.error("Error accepting policies:", error);
    return res.status(500).json({ message: "Server error." });
  }
};

// Verify Google OAuth temp token and return user data
export const verifyGoogleToken = async (req, res) => {
  try {
    const { token } = req.query;

    if (!token) {
      return res.status(400).json({ message: "Token is required." });
    }

    // Verify temp token
    const tokenData = verifyTempToken(token);
    if (!tokenData) {
      return res.status(400).json({
        message: "Invalid or expired signup token. Please try signing up with Google again."
      });
    }

    // Return the user data from token
    return res.status(200).json({
      googleId: tokenData.googleId,
      email: tokenData.email,
      fullName: tokenData.fullName,
      profilePic: tokenData.profilePic,
      emailVerified: tokenData.emailVerified,
    });

  } catch (error) {
    console.error("Error verifying Google token:", error);
    return res.status(500).json({ message: "Server error." });
  }
};