import express from 'express';
import passport from '../lib/passport.js';
import { login, logout, signup, updateProfile, getUserInfo, googleCallback, verifyEmail, resetPassword, updatePassword } from '../controllers/auth.controller.js';
import { protectRoute } from '../middleware/auth.middleware.js';
import { authRateLimiter, strictRateLimiter } from '../middleware/rateLimit.middleware.js';

const router = express.Router();

// Apply rate limiting to auth routes
router.post('/signup', authRateLimiter, signup)

router.post('/login', authRateLimiter, login)

router.post('/verify-email', authRateLimiter, verifyEmail);

router.post('/logout', protectRoute, logout)

router.post('/reset-password', strictRateLimiter, resetPassword);

router.post('/update-password', strictRateLimiter, updatePassword);

router.put('/update-profile', protectRoute, updateProfile);

router.get('/get-user', protectRoute, getUserInfo);

// Google OAuth routes
router.get('/google', authRateLimiter, passport.authenticate('google', {
    scope: ['profile', 'email']
}));

router.get('/google/callback',
    passport.authenticate('google', {
        session: false,
        failureRedirect: '/login?error=oauth_failed'
    }),
    googleCallback
);

export default router;