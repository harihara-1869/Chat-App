import express from 'express';
import { protectRoute } from '../middleware/auth.middleware.js';
import { getUploadUrl, getDownloadUrl } from '../controllers/attachment.controller.js';

const router = express.Router();

router.post("/upload-url", protectRoute, getUploadUrl);

router.get("/download-url/:fileKey", protectRoute, getDownloadUrl);

export default router;
