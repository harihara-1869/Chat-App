import express from 'express';
import { protectRoute } from '../middleware/auth.middleware.js';
import { registerDevice, removeDevice, getMyDevice } from '../controllers/device.controller.js';

const router = express.Router();

router.post("/register", protectRoute, registerDevice);

router.delete("/", protectRoute, removeDevice);

router.get("/me", protectRoute, getMyDevice);

export default router;
