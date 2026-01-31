import mongoose from "mongoose";

const messageSchema = new mongoose.Schema(
  {
    senderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    receiverId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    text: String,
    image: String,

    // 🔹 future-proofing
    readAt: {
      type: Date,
      default: null,
    },

    conversationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Conversation",
      required: true,
      index: true,
    },
  },
  { timestamps: true },
);

// compound index for chat queries
messageSchema.index({ senderId: 1, receiverId: 1, createdAt: 1 });
const Message = mongoose.model("Message", messageSchema);
export default Message;
