import express from "express";
import { protectRoute } from "../middleware/auth.middleware.js";
import {
    getPrivacyPolicyStatus,
    acceptPrivacyPolicy,
} from "../controllers/privacy.controller.js";

const router = express.Router();

// GET /api/privacy-policy/status — check acceptance status
router.get("/status", protectRoute, getPrivacyPolicyStatus);

// POST /api/privacy-policy/accept — accept the privacy policy
router.post("/accept", protectRoute, acceptPrivacyPolicy);

export default router;
