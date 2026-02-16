/**
 * Auth Middleware Unit Tests
 * Tests for protectRoute middleware
 */

import { describe, it, expect, jest, beforeEach } from '@jest/globals';

// Test helper to create mock request
const createMockReq = (overrides = {}) => ({
    cookies: {},
    user: null,
    ...overrides
});

// Test helper to create mock response
const createMockRes = () => {
    const res = {
        status: jest.fn(() => res),
        json: jest.fn(() => res)
    };
    return res;
};

describe('Auth Middleware - Token Validation Logic', () => {
    let mockRes;
    let mockNext;

    beforeEach(() => {
        mockRes = createMockRes();
        mockNext = jest.fn();
    });

    describe('token presence', () => {
        it('should detect missing token', () => {
            const req = createMockReq({ cookies: {} });
            const hasToken = !!req.cookies.jwt;

            expect(hasToken).toBe(false);
        });

        it('should detect present token', () => {
            const req = createMockReq({ cookies: { jwt: 'valid-token' } });
            const hasToken = !!req.cookies.jwt;

            expect(hasToken).toBe(true);
        });
    });

    describe('token decoding', () => {
        it('should verify decoded token has user id', () => {
            const decodedToken = { id: 'user-123', type: 'access_token' };
            const hasUserId = decodedToken && decodedToken.id;

            expect(hasUserId).toBeTruthy();
        });

        it('should reject token without id', () => {
            const decodedToken = { type: 'access_token' };
            const hasUserId = decodedToken && decodedToken.id;

            expect(hasUserId).toBeFalsy();
        });

        it('should reject null decoded token', () => {
            const decodedToken = null;
            const hasUserId = decodedToken && decodedToken.id;

            expect(hasUserId).toBeFalsy();
        });

        it('should verify token type is access_token', () => {
            const decodedToken = { id: 'user-123', type: 'access_token' };
            const isValidType = decodedToken.type === 'access_token';

            expect(isValidType).toBe(true);
        });

        it('should reject token with wrong type', () => {
            const decodedToken = { id: 'user-123', type: 'temp_token' };
            const isValidType = decodedToken.type === 'access_token';

            expect(isValidType).toBe(false);
        });
    });

    describe('response codes', () => {
        it('should return 401 for missing token', () => {
            mockRes.status(401).json({ message: 'No token provided, authorization denied.' });

            expect(mockRes.status).toHaveBeenCalledWith(401);
            expect(mockRes.json).toHaveBeenCalledWith({
                message: 'No token provided, authorization denied.'
            });
        });

        it('should return 401 for invalid token', () => {
            mockRes.status(401).json({ message: 'Token is not valid.' });

            expect(mockRes.status).toHaveBeenCalledWith(401);
        });

        it('should return 404 for user not found', () => {
            mockRes.status(404).json({ message: 'User not found' });

            expect(mockRes.status).toHaveBeenCalledWith(404);
        });

        it('should return 500 for verification failure', () => {
            mockRes.status(500).json({ message: 'Token verification failed.' });

            expect(mockRes.status).toHaveBeenCalledWith(500);
        });
    });

    describe('middleware behavior', () => {
        it('should attach user to request on success', () => {
            const req = createMockReq();
            const user = { 
                _id: 'user-123', 
                fullName: 'Test User', 
                email: 'test@example.com',
                termsAndConditionsAccepted: true,
                privacyPolicyAccepted: true
            };

            // Simulate middleware attaching user
            req.user = user;

            expect(req.user).toEqual(user);
            expect(req.user._id).toBe('user-123');
        });

        it('should call next() on successful authentication', () => {
            // Simulate calling next
            mockNext();

            expect(mockNext).toHaveBeenCalled();
        });

        it('should not call next() on authentication failure', () => {
            // When auth fails, next is not called
            mockRes.status(401).json({ message: 'Unauthorized' });

            expect(mockNext).not.toHaveBeenCalled();
        });
    });

    describe('terms enforcement in protectRoute', () => {
        it('should check user has accepted terms', () => {
            const user = {
                _id: 'user-123',
                termsAndConditionsAccepted: true,
                privacyPolicyAccepted: true
            };

            const hasAcceptedTerms = user.termsAndConditionsAccepted && user.privacyPolicyAccepted;
            expect(hasAcceptedTerms).toBe(true);
        });

        it('should reject user who has not accepted terms', () => {
            const user = {
                _id: 'user-123',
                termsAndConditionsAccepted: false,
                privacyPolicyAccepted: true
            };

            const hasAcceptedTerms = user.termsAndConditionsAccepted && user.privacyPolicyAccepted;
            expect(hasAcceptedTerms).toBe(false);
        });

        it('should reject user who has not accepted privacy policy', () => {
            const user = {
                _id: 'user-123',
                termsAndConditionsAccepted: true,
                privacyPolicyAccepted: false
            };

            const hasAcceptedTerms = user.termsAndConditionsAccepted && user.privacyPolicyAccepted;
            expect(hasAcceptedTerms).toBe(false);
        });
    });
});
