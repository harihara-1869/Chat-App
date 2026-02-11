import express from 'express'
import { protectRoute } from '../middleware/auth.middleware.js';
import { getMessages, sendMessage } from '../controllers/message.controller.js';
import isFriend from '../middleware/isFriend.middleware.js';

const router = express.Router();
router.get("/:id", protectRoute, isFriend, getMessages)

router.post("/send/:id", protectRoute, isFriend, sendMessage)

export default router;