import User from "../models/user.model.js";

export default async function isFriend(req, res, next) {
  const senderId = req.user._id;
  const targetId = req.params.id || req.body.receiverId;

  const isFriend = await User.exists({
    _id: senderId,
    friends: targetId,
  });

  if (!isFriend) {
    return res.status(403).json({ error: "Not friends" });
  }

  next();
}
