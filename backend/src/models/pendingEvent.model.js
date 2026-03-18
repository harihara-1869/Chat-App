import mongoose from "mongoose";

const pendingEventSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
    index: true,
  },
  eventName: {
    type: String,
    required: true,
    enum: ["newMessage", "friendRequest", "friendAccepted"],
  },
  payload: {
    type: mongoose.Schema.Types.Mixed,
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
    expires: 7 * 24 * 60 * 60, // Auto-delete after 7 days
  },
});

pendingEventSchema.index({ userId: 1, createdAt: 1 });

const PendingEvent = mongoose.model("PendingEvent", pendingEventSchema);

export default PendingEvent;
