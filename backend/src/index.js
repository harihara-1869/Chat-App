import express from 'express';
import authRoutes from './routes/auth.route.js';
import dotenv from 'dotenv';
import {initDB} from './lib/db.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5001;

app.use(express.json());
app.use("/api/auth", authRoutes)

async function startServer() {
  try {
    // 1️⃣ Connect to MongoDB FIRST
    await initDB();
    console.log("MongoDB connected");

    // 2️⃣ Start server ONLY after DB is ready
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error("Server failed to start:", error);
    process.exit(1);
  }
}

startServer();