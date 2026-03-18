import { Server } from "socket.io"
import http from "http";
import express from "express";
import jwt from "jsonwebtoken";
import cookie from "cookie";
import User from "../models/user.model.js";
import PendingEvent from "../models/pendingEvent.model.js";
import redisClient from "./redis.js";
import { createAdapter } from "@socket.io/redis-adapter";
import { sendPushNotification, sendFriendRequestNotification, sendFriendAcceptedNotification } from "./firebase.js";
import dotenv from "dotenv";

dotenv.config();

const app = express();
const server = http.createServer(app);

// Try to set up Redis adapter, fall back to in-memory if unavailable
let io;
try {
  io = new Server(server, {
    cors: {
      origin: process.env.FRONTEND_URL || "http://localhost:5173",
      credentials: true,
      methods: ["GET", "POST"],
      allowedHeaders: ["Content-Type", "Authorization"],
    },
  });

  // Set up Redis adapter for multi-instance support
  const redisAdapter = createAdapter(redisClient, redisClient);
  io.adapter(redisAdapter);
  console.log("Socket.io Redis adapter initialized");
} catch (error) {
  console.warn("Failed to initialize Redis adapter, using default:", error.message);
  io = new Server(server, {
    cors: {
      origin: process.env.FRONTEND_URL || "http://localhost:5173",
      credentials: true,
      methods: ["GET", "POST"],
      allowedHeaders: ["Content-Type", "Authorization"],
    },
  });
}

// Middleware to authenticate socket connections using JWT from cookies
io.use(async (socket, next) => {
  try {
    const cookies = cookie.parse(socket.handshake.headers.cookie || "");
    const token = cookies.jwt;

    if (!token) {
      return next(new Error("Authentication error: No token provided"));
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    if (decoded.type !== "access_token") {
      return next(new Error("Token is not valid."));
    }

    const user = await User.findById(decoded.id).select("-password");

    if (!user) {
      return next(new Error("Authentication error: User not found"));
    }

    if (!user.privacyPolicyAccepted || !user.termsAndConditionsAccepted) {
      return next(new Error("Policy not accepted"));
    }

    socket.userId = user._id.toString();
    next();
  } catch (error) {
    console.error("Socket authentication error:", error.message);
    next(new Error("Authentication error: Invalid token"));
  }
});

const SOCKET_MAP_KEY = "user:socket:map";

async function getSocketId(userId) {
  try {
    return await redisClient.hget(SOCKET_MAP_KEY, userId);
  } catch (error) {
    console.error("Redis hget error:", error.message);
    return null;
  }
}

async function setSocketId(userId, socketId) {
  try {
    await redisClient.hset(SOCKET_MAP_KEY, userId, socketId);
  } catch (error) {
    console.error("Redis hset error:", error.message);
  }
}

async function deleteSocketId(userId) {
  try {
    await redisClient.hdel(SOCKET_MAP_KEY, userId);
  } catch (error) {
    console.error("Redis hdel error:", error.message);
  }
}

export async function getReciverSocketId(userId) {
  return await getSocketId(userId);
}

export async function flushPendingEvents(userId) {
  try {
    const pendingEvents = await PendingEvent.find({ userId }).sort({ createdAt: 1 }).limit(50);
    
    if (pendingEvents.length === 0) return;

    const socketId = await getSocketId(userId.toString());
    if (!socketId) return;

    for (const event of pendingEvents) {
      io.to(socketId).emit(event.eventName, event.payload);
    }

    await PendingEvent.deleteMany({ _id: { $in: pendingEvents.map(e => e._id) } });
    console.log(`Flushed ${pendingEvents.length} pending events for user ${userId}`);
  } catch (error) {
    console.error("Error flushing pending events:", error);
  }
}

export async function sendToUser(userId, eventName, payload, options = {}) {
  const { skipPush = false } = options;
  const socketId = await getSocketId(userId.toString());
  
  if (socketId) {
    io.to(socketId).emit(eventName, payload);
    return { sent: true, method: 'socket' };
  } else {
    await bufferPendingEvent(userId, eventName, payload);
    if (!skipPush) {
      await sendPushNotification(userId, eventName, payload);
    }
    return { sent: true, method: 'buffered' };
  }
}

export async function bufferPendingEvent(userId, eventName, payload) {
  try {
    await PendingEvent.create({
      userId,
      eventName,
      payload,
    });
  } catch (error) {
    console.error("Error buffering pending event:", error);
  }
}

io.on("connection", (socket) => {
  console.log("A user connected", socket.id, "userId:", socket.userId);

  const userId = socket.userId;
  socket.deviceId = socket.handshake.auth?.deviceId || 1;

  // Store in Redis
  setSocketId(userId, socket.id);

  // Flush any pending events for this user
  flushPendingEvents(userId);

  // Get all online users from Redis
  redisClient.hkeys(SOCKET_MAP_KEY).then(keys => {
    io.emit("getOnlineUsers", keys);
  });

  // Handle message delivery acknowledgement
  socket.on("ackMessage", (data) => {
    const { messageId, status } = data;
    console.log(`Message ${messageId} acknowledged as ${status}`);
  });

  socket.on("disconnect", async () => {
    console.log("A user disconnected", socket.id);
    await deleteSocketId(userId);
    
    const keys = await redisClient.hkeys(SOCKET_MAP_KEY);
    io.emit("getOnlineUsers", keys);
  });
});

export { io, app, server }
