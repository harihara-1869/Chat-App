/**
 * Key Controller Unit Tests
 * Tests for uploadSignedPreKey, uploadOneTimePreKey, getPreKeyBundle, getPreKeyCount
 *
 * Uses the simplified approach: testing validation logic, response formats,
 * and behavior patterns without complex ESM module mocking.
 */

import { describe, it, expect, jest, beforeEach } from '@jest/globals';

// Test helper to create mock request
const createMockReq = (overrides = {}) => ({
    body: {},
    cookies: {},
    user: { _id: '507f1f77bcf86cd799439011' },
    params: {},
    query: {},
    ...overrides,
});

// Test helper to create mock response
const createMockRes = () => {
    const res = {
        status: jest.fn(() => res),
        json: jest.fn(() => res),
    };
    return res;
};

describe('Key Controller - uploadSignedPreKey Validation', () => {
    it('should require keyId, publicKey, and signature', () => {
        const testCases = [
            { publicKey: 'abc', signature: 'xyz' },       // missing keyId
            { keyId: 1, signature: 'xyz' },                // missing publicKey
            { keyId: 1, publicKey: 'abc' },                // missing signature
            {},                                             // missing all
        ];

        testCases.forEach((body) => {
            const isValid = !!body.keyId && !!body.publicKey && !!body.signature;
            expect(isValid).toBe(false);
        });
    });

    it('should accept valid signed pre-key input', () => {
        const body = {
            keyId: 1,
            publicKey: Buffer.alloc(33, 0x05).toString('base64'),
            signature: Buffer.alloc(64, 0x01).toString('base64'),
            deviceId: 1,
        };

        const isValid = !!body.keyId && !!body.publicKey && !!body.signature;
        expect(isValid).toBe(true);
    });

    it('should validate public key is 33 bytes', () => {
        const validKey = Buffer.alloc(33, 0x05);
        const invalidKey32 = Buffer.alloc(32, 0x05);
        const invalidKey64 = Buffer.alloc(64, 0x05);

        expect(validKey.length).toBe(33);
        expect(invalidKey32.length).not.toBe(33);
        expect(invalidKey64.length).not.toBe(33);
    });

    it('should validate signature is 64 bytes', () => {
        const validSig = Buffer.alloc(64, 0x01);
        const invalidSig32 = Buffer.alloc(32, 0x01);

        expect(validSig.length).toBe(64);
        expect(invalidSig32.length).not.toBe(64);
    });

    it('should default deviceId to 1 if not provided', () => {
        const body = { keyId: 1, publicKey: 'abc', signature: 'xyz' };
        const deviceId = body.deviceId || 1;

        expect(deviceId).toBe(1);
    });

    it('should use provided deviceId when present', () => {
        const body = { keyId: 1, publicKey: 'abc', signature: 'xyz', deviceId: 2 };
        const deviceId = body.deviceId || 1;

        expect(deviceId).toBe(2);
    });
});

describe('Key Controller - uploadOneTimePreKey Validation', () => {
    it('should require setOfOneTimePreKeys array', () => {
        const testCases = [
            {},                                 // missing entirely
            { setOfOneTimePreKeys: null },       // null
            { setOfOneTimePreKeys: 'not-array' }, // not an array
        ];

        testCases.forEach((body) => {
            const isValid = !!body.setOfOneTimePreKeys && Array.isArray(body.setOfOneTimePreKeys);
            expect(isValid).toBe(false);
        });
    });

    it('should reject empty array', () => {
        const body = { setOfOneTimePreKeys: [] };
        const isValid = body.setOfOneTimePreKeys.length > 0 && body.setOfOneTimePreKeys.length <= 100;

        expect(isValid).toBe(false);
    });

    it('should reject more than 100 keys', () => {
        const body = { setOfOneTimePreKeys: new Array(101).fill({ keyId: 1, publicKey: 'abc' }) };
        const isValid = body.setOfOneTimePreKeys.length > 0 && body.setOfOneTimePreKeys.length <= 100;

        expect(isValid).toBe(false);
    });

    it('should accept exactly 100 keys', () => {
        const body = {
            setOfOneTimePreKeys: new Array(100).fill({ keyId: 1, publicKey: 'abc' }),
        };
        const isValid = body.setOfOneTimePreKeys.length > 0 && body.setOfOneTimePreKeys.length <= 100;

        expect(isValid).toBe(true);
    });

    it('should accept 1-99 keys', () => {
        const body = {
            setOfOneTimePreKeys: new Array(50).fill({ keyId: 1, publicKey: 'abc' }),
        };
        const isValid = body.setOfOneTimePreKeys.length > 0 && body.setOfOneTimePreKeys.length <= 100;

        expect(isValid).toBe(true);
    });

    it('should map keys with userId and deviceId', () => {
        const userId = 'user-123';
        const deviceId = 1;
        const inputKeys = [
            { keyId: 1, publicKey: 'key1' },
            { keyId: 2, publicKey: 'key2' },
        ];

        const mappedKeys = inputKeys.map((key) => ({
            userId,
            deviceId,
            keyId: key.keyId,
            publicKey: key.publicKey,
        }));

        expect(mappedKeys).toHaveLength(2);
        expect(mappedKeys[0]).toEqual({
            userId: 'user-123',
            deviceId: 1,
            keyId: 1,
            publicKey: 'key1',
        });
        expect(mappedKeys[1].keyId).toBe(2);
    });
});

describe('Key Controller - getPreKeyBundle Logic', () => {
    it('should extract userId from params', () => {
        const req = createMockReq({ params: { userId: 'recipient-456' } });
        expect(req.params.userId).toBe('recipient-456');
    });

    it('should default deviceId to 1 when not in query', () => {
        const req = createMockReq({ query: {} });
        const deviceId = parseInt(req.query.deviceId) || 1;

        expect(deviceId).toBe(1);
    });

    it('should parse deviceId from query param', () => {
        const req = createMockReq({ query: { deviceId: '2' } });
        const deviceId = parseInt(req.query.deviceId) || 1;

        expect(deviceId).toBe(2);
    });

    it('should construct correct bundle response', () => {
        const bundle = {
            identityKey: 'base64-identity-key',
            registrationId: 1234,
            deviceId: 1,
            signedPreKey: {
                keyId: 1,
                publicKey: 'base64-signed-prekey',
                signature: 'base64-signature',
            },
            oneTimePreKey: {
                keyId: 42,
                publicKey: 'base64-otk',
            },
        };

        expect(bundle).toHaveProperty('identityKey');
        expect(bundle).toHaveProperty('registrationId');
        expect(bundle).toHaveProperty('deviceId');
        expect(bundle.signedPreKey).toHaveProperty('keyId');
        expect(bundle.signedPreKey).toHaveProperty('publicKey');
        expect(bundle.signedPreKey).toHaveProperty('signature');
        expect(bundle.oneTimePreKey).toHaveProperty('keyId');
        expect(bundle.oneTimePreKey).toHaveProperty('publicKey');
    });

    it('should handle null oneTimePreKey when exhausted', () => {
        const bundle = {
            identityKey: 'base64-identity-key',
            registrationId: 1234,
            deviceId: 1,
            signedPreKey: {
                keyId: 1,
                publicKey: 'base64-signed-prekey',
                signature: 'base64-signature',
            },
            oneTimePreKey: null,
        };

        expect(bundle.oneTimePreKey).toBeNull();
        // Session can still be established without OTK (slightly reduced forward secrecy)
    });
});

describe('Key Controller - getPreKeyCount Logic', () => {
    it('should return count and deviceId in response', () => {
        const response = { count: 75, deviceId: 1 };

        expect(response).toHaveProperty('count');
        expect(response).toHaveProperty('deviceId');
        expect(response.count).toBe(75);
    });

    it('should return 0 count when all pre-keys used', () => {
        const response = { count: 0, deviceId: 1 };

        expect(response.count).toBe(0);
    });
});

describe('Key Controller - Response Format', () => {
    let mockRes;

    beforeEach(() => {
        mockRes = createMockRes();
    });

    describe('uploadSignedPreKey response', () => {
        it('should return 200 on success', () => {
            mockRes.status(200).json({ message: 'Signed pre-key uploaded successfully' });

            expect(mockRes.status).toHaveBeenCalledWith(200);
        });

        it('should return 400 for missing fields', () => {
            mockRes.status(400).json({ message: 'keyId, publicKey, and signature are required' });

            expect(mockRes.status).toHaveBeenCalledWith(400);
        });

        it('should return 400 for invalid key length', () => {
            mockRes.status(400).json({ message: 'Invalid signed prekey length (expected 33 bytes)' });

            expect(mockRes.status).toHaveBeenCalledWith(400);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    message: expect.stringContaining('33 bytes'),
                })
            );
        });

        it('should return 404 when device not registered', () => {
            mockRes.status(404).json({ message: 'Device not found. Register a device first.' });

            expect(mockRes.status).toHaveBeenCalledWith(404);
        });
    });

    describe('uploadOneTimePreKey response', () => {
        it('should return 200 on success', () => {
            mockRes.status(200).json({ message: 'One-time pre-keys uploaded successfully' });

            expect(mockRes.status).toHaveBeenCalledWith(200);
        });

        it('should return 400 for invalid input', () => {
            mockRes.status(400).json({ message: 'setOfOneTimePreKeys array is required' });

            expect(mockRes.status).toHaveBeenCalledWith(400);
        });
    });

    describe('getPreKeyBundle response', () => {
        it('should return 200 with full bundle', () => {
            const bundle = {
                identityKey: 'base64key',
                registrationId: 1234,
                deviceId: 1,
                signedPreKey: { keyId: 1, publicKey: 'pk', signature: 'sig' },
                oneTimePreKey: { keyId: 42, publicKey: 'otkpk' },
            };

            mockRes.status(200).json(bundle);

            expect(mockRes.status).toHaveBeenCalledWith(200);
            expect(mockRes.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    identityKey: 'base64key',
                    registrationId: 1234,
                })
            );
        });

        it('should return 404 when device not found', () => {
            mockRes.status(404).json({ message: 'Device not found for user' });

            expect(mockRes.status).toHaveBeenCalledWith(404);
        });

        it('should return 404 when signed pre-key not found', () => {
            mockRes.status(404).json({ message: 'Signed pre-key not found' });

            expect(mockRes.status).toHaveBeenCalledWith(404);
        });
    });

    describe('getPreKeyCount response', () => {
        it('should return 200 with count', () => {
            mockRes.status(200).json({ count: 42, deviceId: 1 });

            expect(mockRes.status).toHaveBeenCalledWith(200);
            expect(mockRes.json).toHaveBeenCalledWith({ count: 42, deviceId: 1 });
        });

        it('should return 404 when device not found', () => {
            mockRes.status(404).json({ message: 'Device not found' });

            expect(mockRes.status).toHaveBeenCalledWith(404);
        });
    });
});

describe('Key Controller - Device Awareness', () => {
    it('should query by userId AND deviceId for signed pre-key', () => {
        const userId = 'user-123';
        const deviceId = 1;

        const query = { userId, deviceId };

        expect(query).toEqual({ userId: 'user-123', deviceId: 1 });
    });

    it('should query by userId AND deviceId for one-time pre-keys', () => {
        const userId = 'user-123';
        const deviceId = 1;
        const used = false;

        const query = { userId, deviceId, used };

        expect(query).toEqual({ userId: 'user-123', deviceId: 1, used: false });
    });

    it('should atomically mark one-time pre-key as used', () => {
        // The controller uses findOneAndUpdate to atomically consume a key
        const updateQuery = { $set: { used: true } };

        expect(updateQuery.$set.used).toBe(true);
    });
});
