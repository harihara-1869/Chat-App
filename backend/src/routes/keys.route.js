import express from 'express';
import { protectRoute } from '../middleware/auth.middleware.js';
import { uploadSignedPreKey, uploadOneTimePreKey, getPreKeyBundle, getPreKeyCount } from '../controllers/key.controller.js';

const router = express.Router();

router.post("/signed", protectRoute, uploadSignedPreKey);

router.post("/one-time", protectRoute, uploadOneTimePreKey);

router.get("/bundle/:userId", protectRoute, getPreKeyBundle);

router.get("/count", protectRoute, getPreKeyCount);

export default router;