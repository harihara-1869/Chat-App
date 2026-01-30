import mongoose from 'mongoose';
import dotenv from 'dotenv';

dotenv.config();

export async function connectDB() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log("MongoDB connected successfully with Mongoose!");
    return mongoose.connection;
  } catch (error) {
    console.error("Failed to connect to MongoDB:", error);
    throw error;
  }
}

// Initialize the connection
let isConnected = false;

export async function initDB() {
  if (!isConnected) {
    await connectDB();
    isConnected = true;
  }
  return mongoose.connection;
}