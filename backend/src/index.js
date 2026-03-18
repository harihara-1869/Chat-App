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
import { requirePrivacyPolicy } from './middleware/requirePrivacyPolicy.js';
import userRoutes from './routes/user.route.js';
import privacyRoutes from './routes/privacy.route.js';
import keyRoutes from './routes/keys.route.js';
import deviceRoutes from './routes/device.route.js';
import attachmentRoutes from './routes/attachment.route.js';
import { flagOldSignedPreKeysForRotation } from './controllers/key.controller.js';
import cron from 'node-cron';
dotenv.config();


const PORT = process.env.PORT || 5001;

// Security middleware

app.use(express.json({ limit: '10mb' })); // Limit payload size
app.use(cookieParser());
app.use(cors({
  origin: process.env.FRONTEND_URL || "http://localhost:5173",
  credentials: true,
}));

// Security headers
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
  res.setHeader('Content-Security-Policy', "default-src 'self'");
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  next();
});

// Initialize Passport (no session needed for JWT-based auth)
app.use(passport.initialize());

app.set('trust proxy', 1);
app.use("/api", generalRateLimiter);

// Enforce privacy policy acceptance on all /api routes (after rate limiting)
app.use("/api", requirePrivacyPolicy);

app.use("/api/auth", authRoutes)
app.use("/api/devices", deviceRoutes)
app.use("/api/attachments", attachmentRoutes)
app.use("/api/keys", keyRoutes)
app.use("/api/privacy-policy", privacyRoutes)
app.use("/api/message", messageRoutes)
app.use("/api/friend", friendRoutes)
app.use("/api/search", searchRoutes)
app.use("/api/user", userRoutes)

async function startServer() {
  try {
    // 1️⃣ Connect to MongoDB FIRST
    await initDB();
    console.log("MongoDB connected");

    // 2️⃣ Start scheduled jobs
    // Run daily at midnight to check for old signed pre-keys
    cron.schedule('0 0 * * *', () => {
      console.log('[Cron] Running signed pre-key rotation check...');
      flagOldSignedPreKeysForRotation();
    });

    // 3️⃣ Start server ONLY after DB is ready
    server.listen(PORT, "0.0.0.0", () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error("Server failed to start:", error);
    process.exit(1);
  }
}

startServer();