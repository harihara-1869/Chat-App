/**
 * Privacy Policy Enforcement Middleware
 * Blocks all API requests (403) if the authenticated user hasn't accepted the privacy policy.
 * Exempt routes are allowed through without the check.
 *
 * This middleware decodes the JWT itself (rather than relying on req.user from protectRoute)
 * so it works correctly as a global middleware applied before route-level auth.
 */

import jwt from 'jsonwebtoken';
import User from '../models/user.model.js';

// Routes that bypass the privacy policy check
const EXEMPT_ROUTES = [
    '/api/privacy-policy/accept',
    '/api/privacy-policy/status',
    '/logout',
];

/**
 * Check if a request path is exempt from privacy policy enforcement.
 * @param {string} path - The request path
 * @returns {boolean}
 */
const isExemptRoute = (path) => {
    // Exact match for specific exempt routes
    if (EXEMPT_ROUTES.includes(path)) return true;

    // Wildcard match for all auth routes (/api/auth/*)
    if (path.startsWith('/api/auth/') || path === '/api/auth') return true;

    return false;
};

/**
 * Middleware that enforces privacy policy acceptance for authenticated users.
 * Decodes the JWT cookie directly so it works as global middleware before protectRoute.
 */
export const requirePrivacyPolicy = async (req, res, next) => {
    try {
        // Skip check for exempt routes
        if (isExemptRoute(req.path)) {
            return next();
        }

        // Try to get the JWT token from cookies
        const token = req.cookies?.jwt;
        if (!token) {
            // No token = unauthenticated, let downstream auth middleware handle it
            return next();
        }

        // Decode the token to get the user ID
        let decoded;
        try {
            decoded = jwt.verify(token, process.env.JWT_SECRET);
        } catch {
            // Invalid token — let downstream auth middleware handle it
            return next();
        }

        if (!decoded?.id) {
            return next();
        }

        // Look up only the privacy policy field (minimal DB query)
        const user = await User.findById(decoded.id).select('privacyPolicyAccepted').lean();

        if (!user) {
            return next();
        }

        // Block if user hasn't accepted the privacy policy
        if (!user.privacyPolicyAccepted) {
            return res.status(403).json({
                error: 'Privacy policy acceptance required',
                requiresPrivacyPolicy: true,
            });
        }

        return next();
    } catch (error) {
        console.error('Error in requirePrivacyPolicy middleware:', error);
        return res.status(500).json({ message: 'Internal server error' });
    }
};
