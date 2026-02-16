import User from "../models/user.model.js";
import bcrypt from "bcryptjs";
import { generateToken, generateTempToken, verifyTempToken } from "../lib/utils.js";
import cloudinary from "../lib/cloudinary.js";
import { sendResetPasswordEmail, sendVerificationEmail } from "../lib/mailgun.js";
import crypto from "crypto";
import { env } from "process";

export const signup = async (req, res) => {
  const { fullName, email, password, privacyPolicy, termsAndConditions } = req.body;
  const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{10,}$/;

  try {
    if (!fullName || !email || !password || !privacyPolicy || !termsAndConditions) {
      return res.status(400).json({ message: "All fields are required." });
    }

    if (!privacyPolicy || !termsAndConditions) {
      return res.status(400).json({ message: "You must accept the privacy policy and terms and conditions." });
    }

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return res.status(400).json({ message: "Invalid email format." });
    }

    if (email.length > 254) {
      return res.status(400).json({ message: "Email is too long." });
    }

    if (fullName.length > 100) {
      return res.status(400).json({ message: "Full name is too long." });
    }

    if (!passwordRegex.test(password)) {
      return res
        .status(400)
        .json({ message: "Password must be at least 10 characters long and contain at least one lowercase letter, one uppercase letter, one number, and one special character." });
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
  const frontendUrl = process.env.FRONTEND_URL || 'http://localhost:5173';
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });

    // Fake hash to prevent timing attacks (user enumeration)
    // Always perform bcrypt comparison even if user not found
    const fakeHash = "$2a$10$abcdefghijklmnopqrstuvwx.yzABCDEFGHIJKLMNOPQRSTUVWXYZ12";
    const passwordToCompare = user ? user.password : fakeHash;

    // Perform comparison regardless of user existence
    const isMatch = await bcrypt.compare(password, passwordToCompare);

    if (!user) {
      return res.status(400).json({ message: "Invalid email or password." });
    }

    // Check if user registered via Google (no password set)
    if (user.provider === "google" && !user.password) {
      return res.status(400).json({
        message: "This account uses Google login. Please sign in with Google."
      });
    }

    if (!user.termsAndConditionsAccepted || !user.privacyPolicyAccepted) {
      const tempToken = generateTempToken(user);
      return res.status(403).json({
        message: "Please accept the privacy policy and terms to continue.",
        redirectTo: `/accept-policies?email=${encodeURIComponent(user.email)}&token=${encodeURIComponent(tempToken)}`
      });

    }

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

    const { user, pendingUser, isNewUser, needsPrivacyAcceptance, error, email } = req.user;

    // Handle error case (email already exists)
    if (error === "email_exists") {
      return res.redirect(`${frontendUrl}/login?error=email_exists&email=${encodeURIComponent(email)}`);
    }

    if (isNewUser) {
      // Generate temp token for new user to complete signup
      const tempToken = generateTempToken(pendingUser);
      return res.redirect(`${frontendUrl}/complete-google-signup?token=${tempToken}`);
    }

    if (needsPrivacyAcceptance) {
      // Existing user needs to accept policies
      const tempToken = generateTempToken(user);
      return res.redirect(`${frontendUrl}/accept-policies?email=${encodeURIComponent(user.email)}&token=${encodeURIComponent(tempToken)}`);
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
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{10,}$/;

    // Validate password complexity
    if (!passwordRegex.test(newPassword)) {
      return res.status(400).json({
        message: "Password must be at least 10 characters long and contain at least one lowercase letter, one uppercase letter, one number, and one special character."
      });
    }

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

    return res.status(200).json({ message: "Password updated successfully. Please log in with your new password." })
  } catch (error) {
    console.log("error in update password:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
}

export const completeGoogleSignup = async (req, res) => {
  try {
    const { tempToken, privacyPolicy, termsAndConditions, fullName } = req.body;

    if (!tempToken) {
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

    // Check if email already exists (prevent account linking)
    const emailExists = await User.findOne({ email: tokenData.email });
    if (emailExists) {
      return res.status(400).json({
        message: "An account with this email already exists. Please sign in with your existing account."
      });
    }

    // Check if googleId already exists (prevent duplicate Google accounts)
    const googleIdExists = await User.findOne({ googleId: tokenData.googleId });
    if (googleIdExists) {
      // Existing Google user - just log them in
      generateToken(googleIdExists._id, res);
      return res.status(200).json({
        message: "Login successful",
        _id: googleIdExists._id,
        fullName: googleIdExists.fullName,
        email: googleIdExists.email,
        profilePic: googleIdExists.profilePic || null,
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
    const { privacyPolicy, termsAndConditions, token } = req.body;

    if (!privacyPolicy || !termsAndConditions || !token) {
      return res.status(400).json({
        message: "Token and policy acceptance are required."
      });
    }

    const tokenData = verifyTempToken(token);
    if (!tokenData) {
      return res.status(400).json({
        message: "Invalid or expired token. Please try again."
      });
    }

    if (!privacyPolicy || !termsAndConditions) {
      return res.status(400).json({
        message: "You must accept the privacy policy and terms and conditions to continue."
      });
    }

    const user = await User.findOne({ email: tokenData.email });

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