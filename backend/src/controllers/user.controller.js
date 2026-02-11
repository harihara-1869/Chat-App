import User from "../models/user.model.js";
import cloudinary from "../lib/cloudinary.js";


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