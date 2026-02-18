import User from "../models/user.model.js";
import cloudinary from "../lib/cloudinary.js";
import { verifyTempToken, generateToken } from "../lib/utils.js"


export const getUserInfo = async (req, res) => {
    try {
        res.status(200).json(req.user);
    } catch (error) {
        console.log("error in get user info:", error);
        res.status(500).json({ message: "Internal server error" });
    }
}

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

export async function getFriends(req, res) {
    try {
        const userId = req.user._id;

        const user = await User.findById(userId).populate("friends", "fullName profilePic email");

        res.status(200).json(user.friends);
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: "Server error" });
    }
}

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