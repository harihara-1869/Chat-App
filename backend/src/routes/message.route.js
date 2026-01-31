import express from 'express'
import { protectRoute } from '../middleware/auth.middleware.js';
import { getUsersForSidebar, getMessages, sendMessage } from '../controllers/message.controller.js';
import isFriend from '../middleware/isFriend.middleware.js';

const router = express.Router();

router.get("/users", protectRoute, getUsersForSidebar)
router.get("/:id", protectRoute, isFriend, getMessages)

router.post("/send/:id", protectRoute, isFriend, sendMessage)

export default router;