import mongoose from "mongoose";

const sessionSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
        deviceId: {
            type: Number,
            default: 1,
        },
        peerUserId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
        peerDeviceId: {
            type: Number,
            default: 1,
        },
        hasSession: {
            type: Boolean,
            default: false,
        },
        lastMessageAt: {
            type: Date,
            default: null,
        },
    },
    { timestamps: true }
);

// Unique compound index for session pairs
sessionSchema.index(
    { userId: 1, deviceId: 1, peerUserId: 1, peerDeviceId: 1 },
    { unique: true }
);

const Session = mongoose.model("Session", sessionSchema);
export default Session;
