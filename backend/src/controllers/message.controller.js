import { getReciverSocketId, bufferPendingEvent } from "../lib/socket.js";
import Message from "../models/message.model.js";
import Conversation from "../models/conversation.model.js";
import Device from "../models/device.model.js";
import { io } from "../lib/socket.js";

/**
 * Get messages between two users with pagination.
 * 
 * Query params:
 * - limit: number of messages to return (default: 30, max: 100)
 * - before: messageId to get messages older than (cursor-based pagination)
 */
export const getMessages = async (req, res) => {
  try {
    const { id: userToChatId } = req.params;
    const senderId = req.user._id;
    const limit = Math.min(parseInt(req.query.limit) || 30, 100);
    const before = req.query.before;

    const query = {
      $or: [
        { senderId: senderId, receiverId: userToChatId },
        { senderId: userToChatId, receiverId: senderId },
      ],
    };

    // Cursor-based pagination
    if (before) {
      const beforeMessage = await Message.findById(before);
      if (beforeMessage) {
        query.createdAt = { $lt: beforeMessage.createdAt };
      }
    }

    const messages = await Message.find(query)
      .sort({ createdAt: -1 })
      .limit(limit + 1) // Fetch one extra to determine hasMore
      .lean();

    const hasMore = messages.length > limit;
    if (hasMore) {
      messages.pop();
    }

    // Reverse to get oldest first
    const sortedMessages = hasMore ? messages.reverse() : messages;

    res.status(200).json({
      messages: sortedMessages,
      hasMore,
    });
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

    // Emit to receiver if online, otherwise buffer for later delivery
    const receiverSocketId = getReciverSocketId(receiverId.toString());
    const messagePayload = newMessage.toObject();
    
    if (receiverSocketId) {
      io.to(receiverSocketId).emit("newMessage", messagePayload);
    } else {
      // Buffer the message for offline delivery
      await bufferPendingEvent(receiverId, "newMessage", messagePayload);
    }

    res.status(201).json(newMessage);
  } catch (error) {
    console.error("Error in sendMessage controller:", error.message);
    res.status(500).json({ error: "Internal server error" });
  }
};
