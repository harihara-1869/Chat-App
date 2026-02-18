import mongoose from "mongoose";

const messageSchema = new mongoose.Schema(
  {
    conversationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Conversation",
      required: true,
      index: true,
    },

    senderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    senderDeviceId: {
      type: Number,
      default: 1,
    },

    receiverId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    recipientDeviceId: {
      type: Number,
      default: 1,
    },

    type: {
      type: String,
      enum: ["prekey", "message"],
      required: true,
    },

    // PreKey message data (only for first message / session setup)
    preKeyBundle: {
      identityKey: String,
      ephemeralKey: String,
      signedPreKeyId: Number,
      oneTimePreKeyId: Number,
    },

    // Double Ratchet Header
    ratchetHeader: {
      ratchetPublicKey: String,
      messageNumber: Number,
      previousChainLength: Number,
    },

    ciphertext: {
      type: String, // base64
      required: true,
    },

    // Sender's registration ID for session matching
    registrationId: {
      type: Number,
    },

    attachments: [
      {
        fileType: String,        // "image/jpeg", "image/png"
        encryptedUrl: String,    // URL to encrypted file
        fileSize: Number,
      },
    ],

    readAt: {
      type: Date,
      default: null,
    },

    protocolVersion: {
      type: Number,
      default: 1,
    },
  },
  { timestamps: true }
);

messageSchema.index({ conversationId: 1, createdAt: 1 });

const Message = mongoose.model("Message", messageSchema);
export default Message;
