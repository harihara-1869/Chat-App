import express from 'express';
import { protectRoute } from '../middleware/auth.middleware.js';
import {
  uploadSignedPreKey,
  uploadKyberPreKey,
  uploadOneTimePreKey,
  getPreKeyBundle,
  getPreKeyCount,
  rotateSignedPreKey,
} from '../controllers/key.controller.js';
import { strictRateLimiter } from "../middleware/rateLimit.middleware.js";

const router = express.Router();

router.post("/signed", protectRoute, uploadSignedPreKey);

router.post("/rotate", protectRoute, rotateSignedPreKey);

router.post("/kyber", protectRoute, uploadKyberPreKey);

router.post("/one-time", protectRoute, uploadOneTimePreKey);

router.get("/bundle/:userId", protectRoute, strictRateLimiter, getPreKeyBundle);

/**
 * Get the count of remaining one-time pre-keys.
 * Threshold: 10 keys. If count < 10, client should upload more.
 */
router.get("/count", protectRoute, getPreKeyCount);

export default router;
