/**
 * requirePrivacyPolicy Middleware Unit Tests
 * Tests the JWT-decoding, DB-querying privacy policy enforcement middleware.
 *
 * Uses file:// URLs for jest.unstable_mockModule to work around
 * Jest ESM path resolution issues with setupFilesAfterEnv.
 */

import { describe, it, expect, jest, beforeEach, beforeAll } from '@jest/globals';
import { pathToFileURL } from 'url';
import { resolve } from 'path';

// --- Mocks ---
const mockVerify = jest.fn();
const mockFindById = jest.fn();

// Get absolute file:// URLs for the modules we need to mock
const projectRoot = resolve('.');
const userModelUrl = pathToFileURL(resolve(projectRoot, 'src/models/user.model.js')).href;
const middlewareUrl = pathToFileURL(resolve(projectRoot, 'src/middleware/requirePrivacyPolicy.js')).href;

// Mock jsonwebtoken (node_modules — use package name)
jest.unstable_mockModule('jsonwebtoken', () => ({
    default: { verify: mockVerify },
}));

// Mock User model (use file:// URL)
jest.unstable_mockModule(userModelUrl, () => ({
    default: { findById: mockFindById },
}));

// Dynamic import after mocking
let requirePrivacyPolicy;
beforeAll(async () => {
    const mod = await import(middlewareUrl);
    requirePrivacyPolicy = mod.requirePrivacyPolicy;
});

// Test helpers
const createMockReq = (overrides = {}) => ({
    path: '/api/message/send',
    cookies: {},
    ...overrides,
});

const createMockRes = () => {
    const res = {
        status: jest.fn(() => res),
        json: jest.fn(() => res),
    };
    return res;
};

describe('requirePrivacyPolicy Middleware', () => {
    let mockRes;
    let mockNext;

    beforeEach(() => {
        mockRes = createMockRes();
        mockNext = jest.fn();
        mockVerify.mockReset();
        mockFindById.mockReset();
    });

    describe('exempt routes', () => {
        const exemptPaths = [
            '/api/privacy-policy/accept',
            '/api/privacy-policy/status',
            '/api/auth/login',
            '/api/auth/signup',
            '/api/auth/google',
            '/api/auth/google/callback',
            '/api/auth',
            '/logout',
        ];

        exemptPaths.forEach((path) => {
            it(`should call next() for exempt route: ${path}`, async () => {
                const req = createMockReq({ path, cookies: { jwt: 'some-token' } });

                await requirePrivacyPolicy(req, mockRes, mockNext);

                expect(mockNext).toHaveBeenCalled();
                expect(mockRes.status).not.toHaveBeenCalled();
            });
        });
    });

    describe('unauthenticated requests', () => {
        it('should call next() when no JWT cookie exists', async () => {
            const req = createMockReq({ cookies: {} });

            await requirePrivacyPolicy(req, mockRes, mockNext);

            expect(mockNext).toHaveBeenCalled();
            expect(mockRes.status).not.toHaveBeenCalled();
        });

        it('should call next() when JWT is invalid', async () => {
            const req = createMockReq({ cookies: { jwt: 'invalid-token' } });
            mockVerify.mockImplementation(() => { throw new Error('invalid'); });

            await requirePrivacyPolicy(req, mockRes, mockNext);

            expect(mockNext).toHaveBeenCalled();
            expect(mockRes.status).not.toHaveBeenCalled();
        });

        it('should call next() when decoded token has no id', async () => {
            const req = createMockReq({ cookies: { jwt: 'some-token' } });
            mockVerify.mockReturnValue({});

            await requirePrivacyPolicy(req, mockRes, mockNext);

            expect(mockNext).toHaveBeenCalled();
        });

        it('should call next() when user not found in DB', async () => {
            const req = createMockReq({ cookies: { jwt: 'some-token' } });
            mockVerify.mockReturnValue({ id: 'user-123' });
            mockFindById.mockReturnValue({
                select: jest.fn().mockReturnValue({
                    lean: jest.fn().mockResolvedValue(null),
                }),
            });

            await requirePrivacyPolicy(req, mockRes, mockNext);

            expect(mockNext).toHaveBeenCalled();
        });
    });

    describe('privacy policy not accepted', () => {
        it('should return 403 when user has not accepted privacy policy', async () => {
            const req = createMockReq({ cookies: { jwt: 'valid-token' } });
            mockVerify.mockReturnValue({ id: 'user-123' });
            mockFindById.mockReturnValue({
                select: jest.fn().mockReturnValue({
                    lean: jest.fn().mockResolvedValue({ _id: 'user-123', privacyPolicyAccepted: false }),
                }),
            });

            await requirePrivacyPolicy(req, mockRes, mockNext);

            expect(mockNext).not.toHaveBeenCalled();
            expect(mockRes.status).toHaveBeenCalledWith(403);
            expect(mockRes.json).toHaveBeenCalledWith({
                error: 'Privacy policy acceptance required',
                requiresPrivacyPolicy: true,
            });
        });
    });

    describe('privacy policy accepted', () => {
        it('should call next() when user has accepted privacy policy', async () => {
            const req = createMockReq({ cookies: { jwt: 'valid-token' } });
            mockVerify.mockReturnValue({ id: 'user-123' });
            mockFindById.mockReturnValue({
                select: jest.fn().mockReturnValue({
                    lean: jest.fn().mockResolvedValue({ _id: 'user-123', privacyPolicyAccepted: true }),
                }),
            });

            await requirePrivacyPolicy(req, mockRes, mockNext);

            expect(mockNext).toHaveBeenCalled();
            expect(mockRes.status).not.toHaveBeenCalled();
        });
    });
});
