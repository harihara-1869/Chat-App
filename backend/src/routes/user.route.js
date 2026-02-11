import express from "express";
import { getFriends, updateProfile, getUserInfo } from "../controllers/user.controller.js";
import { protectRoute } from "../middleware/auth.middleware.js";

const router = express.Router();

router.put('/update-profile', protectRoute, updateProfile);

router.get('/get-user', protectRoute, getUserInfo);

router.get('/get-friends', protectRoute, getFriends);

export default router;
