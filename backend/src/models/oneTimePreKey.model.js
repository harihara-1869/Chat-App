import mongoose from "mongoose";

const oneTimePreKeySchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    deviceId: {
      type: Number,
      required: true,
      default: 1,
    },
    keyId: {
      type: Number,
      required: true,
    },
    publicKey: {
      type: String, // base64
      required: true,
    },
    used: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

// Compound index for fast lookup of unused OTKs per user-device
oneTimePreKeySchema.index({ userId: 1, deviceId: 1, used: 1 });

const OneTimePreKey = mongoose.model("OneTimePreKey", oneTimePreKeySchema);
export default OneTimePreKey;