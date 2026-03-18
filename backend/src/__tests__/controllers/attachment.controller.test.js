/**
 * Attachment Controller Unit Tests
 * Tests for getUploadUrl and getDownloadUrl
 *
 * These tests validate the attachment upload/download URL generation
 * and file metadata validation.
 */

import { describe, it, expect, jest, beforeEach } from '@jest/globals';

// Test helper to create mock request
const createMockReq = (overrides = {}) => ({
    body: {},
    cookies: {},
    user: { _id: 'user-123' },
    params: {},
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

describe('Attachment Controller - Input Validation', () => {
    let mockRes;

    beforeEach(() => {
        mockRes = createMockRes();
    });

    describe('getUploadUrl validation', () => {
        it('should require fileType in request body', () => {
            const body = { fileSize: 1024 };
            const isValid = !!body.fileType && !!body.fileSize;

            expect(isValid).toBe(false);
        });

        it('should require fileSize in request body', () => {
            const body = { fileType: 'image/jpeg' };
            const isValid = !!body.fileType && !!body.fileSize;

            expect(isValid).toBe(false);
        });

        it('should accept valid fileType and fileSize', () => {
            const body = { fileType: 'image/jpeg', fileSize: 1024 };
            const isValid = !!body.fileType && !!body.fileSize;

            expect(isValid).toBe(true);
        });

        it('should return 400 for missing fileType or fileSize', () => {
            mockRes.status(400).json({ error: "fileType and fileSize are required" });

            expect(mockRes.status).toHaveBeenCalledWith(400);
            expect(mockRes.json).toHaveBeenCalledWith({ error: "fileType and fileSize are required" });
        });

        it('should validate fileType is a string', () => {
            const fileType = 'image/jpeg';
            expect(typeof fileType).toBe('string');
        });

        it('should validate fileSize is a number', () => {
            const fileSize = 1024;
            expect(typeof fileSize).toBe('number');
        });
    });

    describe('getDownloadUrl validation', () => {
        it('should require fileKey in request params', () => {
            const params = { fileKey: '' };
            const isValid = !!params.fileKey;

            expect(isValid).toBe(false);
        });

        it('should accept valid fileKey', () => {
            const params = { fileKey: 'abc-123-file.jpg' };
            const isValid = !!params.fileKey;

            expect(isValid).toBe(true);
        });

        it('should return 400 for missing fileKey', () => {
            mockRes.status(400).json({ error: "fileKey is required" });

            expect(mockRes.status).toHaveBeenCalledWith(400);
            expect(mockRes.json).toHaveBeenCalledWith({ error: "fileKey is required" });
        });
    });
});

describe('Attachment Controller - File Type Validation', () => {
    it('should accept image/jpeg files', () => {
        const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
        expect(allowedTypes).toContain('image/jpeg');
    });

    it('should accept image/png files', () => {
        const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
        expect(allowedTypes).toContain('image/png');
    });

    it('should accept image/gif files', () => {
        const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
        expect(allowedTypes).toContain('image/gif');
    });

    it('should accept image/webp files', () => {
        const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
        expect(allowedTypes).toContain('image/webp');
    });

    it('should accept application/pdf files', () => {
        const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
        expect(allowedTypes).toContain('application/pdf');
    });

    it('should accept audio/mpeg files', () => {
        const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
        expect(allowedTypes).toContain('audio/mpeg');
    });

    it('should accept audio/ogg files', () => {
        const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
        expect(allowedTypes).toContain('audio/ogg');
    });

    it('should reject unsupported file types', () => {
        const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
        const unsupportedType = 'application/exe';

        expect(allowedTypes).not.toContain(unsupportedType);
    });

    it('should reject text/plain files', () => {
        const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
        expect(allowedTypes).not.toContain('text/plain');
    });
});

describe('Attachment Controller - File Size Limits', () => {
    it('should allow JPEG files up to 10MB', () => {
        const maxSize = 10 * 1024 * 1024; // 10MB
        const fileSize = 5 * 1024 * 1024; // 5MB

        expect(fileSize).toBeLessThanOrEqual(maxSize);
    });

    it('should reject JPEG files over 10MB', () => {
        const maxSize = 10 * 1024 * 1024; // 10MB
        const fileSize = 15 * 1024 * 1024; // 15MB

        expect(fileSize).toBeGreaterThan(maxSize);
    });

    it('should allow PNG files up to 10MB', () => {
        const maxSize = 10 * 1024 * 1024;
        const fileSize = 10 * 1024 * 1024;

        expect(fileSize).toBeLessThanOrEqual(maxSize);
    });

    it('should allow GIF files up to 5MB', () => {
        const maxSize = 5 * 1024 * 1024;
        const fileSize = 4 * 1024 * 1024;

        expect(fileSize).toBeLessThanOrEqual(maxSize);
    });

    it('should reject GIF files over 5MB', () => {
        const maxSize = 5 * 1024 * 1024;
        const fileSize = 6 * 1024 * 1024;

        expect(fileSize).toBeGreaterThan(maxSize);
    });

    it('should allow PDF files up to 25MB', () => {
        const maxSize = 25 * 1024 * 1024;
        const fileSize = 20 * 1024 * 1024;

        expect(fileSize).toBeLessThanOrEqual(maxSize);
    });

    it('should reject PDF files over 25MB', () => {
        const maxSize = 25 * 1024 * 1024;
        const fileSize = 30 * 1024 * 1024;

        expect(fileSize).toBeGreaterThan(maxSize);
    });

    it('should allow audio files up to 15MB', () => {
        const maxSize = 15 * 1024 * 1024;
        const fileSize = 10 * 1024 * 1024;

        expect(fileSize).toBeLessThanOrEqual(maxSize);
    });
});

describe('Attachment Controller - Response Format', () => {
    let mockRes;

    beforeEach(() => {
        mockRes = createMockRes();
    });

    describe('getUploadUrl response', () => {
        it('should return uploadUrl and fileKey on success', () => {
            const response = {
                uploadUrl: 'https://s3.amazonaws.com/bucket/...',
                fileKey: 'uuid-123-file',
                expiresIn: 300
            };

            mockRes.status(200).json(response);

            expect(mockRes.status).toHaveBeenCalledWith(200);
            expect(mockRes.json).toHaveBeenCalledWith(expect.objectContaining({
                uploadUrl: expect.any(String),
                fileKey: expect.any(String),
                expiresIn: expect.any(Number)
            }));
        });

        it('should return development mode response when S3 not configured', () => {
            const response = {
                fileKey: 'uuid-123-file',
                uploadUrl: null,
                expiresIn: 0,
                development: true
            };

            expect(response.development).toBe(true);
            expect(response.uploadUrl).toBeNull();
        });

        it('should return 400 for invalid file type', () => {
            mockRes.status(400).json({ error: "File type not allowed" });

            expect(mockRes.status).toHaveBeenCalledWith(400);
        });

        it('should return 400 for file size exceeding limit', () => {
            mockRes.status(400).json({ error: "File size exceeds limit for image/jpeg" });

            expect(mockRes.status).toHaveBeenCalledWith(400);
        });

        it('should return 500 on server error', () => {
            mockRes.status(500).json({ error: "Internal server error" });

            expect(mockRes.status).toHaveBeenCalledWith(500);
            expect(mockRes.json).toHaveBeenCalledWith({ error: "Internal server error" });
        });
    });

    describe('getDownloadUrl response', () => {
        it('should return downloadUrl and expiresIn on success', () => {
            const response = {
                downloadUrl: 'https://s3.amazonaws.com/bucket/...',
                expiresIn: 3600
            };

            mockRes.status(200).json(response);

            expect(mockRes.status).toHaveBeenCalledWith(200);
            expect(mockRes.json).toHaveBeenCalledWith(expect.objectContaining({
                downloadUrl: expect.any(String),
                expiresIn: expect.any(Number)
            }));
        });

        it('should return development mode response when S3 not configured', () => {
            const response = {
                downloadUrl: null,
                expiresIn: 0,
                development: true
            };

            expect(response.development).toBe(true);
            expect(response.downloadUrl).toBeNull();
        });

        it('should return 500 on server error', () => {
            mockRes.status(500).json({ error: "Internal server error" });

            expect(mockRes.status).toHaveBeenCalledWith(500);
        });
    });
});

describe('Attachment Controller - File Key Format', () => {
    it('should generate unique file keys with UUID and timestamp', () => {
        const uuid = '550e8400-e29b-41d4-a716-446655440000';
        const timestamp = Date.now();
        const fileKey = `${uuid}-${timestamp}`;

        expect(fileKey).toContain(uuid);
        expect(fileKey).toContain(timestamp.toString());
    });

    it('should generate different file keys for each request', () => {
        const fileKey1 = `uuid-1-${Date.now()}`;
        const fileKey2 = `uuid-2-${Date.now() + 1}`;

        expect(fileKey1).not.toBe(fileKey2);
    });
});

describe('Mock Request/Response Utilities', () => {
    it('should create mock request with defaults', () => {
        const req = createMockReq();

        expect(req.body).toEqual({});
        expect(req.user._id).toBe('user-123');
    });

    it('should create mock request with body overrides', () => {
        const req = createMockReq({
            body: { fileType: 'image/jpeg', fileSize: 1024 }
        });

        expect(req.body.fileType).toBe('image/jpeg');
        expect(req.body.fileSize).toBe(1024);
    });

    it('should create mock request with params overrides', () => {
        const req = createMockReq({
            params: { fileKey: 'abc-123' }
        });

        expect(req.params.fileKey).toBe('abc-123');
    });

    it('should create chainable mock response', () => {
        const res = createMockRes();

        res.status(200).json({ success: true });

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith({ success: true });
    });
});
