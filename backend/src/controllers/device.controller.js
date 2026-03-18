import crypto from "crypto";
import Device from "../models/device.model.js";
import SignedPreKey from "../models/signedPreKey.model.js";
import OneTimePreKey from "../models/oneTimePreKey.model.js";
import Session from "../models/session.model.js";

/**
 * Register or replace the user's device.
 * Single-device mode: old device + its keys are deleted.
 * Future multi-device: remove the deletion logic.
 */
export const registerDevice = async (req, res) => {
    try {
        const userId = req.user._id;
        const { identityPublicKey, registrationId, label, platform } = req.body;

        if (!identityPublicKey || !registrationId) {
            return res.status(400).json({
                message: "identityPublicKey and registrationId are required",
            });
        }

        // Validate identity key format
        let keyBuffer;
        try {
            keyBuffer = Buffer.from(identityPublicKey, "base64");
        } catch (err) {
            return res.status(400).json({ message: "Invalid base64 format" });
        }

        if (keyBuffer.length !== 33) {
            return res.status(400).json({
                message: "Invalid identity key length (expected 33 bytes for libsignal)",
            });
        }

        const fingerprint = crypto
            .createHash("sha256")
            .update(keyBuffer)
            .digest("hex");

        // Single-device mode: delete existing device + keys
        const existingDevice = await Device.findOne({ userId });
        if (existingDevice) {
            const oldDeviceId = existingDevice.deviceId;
            await Promise.all([
                SignedPreKey.deleteMany({ userId, deviceId: oldDeviceId }),
                OneTimePreKey.deleteMany({ userId, deviceId: oldDeviceId }),
                Session.deleteMany({
                    $or: [
                        { userId, deviceId: oldDeviceId },
                        { peerUserId: userId, peerDeviceId: oldDeviceId },
                    ],
                }),
                Device.deleteOne({ _id: existingDevice._id }),
            ]);
        }

        const deviceId = 1; // Single-device mode: always 1

        const device = await Device.create({
            userId,
            deviceId,
            registrationId,
            identityPublicKey,
            identityKeyFingerprint: fingerprint,
            label: label || "",
            platform: platform || "web",
            lastSeenAt: new Date(),
        });

        res.status(201).json({
            message: "Device registered successfully",
            deviceId: device.deviceId,
            registrationId: device.registrationId,
        });
    } catch (error) {
        console.error("Error in registerDevice:", error);
        res.status(500).json({ message: "Internal server error" });
    }
};

/**
 * Remove the user's device and cascade-delete its keys/sessions.
 */
export const removeDevice = async (req, res) => {
    try {
        const userId = req.user._id;

        const device = await Device.findOne({ userId });
        if (!device) {
            return res.status(404).json({ message: "No device found" });
        }

        const deviceId = device.deviceId;

        await Promise.all([
            SignedPreKey.deleteMany({ userId, deviceId }),
            OneTimePreKey.deleteMany({ userId, deviceId }),
            Session.deleteMany({
                $or: [
                    { userId, deviceId },
                    { peerUserId: userId, peerDeviceId: deviceId },
                ],
            }),
            Device.deleteOne({ _id: device._id }),
        ]);

        res.status(200).json({ message: "Device removed successfully" });
    } catch (error) {
        console.error("Error in removeDevice:", error);
        res.status(500).json({ message: "Internal server error" });
    }
};

/**
 * Get info about the authenticated user's device.
 */
export const getMyDevice = async (req, res) => {
    try {
        const userId = req.user._id;

        const device = await Device.findOne({ userId }).select(
            "-__v"
        );

        if (!device) {
            return res.status(404).json({ message: "No device registered" });
        }

        res.status(200).json(device);
    } catch (error) {
        console.error("Error in getMyDevice:", error);
        res.status(500).json({ message: "Internal server error" });
    }
};

/**
 * Save or update FCM push notification token.
 */
export const saveFcmToken = async (req, res) => {
    try {
        const userId = req.user._id;
        const { token } = req.body;

        if (!token) {
            return res.status(400).json({ message: "FCM token is required" });
        }

        const device = await Device.findOne({ userId });
        if (!device) {
            return res.status(404).json({ message: "No device registered. Register device first." });
        }

        device.fcmToken = token;
        await device.save();

        res.status(200).json({ message: "FCM token saved successfully" });
    } catch (error) {
        console.error("Error in saveFcmToken:", error);
        res.status(500).json({ message: "Internal server error" });
    }
};
