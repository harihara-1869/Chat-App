import mongoose from "mongoose";

const deviceSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
            unique: true, // Single device per user for now. Remove for multi-device.
        },
        deviceId: {
            type: Number,
            default: 1,
        },
        registrationId: {
            type: Number,
            required: true,
        },
        identityPublicKey: {
            type: String, // base64 encoded Curve25519 public key
            required: true,
        },
        identityKeyFingerprint: {
            type: String, // SHA-256 fingerprint for safety number display
        },
        label: {
            type: String, // e.g. "Chrome on Windows", "iPhone 15"
            default: "",
        },
        platform: {
            type: String,
            enum: ["web", "ios", "android"],
            default: "web",
        },
        fcmToken: {
            type: String,
        },
        lastSeenAt: {
            type: Date,
            default: Date.now,
        },
    },
    { timestamps: true }
);

// Compound index for future multi-device support
deviceSchema.index({ userId: 1, deviceId: 1 }, { unique: true });

const Device = mongoose.model("Device", deviceSchema);
export default Device;
