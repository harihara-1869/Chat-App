import mongoose from "mongoose";

const kyberPreKeySchema = new mongoose.Schema(
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
      type: String,
      required: true,
    },
    signature: {
      type: String,
      required: true,
    },
    status: {
      type: String,
      enum: ["active", "archived"],
      default: "active",
    },
    archivedAt: {
      type: Date,
      default: null,
    },
  },
  { timestamps: true }
);

kyberPreKeySchema.index({ userId: 1, deviceId: 1, status: 1 });
kyberPreKeySchema.index({ userId: 1, deviceId: 1, createdAt: 1 });

const KyberPreKey = mongoose.model("KyberPreKey", kyberPreKeySchema);
export default KyberPreKey;
