import mongoose from "mongoose";

const signedPreKeySchema = new mongoose.Schema(
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
    signature: {
      type: String, // base64
      required: true,
    },
  },
  { timestamps: true }
);

// One active signed prekey per user-device pair
signedPreKeySchema.index({ userId: 1, deviceId: 1 }, { unique: true });

const SignedPreKey = mongoose.model("SignedPreKey", signedPreKeySchema);
export default SignedPreKey;