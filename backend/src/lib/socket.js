import { Server } from "socket.io"
import http from "http";
import express from "express";
import jwt from "jsonwebtoken";
import cookie from "cookie";
import User from "../models/user.model.js";
import dotenv from "dotenv";

dotenv.config();

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: process.env.FRONTEND_URL || "http://localhost:5173",
    credentials: true, // Allow cookies to be sent,
    methods: ["GET", "POST"],
    allowedHeaders: ["Content-Type", "Authorization"],
  },
});

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

    socket.userId = user._id.toString(); // Attach userId to socket
    next();
  } catch (error) {
    console.error("Socket authentication error:", error.message);
    next(new Error("Authentication error: Invalid token"));
  }
});

export function getReciverSocketId(userId) {
  return userSocketMap[userId]
}

//Stores online users
const userSocketMap = {}

io.on("connection", (socket) => {
  console.log("A user connected", socket.id, "userId:", socket.userId);

  const userId = socket.userId; // Use authenticated userId, not query param
  // Store deviceId from handshake for future multi-device support
  socket.deviceId = socket.handshake.auth?.deviceId || 1;

  if (userId) userSocketMap[userId] = socket.id

  //io.emit() is used to send events to all connected clients
  io.emit("getOnlineUsers", Object.keys(userSocketMap));

  socket.on("disconnect", () => {
    console.log("A user disconnected", socket.id)
    delete userSocketMap[userId];
    io.emit("getOnlineUsers", Object.keys(userSocketMap));
  })
})

export { io, app, server }