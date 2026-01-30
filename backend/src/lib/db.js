import {MongoClient, ServerApiVersion} from 'mongodb';
import dotenv from 'dotenv';

dotenv.config();

const client = new MongoClient(process.env.MONGO_URI, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  }
});


export async function connectDB() {
  try {
    // Connect the client to the server	(optional starting in v4.7)
    await client.connect();
    // Send a ping to confirm a successful connection
    await client.db("admin").command({ ping: 1 });
    console.log("Pinged your deployment. You successfully connected to MongoDB!");
    return client;
  } catch (error) {
    console.error("Failed to connect to MongoDB:", error);
    throw error;
  }
}

// Initialize the connection
let dbClient;

export async function initDB() {
  if (!dbClient) {
    dbClient = await connectDB();
  }
  return dbClient;
}

export function getDB() {
  if (!dbClient) {
    throw new Error("Database not initialized. Call initDB() first.");
  }
  return dbClient;
}