import cloudinary from "../lib/cloudinary.js";
import { getReciverSocketId } from "../lib/socket.js";
import Message from "../models/message.model.js";
import User from "../models/user.model.js";
import {io} from "../lib/socket.js"

export const getUsersForSidebar = async (req, res) => {
  try {
    const loggedInUserId = req.user._id;

    const user = await User.findById(loggedInUserId)
      .populate("friends", "fullName profilePic email")
      .select("friends");

    res.status(200).json(user.friends);
  } catch (error) {
    console.error("Error in getUsersForSidebar:", error.message);
    res.status(500).json({ error: "Internal server error" });
  }
};

export const getMessages = async (req, res) => {
  try {
    const {id:userToChatId} = req.params;
    const senderId = req.user._id;
    
    const messages = await Message.find({
      $or:[
        {senderId: senderId, receiverId:userToChatId},
        {senderId: userToChatId, receiverId: senderId}
      ]
    })

    res.status(200).json(messages)
  } catch (error) {
    console.error("Error in getMessages controller: ", error);
    res.status(500).json({error: "Internal server error"})
  }
}

export const sendMessage = async (req, res) => {
  try{
    const {text, image} = req.body;
    const {id: receiverId} = req.params;
    const senderId = req.user._id;

    let imageUrl;
    if(image) {
      const uploadResponse = await cloudinary.uploader.upload(image);
      imageUrl = uploadResponse.secure_url;
    }

    const newMessage = new Message({
      senderId,
      receiverId,
      text,
      image: imageUrl,
    });

    await newMessage.save();

    const reciverSocketId = getReciverSocketId(receiverId)
    if(reciverSocketId){
      io.to(reciverSocketId).emit("newMessage", newMessage)
    }

    res.status(201).json(newMessage)
  }catch (error){
    console.error("Error in sendMessage controller: ", error.message);
    res.status(500).json({error: "Internal server error"})
  }
}