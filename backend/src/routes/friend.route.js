import express from 'express'
import { protectRoute } from '../middleware/auth.middleware.js';
import { 
  acceptFriendRequest, 
  friendRequest, 
  rejectFriendRequest, 
  getPendingRequests,
  blockUser,
  unfriendUser,
  getBlockedUsers
} from '../controllers/friend.controller.js';

const router = express.Router()

router.post("/request/:userId", protectRoute, friendRequest)

router.get("/requests/pending", protectRoute, getPendingRequests)

router.post("/accept/:requestId", protectRoute, acceptFriendRequest)

router.post("/reject/:requestId", protectRoute, rejectFriendRequest)

router.post("/block/:userId", protectRoute, blockUser)

router.delete("/:userId", protectRoute, unfriendUser)

router.get("/blocked", protectRoute, getBlockedUsers)

export default router;