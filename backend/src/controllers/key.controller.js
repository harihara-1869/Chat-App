import User from "../models/user.model.js";
import Device from "../models/device.model.js";
import SignedPreKey from "../models/signedPreKey.model.js";
import OneTimePreKey from "../models/oneTimePreKey.model.js";


/**
 * Upload a signed pre-key for the user's device.
 */
export const uploadSignedPreKey = async (req, res) => {
    try {
        const userId = req.user._id;
        const { keyId, publicKey, signature, deviceId = 1 } = req.body;

        if (!keyId || !publicKey || !signature) {
            return res.status(400).json({ message: "keyId, publicKey, and signature are required" });
        }

        const pubKeyBuffer = Buffer.from(publicKey, "base64");
        if (pubKeyBuffer.length !== 33) {
            return res.status(400).json({ message: "Invalid signed prekey length (expected 33 bytes)" });
        }

        const sigBuffer = Buffer.from(signature, "base64");
        if (sigBuffer.length !== 64) {
            return res.status(400).json({ message: "Invalid signature length" });
        }

        // Verify the device exists
        const device = await Device.findOne({ userId, deviceId });
        if (!device) {
            return res.status(404).json({ message: "Device not found. Register a device first." });
        }

        await SignedPreKey.findOneAndUpdate(
            { userId, deviceId },
            { keyId, publicKey, signature },
            { upsert: true, new: true }
        );

        res.status(200).json({ message: "Signed pre-key uploaded successfully" });
    } catch (error) {
        console.error("Error in uploadSignedPreKey:", error);
        res.status(500).json({ message: "Internal server error" });
    }
};

/**
 * Upload a batch of one-time pre-keys for the user's device.
 */
export const uploadOneTimePreKey = async (req, res) => {
    try {
        const userId = req.user._id;
        const { setOfOneTimePreKeys, deviceId = 1 } = req.body;

        if (!setOfOneTimePreKeys || !Array.isArray(setOfOneTimePreKeys)) {
            return res.status(400).json({ message: "setOfOneTimePreKeys array is required" });
        }

        if (setOfOneTimePreKeys.length === 0 || setOfOneTimePreKeys.length > 100) {
            return res.status(400).json({ message: "Must provide 1-100 one-time pre-keys" });
        }

        // Verify the device exists
        const device = await Device.findOne({ userId, deviceId });
        if (!device) {
            return res.status(404).json({ message: "Device not found. Register a device first." });
        }

        await OneTimePreKey.insertMany(
            setOfOneTimePreKeys.map(key => ({
                userId,
                deviceId,
                keyId: key.keyId,
                publicKey: key.publicKey,
            }))
        );

        res.status(200).json({ message: "One-time pre-keys uploaded successfully" });
    } catch (error) {
        console.error("Error in uploadOneTimePreKey:", error);
        res.status(500).json({ message: "Internal server error" });
    }
};

/**
 * Get a pre-key bundle for a specific user (and optionally device).
 * Consumes one one-time pre-key (marks it as used).
 */
export const getPreKeyBundle = async (req, res) => {
    try {
        const { userId } = req.params;
        const deviceId = parseInt(req.query.deviceId) || 1;

        // Get the device (which holds identity key)
        const device = await Device.findOne({ userId, deviceId });
        if (!device) {
            return res.status(404).json({ message: "Device not found for user" });
        }

        const signedPreKey = await SignedPreKey.findOne({ userId, deviceId });
        if (!signedPreKey) {
            return res.status(404).json({ message: "Signed pre-key not found" });
        }

        // Atomically consume one unused one-time pre-key
        const oneTimePreKey = await OneTimePreKey.findOneAndUpdate(
            { userId, deviceId, used: false },
            { $set: { used: true } },
            { new: true }
        );

        res.status(200).json({
            identityKey: device.identityPublicKey,
            registrationId: device.registrationId,
            deviceId: device.deviceId,
            signedPreKey: {
                keyId: signedPreKey.keyId,
                publicKey: signedPreKey.publicKey,
                signature: signedPreKey.signature,
            },
            oneTimePreKey: oneTimePreKey
                ? {
                    keyId: oneTimePreKey.keyId,
                    publicKey: oneTimePreKey.publicKey,
                }
                : null,
        });
    } catch (error) {
        console.error("Error in getPreKeyBundle:", error);
        res.status(500).json({ message: "Internal server error" });
    }
};

/**
 * Get the count of remaining unused one-time pre-keys for the user's device.
 */
export const getPreKeyCount = async (req, res) => {
    try {
        const userId = req.user._id;
        const deviceId = parseInt(req.query.deviceId) || 1;

        const device = await Device.findOne({ userId, deviceId });
        if (!device) {
            return res.status(404).json({ message: "Device not found" });
        }

        const count = await OneTimePreKey.countDocuments({
            userId,
            deviceId,
            used: false,
        });

        res.status(200).json({ count, deviceId });
    } catch (error) {
        console.error("Error in getPreKeyCount:", error);
        res.status(500).json({ message: "Internal server error" });
    }
};
