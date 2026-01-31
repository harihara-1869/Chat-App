import express from 'express';
import authRoutes from './routes/auth.route.js';
import messageRoutes from './routes/message.route.js';
import friendRoutes from './routes/friend.route.js'
import searchRoutes from './routes/search.route.js'
import dotenv from 'dotenv';
import { initDB } from './lib/db.js';
import cookieParser from 'cookie-parser';
import cors from 'cors';
import { app, server } from "./lib/socket.js"
import passport from './lib/passport.js';
import { generalRateLimiter } from './middleware/rateLimit.middleware.js';

dotenv.config();


const PORT = process.env.PORT || 5001;

app.use(express.json({ limit: '10mb' })); // Limit payload size
app.use(cookieParser());
app.use(cors({
  origin: process.env.FRONTEND_URL || "http://localhost:5173",
  credentials: true,
}));

// Initialize Passport (no session needed for JWT-based auth)
app.use(passport.initialize());

// Trust proxy for accurate IP detection behind reverse proxies (nginx, cloudflare, etc.)
app.set('trust proxy', 1);

// Apply general rate limiting to all API routes
app.use("/api", generalRateLimiter);

app.use("/api/auth", authRoutes)
app.use("/api/message", messageRoutes)
app.use("/api/friend", friendRoutes)
app.use("/api/search", searchRoutes)

async function startServer() {
  try {
    // 1️⃣ Connect to MongoDB FIRST
    await initDB();
    console.log("MongoDB connected");

    // 2️⃣ Start server ONLY after DB is ready
    server.listen(PORT, "0.0.0.0", () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error("Server failed to start:", error);
    process.exit(1);
  }
}

startServer();