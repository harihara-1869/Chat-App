import express from 'express';
import authRoutes from './routes/auth.route.js';
import dotenv from 'dotenv';
import {initDB, connectDB, getDB} from './lib/db.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5001;

app.use("/api/auth", authRoutes)

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
  initDB().then(() => {
    console.log("Database initialized");
  }).catch((err) => {
    console.error("Failed to initialize database:", err);
  });
});