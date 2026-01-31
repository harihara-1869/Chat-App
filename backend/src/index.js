import express from 'express';
import authRoutes from './routes/auth.route.js';
import messageRoutes from './routes/message.route.js';
import dotenv from 'dotenv';
import {initDB} from './lib/db.js';
import cookieParser from 'cookie-parser';
import cors from 'cors';
import {app, server} from "./lib/socket.js"

dotenv.config();


const PORT = process.env.PORT || 5001;

app.use(express.json());
app.use(cookieParser());
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:5173',
  credentials: true,
}));

app.use("/api/auth", authRoutes)
app.use("/api/message", messageRoutes)

async function startServer() {
  try {
    // 1️⃣ Connect to MongoDB FIRST
    await initDB();
    console.log("MongoDB connected");

    // 2️⃣ Start server ONLY after DB is ready
    server.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error("Server failed to start:", error);
    process.exit(1);
  }
}

startServer();