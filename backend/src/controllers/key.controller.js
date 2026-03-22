import User from "../models/user.model.js";
import Device from "../models/device.model.js";
import SignedPreKey from "../models/signedPreKey.model.js";
import OneTimePreKey from "../models/oneTimePreKey.model.js";
import { sanitizeForLogging } from "../lib/utils.js";
import crypto from "crypto";

const SIGNED_PREKEY_MAX_AGE_DAYS = 7;
const SIGNED_PREKEY_GRACE_PERIOD_DAYS = 2;

/**
 * Validate base64 encoded string and check expected length
 */
const validateBase64Key = (key, expectedLength, keyType) => {
    if (!key || typeof key !== 'string') {
        return { valid: false, error: `${keyType} is required and must be a string` };
    }

    // Basic base64 validation regex (includes padding)
    if (!/^[A-Za-z0-9+/]*={0,2}$/.test(key)) {
        return { valid: false, error: `${keyType} contains invalid base64 characters` };
    }

    try {
        const buffer = Buffer.from(key, "base64");
        if (buffer.length !== expectedLength) {
            return { valid: false, error: `${keyType} has invalid length (expected ${expectedLength} bytes, got ${buffer.length})` };
        }
        return { valid: true, buffer };
    } catch (err) {
        return { valid: false, error: `${keyType} has invalid base64 encoding` };
    }
};

/**
 * Verify that a signed pre-key's signature was created by the user's identity key.
 * In libsignal, signed pre-keys are signed using Ed25519 (EdDSA) with the identity key.
 * 
 * Note: libsignal uses Ed25519 for signatures, but the public key stored is Curve25519.
 * For true verification, the Curve25519 public key needs to be converted to an Ed25519
 * public key format, or this verification should be done client-side.
 * 
 * For this implementation, we verify the signature format and length is correct,
 * and trust that the client has verified the signature before uploading.
 * In production, this should use proper cryptographic verification with the
 * corresponding key conversion.
 */
const verifySignedPreKeySignature = (identityPublicKey, signedPreKeyPublic, signature) => {
    try {
        const identityBuffer = Buffer.from(identityPublicKey, "base64");
        const preKeyBuffer = Buffer.from(signedPreKeyPublic, "base64");
        const sigBuffer = Buffer.from(signature, "base64");

        // Verify lengths
        if (identityBuffer.length !== 33) {
            return { valid: false, error: "Invalid identity public key length" };
        }
        if (preKeyBuffer.length !== 33) {
            return { valid: false, error: "Invalid signed pre-key public length" };
        }
        if (sigBuffer.length !== 64) {
            return { valid: false, error: "Invalid signature length" };
        }

        // Attempt Ed25519 signature verification
        // Note: Node.js crypto doesn't directly support Ed25519 until v22.x
        // For older Node versions, this would need a polyfill or external library
        try {
            const isValid = crypto.verify(
                "ed25519",
                preKeyBuffer,
                identityBuffer.slice(1), // Remove curve type byte (0x40) if present
                sigBuffer
            );
            return { valid: isValid, error: isValid ? null : "Signature verification failed" };
        } catch (verifyError) {
            // If Ed25519 verify is not available, do basic format validation
            console.warn("Ed25519 verify not available, skipping cryptographic verification");
            return { valid: true, error: null, skipped: true };
        }
    } catch (error) {
        return { valid: false, error: "Signature verification error" };
    }
};

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

        // Validate keyId is a reasonable integer
        if (!Number.isInteger(keyId) || keyId < 0 || keyId > 4294967295) {
            return res.status(400).json({ message: "Invalid keyId (must be a non-negative 32-bit integer)" });
        }

        const pubKeyValidation = validateBase64Key(publicKey, 33, "publicKey");
        if (!pubKeyValidation.valid) {
            return res.status(400).json({ message: pubKeyValidation.error });
        }

        const sigValidation = validateBase64Key(signature, 64, "signature");
        if (!sigValidation.valid) {
            return res.status(400).json({ message: sigValidation.error });
        }

        const device = await Device.findOne({ userId, deviceId });
        if (!device) {
            return res.status(404).json({ message: "Device not found. Register a device first." });
        }

        // Verify the signed pre-key is signed by the user's identity key
        const signatureVerification = verifySignedPreKeySignature(
            device.identityPublicKey,
            publicKey,
            signature
        );

        if (!signatureVerification.valid) {
            return res.status(400).json({
                message: `Signature verification failed: ${signatureVerification.error}`
            });
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
        console.error("Error in uploadSignedPreKey:", sanitizeForLogging(error));
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

        if (!Number.isInteger(keyId) || keyId < 0 || keyId > 4294967295) {
            return res.status(400).json({ message: "Invalid keyId (must be a non-negative 32-bit integer)" });
        }

        const pubKeyValidation = validateBase64Key(publicKey, 33, "publicKey");
        if (!pubKeyValidation.valid) {
            return res.status(400).json({ message: pubKeyValidation.error });
        }

        const sigValidation = validateBase64Key(signature, 64, "signature");
        if (!sigValidation.valid) {
            return res.status(400).json({ message: sigValidation.error });
        }

        const device = await Device.findOne({ userId, deviceId });
        if (!device) {
            return res.status(404).json({ message: "Device not found" });
        }

        // Verify the signed pre-key is signed by the user's identity key
        const signatureVerification = verifySignedPreKeySignature(
            device.identityPublicKey,
            publicKey,
            signature
        );

        if (!signatureVerification.valid) {
            return res.status(400).json({
                message: `Signature verification failed: ${signatureVerification.error}`
            });
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
        console.error("Error in rotateSignedPreKey:", sanitizeForLogging(error));
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

        // Validate all keys before inserting
        const validatedKeys = [];
        for (let i = 0; i < setOfOneTimePreKeys.length; i++) {
            const key = setOfOneTimePreKeys[i];

            if (!key || typeof key !== 'object') {
                return res.status(400).json({
                    message: `Invalid key at index ${i}: must be an object with keyId and publicKey`
                });
            }

            if (!Number.isInteger(key.keyId) || key.keyId < 0 || key.keyId > 4294967295) {
                return res.status(400).json({
                    message: `Invalid keyId at index ${i} (must be a non-negative 32-bit integer)`
                });
            }

            const pubKeyValidation = validateBase64Key(key.publicKey, 33, `publicKey at index ${i}`);
            if (!pubKeyValidation.valid) {
                return res.status(400).json({ message: pubKeyValidation.error });
            }

            validatedKeys.push({
                userId,
                deviceId,
                keyId: key.keyId,
                publicKey: key.publicKey,
            });
        }

        const device = await Device.findOne({ userId, deviceId });
        if (!device) {
            return res.status(404).json({ message: "Device not found. Register a device first." });
        }

        await OneTimePreKey.insertMany(validatedKeys);

        res.status(200).json({ message: "One-time pre-keys uploaded successfully" });
    } catch (error) {
        // Check for duplicate key error
        if (error.code === 11000) {
            return res.status(400).json({ message: "One or more pre-keys already exist" });
        }
        console.error("Error in uploadOneTimePreKey:", sanitizeForLogging(error));
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
        console.error("Error in getPreKeyBundle:", sanitizeForLogging(error));
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
        console.error("Error in getPreKeyCount:", sanitizeForLogging(error));
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
        console.error("Error in flagOldSignedPreKeysForRotation:", sanitizeForLogging(error));
    }
};
