import { getReciverSocketId } from "../lib/socket.js";
import Message from "../models/message.model.js";
import Conversation from "../models/conversation.model.js";
import Device from "../models/device.model.js";
import { io } from "../lib/socket.js";

/**
 * Get messages between two users.
 */
export const getMessages = async (req, res) => {
  try {
    const { id: userToChatId } = req.params;
    const senderId = req.user._id;

    const messages = await Message.find({
      $or: [
        { senderId: senderId, receiverId: userToChatId },
        { senderId: userToChatId, receiverId: senderId },
      ],
    }).sort({ createdAt: 1 });

    res.status(200).json(messages);
  } catch (error) {
    console.error("Error in getMessages controller:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

/**
 * Send an encrypted message.
 * 
 * The client encrypts the message using libsignal-client and sends:
 * - type: "prekey" (first message) or "message" (subsequent)
 * - ciphertext: base64-encoded encrypted message
 * - ratchetHeader: Double Ratchet header (for "message" type)
 * - preKeyBundle: pre-key bundle data (for "prekey" type)
 * - senderDeviceId: sender's device ID
 * - registrationId: sender's registration ID
 * - attachments: optional encrypted file attachments
 */
export const sendMessage = async (req, res) => {
  try {
    const { id: receiverId } = req.params;
    const senderId = req.user._id;
    const {
      type,
      ciphertext,
      ratchetHeader,
      preKeyBundle,
      senderDeviceId = 1,
      registrationId,
      attachments,
    } = req.body;

    // Validate required fields
    if (!type || !ciphertext) {
      return res.status(400).json({
        error: "type and ciphertext are required",
      });
    }

    if (!["prekey", "message"].includes(type)) {
      return res.status(400).json({
        error: "type must be 'prekey' or 'message'",
      });
    }

    // For prekey messages, preKeyBundle is required
    if (type === "prekey" && !preKeyBundle) {
      return res.status(400).json({
        error: "preKeyBundle is required for prekey messages",
      });
    }

    // For regular messages, ratchetHeader is required
    if (type === "message" && !ratchetHeader) {
      return res.status(400).json({
        error: "ratchetHeader is required for regular messages",
      });
    }

    // Find or create conversation
    let conversation = await Conversation.findOne({
      participants: { $all: [senderId, receiverId] },
    });

    if (!conversation) {
      conversation = await Conversation.create({
        participants: [senderId, receiverId],
      });
    }

    // Get recipient's device (single-device mode: always device 1)
    const recipientDevice = await Device.findOne({ userId: receiverId });
    const recipientDeviceId = recipientDevice ? recipientDevice.deviceId : 1;

    const newMessage = new Message({
      conversationId: conversation._id,
      senderId,
      senderDeviceId,
      receiverId,
      recipientDeviceId,
      type,
      ciphertext,
      ratchetHeader: ratchetHeader || undefined,
      preKeyBundle: preKeyBundle || undefined,
      registrationId,
      attachments: attachments || [],
    });

    await newMessage.save();

    // Update conversation's last message
    conversation.lastMessage = newMessage._id;
    await conversation.save();

    // Emit to receiver if online
    const receiverSocketId = getReciverSocketId(receiverId);
    if (receiverSocketId) {
      io.to(receiverSocketId).emit("newMessage", newMessage);
    }

    res.status(201).json(newMessage);
  } catch (error) {
    console.error("Error in sendMessage controller:", error.message);
    res.status(500).json({ error: "Internal server error" });
  }
};
