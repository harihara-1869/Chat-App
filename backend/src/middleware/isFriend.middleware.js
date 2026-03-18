import User from "../models/user.model.js";

export default async function isFriend(req, res, next) {
  const senderId = req.user._id;
  const targetId = req.params.id || req.body.receiverId || req.body.recipientId;

  // Check if sender has blocked the target
  const senderBlocked = await User.exists({
    _id: senderId,
    blockedUsers: targetId,
  });

  if (senderBlocked) {
    return res.status(403).json({ error: "You have blocked this user" });
  }

  // Check if target has blocked the sender
  const targetBlocked = await User.exists({
    _id: targetId,
    blockedUsers: senderId,
  });

  if (targetBlocked) {
    return res.status(403).json({ error: "You are blocked by this user" });
  }

  // Check if they are friends (required for messaging)
  const isFriend = await User.exists({
    _id: senderId,
    friends: targetId,
  });

  if (!isFriend) {
    return res.status(403).json({ error: "Not friends" });
  }

  next();
}
