import express from 'express';
import passport from '../lib/passport.js';
import { 
  login, 
  logout, 
  signup, 
  googleCallback, 
  verifyEmail, 
  resetPassword, 
  updatePassword,
  completeGoogleSignup,
  acceptPrivacyPolicy,
  verifyGoogleToken 
} from '../controllers/auth.controller.js';
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

// Google OAuth completion routes
router.get('/google/verify-token', authRateLimiter, verifyGoogleToken);
router.post('/google/complete-signup', authRateLimiter, completeGoogleSignup);
router.post('/google/accept-privacy', authRateLimiter, acceptPrivacyPolicy);

// Google OAuth routes
router.get('/google', authRateLimiter, passport.authenticate('google', {
    scope: ['profile', 'email']
}));

router.get('/google/callback',
    (req, res, next) => {
        passport.authenticate('google', {
            session: false,
        }, (err, authData, info) => {
            const frontendUrl = process.env.FRONTEND_URL || 'http://localhost:5173';

            if (err) {
                console.error('Google OAuth error:', err);
                return res.redirect(`${frontendUrl}/login?error=server_error`);
            }
            if (!authData) {
                return res.redirect(`${frontendUrl}/login?error=oauth_failed`);
            }

            req.user = authData;
            next();
        })(req, res, next);
    },
    googleCallback
);

export default router;