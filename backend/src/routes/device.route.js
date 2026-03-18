import express from 'express';
import { protectRoute } from '../middleware/auth.middleware.js';
import { registerDevice, removeDevice, getMyDevice, saveFcmToken } from '../controllers/device.controller.js';

const router = express.Router();

router.post("/register", protectRoute, registerDevice);

router.delete("/", protectRoute, removeDevice);

router.get("/me", protectRoute, getMyDevice);

router.post("/fcm-token", protectRoute, saveFcmToken);

export default router;
