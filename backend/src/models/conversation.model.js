import mongoose from "mongoose";

const conversationSchema = new mongoose.Schema(
  {
    participants: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true,
      },
    ],
    lastMessage: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Message",
    },
  },
  { timestamps: true }
);

conversationSchema.index(
  { participants: 1 },
  { unique: true }
);

conversationSchema.pre("deleteOne", async function (next) {
  await Message.deleteMany({ conversationId: this._id });
  next();
});


const Conversation = mongoose.model("Conversation", conversationSchema);
export default Conversation;