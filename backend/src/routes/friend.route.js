import express from 'express'
import { protectRoute } from '../middleware/auth.middleware.js';
import { acceptFriendRequest, friendRequest, rejectFriendRequest, getPendingRequests } from '../controllers/friend.controller.js';

const router = express.Router()

router.post("/request/:userId", protectRoute, friendRequest)

router.get("/requests/pending", protectRoute, getPendingRequests)

router.post("/accept/:requestId", protectRoute, acceptFriendRequest)

router.post("/reject/:requestId", protectRoute, rejectFriendRequest)

export default router;