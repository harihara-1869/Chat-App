import FriendRequest from "../models/friendRequest.model.js";
import User from "../models/user.model.js";
import Conversation from "../models/conversation.model.js";
import { io, getReciverSocketId } from "../lib/socket.js";

export async function friendRequest(req, res) {
  try {
    const senderId = req.user._id;
    const { userId: receiverId } = req.params;

    if (senderId.toString() === receiverId) {
      return res.status(400).json({ error: "You can't add yourself" });
    }

    const targetUser = await User.findById(receiverId);
    if (!targetUser) {
      return res.status(404).json({ error: "User not found" });
    }

    const existingRequest = await FriendRequest.findOne({
      $or: [
        { senderId, receiverId },
        { senderId: receiverId, receiverId: senderId },
      ],
    });

    if (existingRequest) {
      // If pending, don't allow duplicate
      if (existingRequest.status === "pending") {
        return res.status(400).json({
          error: "Friend request already exists",
        });
      }
      // If accepted, they're already friends (shouldn't reach here due to check below, but safety)
      if (existingRequest.status === "accepted") {
        return res.status(400).json({ error: "Already friends" });
      }
      // If rejected, allow re-sending by updating status back to pending
      if (existingRequest.status === "rejected") {
        // Update the sender to current user if they're re-requesting
        existingRequest.senderId = senderId;
        existingRequest.receiverId = receiverId;
        existingRequest.status = "pending";
        await existingRequest.save();
        return res.json({ success: true });
      }
    }

    const alreadyFriends = await User.exists({
      _id: senderId,
      friends: receiverId,
    });

    if (alreadyFriends) {
      return res.status(400).json({ error: "Already friends" });
    }

    const newRequest = await FriendRequest.create({ senderId, receiverId });

    // Populate sender info and emit socket event to receiver
    const populatedRequest = await FriendRequest.findById(newRequest._id)
      .populate("senderId", "fullName profilePic email");

    const receiverSocketId = getReciverSocketId(receiverId);
    if (receiverSocketId) {
      io.to(receiverSocketId).emit("newFriendRequest", populatedRequest);
    }

    return res.json({ success: true });

  } catch (err) {
    if (err.code === 11000) {
      return res.status(400).json({
        error: "Friend request already sent",
      });
    }

    console.error(err);
    return res.status(500).json({ error: "Server error" });
  }
}

export async function acceptFriendRequest(req, res) {
  try {
    const userId = req.user._id;
    const { requestId } = req.params;

    const request = await FriendRequest.findById(requestId);
    if (!request) {
      return res.status(404).json({ error: "Friend request not found" });
    }

    if (request.receiverId.toString() !== userId.toString()) {
      return res.status(403).json({ error: "Not authorized" });
    }

    if (request.status !== "pending") {
      return res.status(400).json({ error: "Request already handled" });
    }

    request.status = "accepted";
    await request.save();

    const userA = request.senderId;
    const userB = request.receiverId;

    // Add userB to userA's friends, and userA to userB's friends
    await User.findByIdAndUpdate(userA, {
      $addToSet: { friends: userB }
    });
    await User.findByIdAndUpdate(userB, {
      $addToSet: { friends: userA }
    });

    try {
      await Conversation.create({
        participants: [userA, userB],
      });
    } catch (err) {
      if (err.code !== 11000) {
        throw err;
      }
    }

    // Emit socket events to both users
    const senderSocketId = getReciverSocketId(userA.toString());
    const receiverSocketId = getReciverSocketId(userB.toString());

    // Get both users' info for the event
    const senderUser = await User.findById(userA).select("fullName profilePic email");
    const receiverUser = await User.findById(userB).select("fullName profilePic email");

    if (senderSocketId) {
      io.to(senderSocketId).emit("friendRequestAccepted", { friend: receiverUser });
    }
    if (receiverSocketId) {
      io.to(receiverSocketId).emit("friendRequestAccepted", { friend: senderUser });
    }

    return res.json({ success: true });
  } catch (err) {
    console.error("Error in acceptFriendRequest:", err);
    return res.status(500).json({ error: "Server error" });
  }
}

export async function rejectFriendRequest(req, res) {
  try {
    const userId = req.user._id;
    const { requestId } = req.params;

    const request = await FriendRequest.findById(requestId);

    if (!request) {
      return res.status(404).json({ error: "Friend request not found" });
    }

    if (request.receiverId.toString() !== userId.toString()) {
      return res.status(403).json({ error: "Not authorized" });
    }

    if (request.status !== "pending") {
      return res.status(400).json({ error: "Request already handled" });
    }

    request.status = "rejected";
    await request.save();

    return res.json({ success: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Server error" });
  }
}

export async function getPendingRequests(req, res) {
  try {
    const userId = req.user._id;

    const requests = await FriendRequest.find({
      receiverId: userId,
      status: "pending"
    }).populate("senderId", "fullName profilePic email");

    res.status(200).json(requests);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Server error" });
  }
}

export async function getFriends(req, res) {
  try {
    const userId = req.user._id;

    const user = await User.findById(userId).populate("friends", "fullName profilePic email");

    res.status(200).json(user.friends);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Server error" });
  }
}