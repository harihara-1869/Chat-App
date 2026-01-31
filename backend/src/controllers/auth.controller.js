import User from "../models/user.model.js";
import bcrypt from "bcryptjs";
import { generateToken } from "../lib/utils.js";
import cloudinary from "../lib/cloudinary.js";
import { sendVerificationEmail } from "../lib/mailgun.js";
import crypto from "crypto";

export const signup = async (req, res) => {
  const { fullName, email, password } = req.body;
  try {
    if (!fullName || !email || !password) {
      return res.status(400).json({ message: "All fields are required." });
    }

    if (/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      // Email is valid
    } else {
      return res.status(400).json({ message: "Invalid email format." });
    }

    if (password.length < 6) {
      return res
        .status(400)
        .json({ message: "Password must be at least 6 characters long." });
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
    const verificationTokenExpiresAt = Date.now() + 3 * 60 * 60 * 1000; // 3 hours

    const newUser = new User({
      fullName,
      email,
      password: hashedPassword,
      verificationToken,
      verificationTokenExpiresAt,
      emailVerified: false,
    });

    if (newUser) {
      await newUser.save();

      // Send verification email
      await sendVerificationEmail(newUser.email, verificationToken);

      return res.status(201).json({
        message: "Account created! Please verify your email to log in.",
        _id: newUser._id,
        fullName: newUser.fullName,
        email: newUser.email,
        profilePic: newUser.profilePic || null,
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

    // Check if email is verified
    if (!user.emailVerified) {
      return res.status(403).json({ message: "Please verify your email address before logging in." });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Invalid email or password." });
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

export const updateProfile = async (req, res) => {
  try {
    const { profilePic } = req.body;
    const userId = req.user._id;

    if (!profilePic) {
      return res.status(400).json({ message: "Profile pic is required" });
    }

    const uploadResponse = await cloudinary.uploader.upload(profilePic);
    const updateUser = await User.findByIdAndUpdate(
      userId,
      { profilePic: uploadResponse.secure_url },
      { new: true },
    );
    res.status(200).json(updateUser);
  } catch (error) {
    console.log("error in update profile:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const getUserInfo = async (req, res) => {
  try {
    res.status(200).json(req.user);
  } catch (error) {
    console.log("error in get user info:", error);
    res.status(500).json({ message: "Internal server error" });
  }
}

// Google OAuth callback handler
export const googleCallback = (req, res) => {
  try {
    const frontendUrl = process.env.FRONTEND_URL || 'http://localhost:5173';

    // User is already authenticated by Passport at this point (req.user is set)
    if (!req.user) {
      return res.redirect(`${frontendUrl}/login?error=auth_failed`);
    }

    // Generate JWT token
    generateToken(req.user._id, res);

    // Redirect to frontend
    res.redirect(frontendUrl);
  } catch (error) {
    console.error("Error during Google OAuth callback:", error);
    const frontendUrl = process.env.FRONTEND_URL || 'http://localhost:5173';
    res.redirect(`${frontendUrl}/login?error=server_error`);
  }
};