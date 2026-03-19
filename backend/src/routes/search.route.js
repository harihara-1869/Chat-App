import { Router } from 'express'
import { protectRoute } from '../middleware/auth.middleware.js'
import User from '../models/user.model.js'
import { sanitizeForLogging } from '../lib/utils.js'

const router = Router()

const MIN_QUERY_LENGTH = 3;
const MAX_QUERY_LENGTH = 100;

router.get("/", protectRoute, async (req, res) => {
    try {
        const userId = req.user._id;
        let { q } = req.query;

        // Handle array input (prevent bypass via ?q[]=...)
        if (Array.isArray(q)) {
            q = q[0];
        }

        if (!q || typeof q !== 'string' || q.trim().length < MIN_QUERY_LENGTH) {
            return res.status(400).json({
                error: `Search query must be at least ${MIN_QUERY_LENGTH} characters`,
            });
        }

        const trimmed = q.trim();

        // Enforce maximum query length to prevent ReDoS and resource exhaustion
        if (trimmed.length > MAX_QUERY_LENGTH) {
            return res.status(400).json({
                error: `Search query must not exceed ${MAX_QUERY_LENGTH} characters`,
            });
        }

        const isEmail = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(trimmed);

        let users;

        if (isEmail) {
            users = await User.find({
                _id: { $ne: userId },
                email: trimmed.toLowerCase(),
            })
                .select("_id fullName profilePic")
                .limit(1);
        } else {
            // Escape special regex characters to prevent ReDoS attacks
            const escaped = trimmed.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            users = await User.find({
                _id: { $ne: userId },
                fullName: { $regex: escaped, $options: "i" },
            })
                .select("_id fullName profilePic")
                .limit(10);
        }

        res.status(200).json(users);
    } catch (error) {
        console.error("Error in searchUsers:", sanitizeForLogging(error));
        res.status(500).json({ error: "Internal server error" });
    }
})

export default router
