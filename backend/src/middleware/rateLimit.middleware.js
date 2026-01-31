import rateLimit from "express-rate-limit";

// Rate limiter for authentication routes (login, signup, google auth)
// Stricter limits to prevent brute force attacks
export const authRateLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 10, // 10 requests per window per IP
    message: {
        message: "Too many authentication attempts. Please try again after 15 minutes.",
    },
    standardHeaders: true, // Return rate limit info in headers
    legacyHeaders: false, // Disable X-RateLimit-* headers
    // Trust proxy for accurate IP detection (e.g., behind nginx, cloudflare)
    // Set to true in production if behind a reverse proxy
    skipSuccessfulRequests: false, // Count all requests
});

// General rate limiter for API routes
export const generalRateLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // 100 requests per window per IP
    message: {
        message: "Too many requests. Please try again later.",
    },
    standardHeaders: true,
    legacyHeaders: false,
});

// Strict rate limiter for password reset or sensitive operations
export const strictRateLimiter = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    max: 5, // 5 requests per hour per IP
    message: {
        message: "Too many attempts. Please try again after an hour.",
    },
    standardHeaders: true,
    legacyHeaders: false,
});
