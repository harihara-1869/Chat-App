import express from "express";
import { getFriends, updateProfile, getUserInfo, acceptPolicies } from "../controllers/user.controller.js";
import { protectRoute } from "../middleware/auth.middleware.js";
import { authRateLimiter } from "../middleware/rateLimit.middleware.js";

const router = express.Router();

router.put('/update-profile', protectRoute, updateProfile);

router.get('/get-user', protectRoute, getUserInfo);

router.get('/get-friends', protectRoute, getFriends);

router.post('/accept-policies', authRateLimiter, acceptPolicies);

export default router;
