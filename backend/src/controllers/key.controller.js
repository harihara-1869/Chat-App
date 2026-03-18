import User from "../models/user.model.js";
import Device from "../models/device.model.js";
import SignedPreKey from "../models/signedPreKey.model.js";
import OneTimePreKey from "../models/oneTimePreKey.model.js";

const SIGNED_PREKEY_MAX_AGE_DAYS = 7;
const SIGNED_PREKEY_GRACE_PERIOD_DAYS = 2;

/**
 * Upload a signed pre-key for the user's device.
 * Archives the existing key if replacing.
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

        const device = await Device.findOne({ userId, deviceId });
        if (!device) {
            return res.status(404).json({ message: "Device not found. Register a device first." });
        }

        // Archive existing active key if it exists (for rotation)
        await SignedPreKey.updateMany(
            { userId, deviceId, status: "active" },
            { 
                status: "archived",
                archivedAt: new Date()
            }
        );

        // Create new signed pre-key
        await SignedPreKey.findOneAndUpdate(
            { userId, deviceId },
            { 
                keyId, 
                publicKey, 
                signature,
                status: "active",
                archivedAt: null
            },
            { upsert: true, new: true }
        );

        res.status(200).json({ message: "Signed pre-key uploaded successfully" });
    } catch (error) {
        console.error("Error in uploadSignedPreKey:", error);
        res.status(500).json({ message: "Internal server error" });
    }
};

/**
 * Rotate signed pre-key - archives old key and uploads new one
 */
export const rotateSignedPreKey = async (req, res) => {
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

        const device = await Device.findOne({ userId, deviceId });
        if (!device) {
            return res.status(404).json({ message: "Device not found" });
        }

        // Archive existing active key
        await SignedPreKey.updateMany(
            { userId, deviceId, status: "active" },
            { 
                status: "archived",
                archivedAt: new Date()
            }
        );

        // Create new key
        await SignedPreKey.create({
            userId,
            deviceId,
            keyId,
            publicKey,
            signature,
            status: "active"
        });

        res.status(200).json({ message: "Signed pre-key rotated successfully" });
    } catch (error) {
        console.error("Error in rotateSignedPreKey:", error);
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

        const device = await Device.findOne({ userId, deviceId });
        if (!device) {
            return res.status(404).json({ message: "Device not found for user" });
        }

        // Only get active signed pre-key
        const signedPreKey = await SignedPreKey.findOne({ userId, deviceId, status: "active" });
        if (!signedPreKey) {
            return res.status(404).json({ message: "Signed pre-key not found or inactive" });
        }

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

/**
 * Scheduled job: Flag old signed pre-keys for rotation
 * Runs daily - marks keys older than 7 days as "rotating"
 * After 2 more days (grace period), they can be auto-deleted
 */
export const flagOldSignedPreKeysForRotation = async () => {
    try {
        const thresholdDate = new Date();
        thresholdDate.setDate(thresholdDate.getDate() - SIGNED_PREKEY_MAX_AGE_DAYS);

        // Flag old active keys for rotation
        const result = await SignedPreKey.updateMany(
            { 
                status: "active",
                createdAt: { $lt: thresholdDate }
            },
            { 
                status: "rotating"
            }
        );

        if (result.modifiedCount > 0) {
            console.log(`[SignedPreKey Rotation] Flagged ${result.modifiedCount} keys older than ${SIGNED_PREKEY_MAX_AGE_DAYS} days for rotation`);
        }

        // Delete keys that have been rotating for more than grace period
        const deleteThresholdDate = new Date();
        deleteThresholdDate.setDate(deleteThresholdDate.getDate() - (SIGNED_PREKEY_MAX_AGE_DAYS + SIGNED_PREKEY_GRACE_PERIOD_DAYS));

        const deleteResult = await SignedPreKey.deleteMany({
            status: "rotating",
            createdAt: { $lt: deleteThresholdDate }
        });

        if (deleteResult.deletedCount > 0) {
            console.log(`[SignedPreKey Rotation] Deleted ${deleteResult.deletedCount} keys after grace period`);
        }

    } catch (error) {
        console.error("Error in flagOldSignedPreKeysForRotation:", error);
    }
};
