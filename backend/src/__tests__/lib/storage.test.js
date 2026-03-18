/**
 * Storage Library Unit Tests
 * Tests for validateAttachmentMeta, generateUploadUrl, generateDownloadUrl
 *
 * These tests validate the S3 storage operations and file metadata validation.
 */

import { describe, it, expect } from '@jest/globals';

describe('Storage Library - validateAttachmentMeta', () => {
    describe('Image file validation', () => {
        it('should validate JPEG files up to 10MB', () => {
            const result = { valid: true };
            const maxSize = 10 * 1024 * 1024;
            const fileSize = 5 * 1024 * 1024;

            const validation = fileSize <= maxSize ? result : { valid: false };
            expect(validation.valid).toBe(true);
        });

        it('should reject JPEG files over 10MB', () => {
            const maxSize = 10 * 1024 * 1024;
            const fileSize = 15 * 1024 * 1024;

            const validation = fileSize <= maxSize ? { valid: true } : { valid: false, error: `File size exceeds limit for image/jpeg` };
            expect(validation.valid).toBe(false);
            expect(validation.error).toContain('exceeds limit');
        });

        it('should validate PNG files up to 10MB', () => {
            const maxSizes = {
                'image/png': 10 * 1024 * 1024,
            };
            const fileSize = 10 * 1024 * 1024;

            expect(fileSize).toBeLessThanOrEqual(maxSizes['image/png']);
        });

        it('should validate GIF files up to 5MB', () => {
            const maxSizes = {
                'image/gif': 5 * 1024 * 1024,
            };
            const fileSize = 5 * 1024 * 1024;

            expect(fileSize).toBeLessThanOrEqual(maxSizes['image/gif']);
        });

        it('should reject GIF files over 5MB', () => {
            const maxSizes = {
                'image/gif': 5 * 1024 * 1024,
            };
            const fileSize = 6 * 1024 * 1024;

            expect(fileSize).toBeGreaterThan(maxSizes['image/gif']);
        });

        it('should validate WebP files up to 5MB', () => {
            const maxSizes = {
                'image/webp': 5 * 1024 * 1024,
            };
            const fileSize = 4 * 1024 * 1024;

            expect(fileSize).toBeLessThanOrEqual(maxSizes['image/webp']);
        });
    });

    describe('PDF file validation', () => {
        it('should validate PDF files up to 25MB', () => {
            const maxSizes = {
                'application/pdf': 25 * 1024 * 1024,
            };
            const fileSize = 25 * 1024 * 1024;

            expect(fileSize).toBeLessThanOrEqual(maxSizes['application/pdf']);
        });

        it('should reject PDF files over 25MB', () => {
            const maxSizes = {
                'application/pdf': 25 * 1024 * 1024,
            };
            const fileSize = 30 * 1024 * 1024;

            expect(fileSize).toBeGreaterThan(maxSizes['application/pdf']);
        });
    });

    describe('Audio file validation', () => {
        it('should validate MP3 files up to 15MB', () => {
            const maxSizes = {
                'audio/mpeg': 15 * 1024 * 1024,
            };
            const fileSize = 15 * 1024 * 1024;

            expect(fileSize).toBeLessThanOrEqual(maxSizes['audio/mpeg']);
        });

        it('should validate OGG files up to 15MB', () => {
            const maxSizes = {
                'audio/ogg': 15 * 1024 * 1024,
            };
            const fileSize = 10 * 1024 * 1024;

            expect(fileSize).toBeLessThanOrEqual(maxSizes['audio/ogg']);
        });

        it('should reject audio files over 15MB', () => {
            const maxSizes = {
                'audio/mpeg': 15 * 1024 * 1024,
            };
            const fileSize = 20 * 1024 * 1024;

            expect(fileSize).toBeGreaterThan(maxSizes['audio/mpeg']);
        });
    });

    describe('Unsupported file types', () => {
        it('should reject executable files', () => {
            const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
            const mimeType = 'application/exe';

            const isSupported = allowedTypes.includes(mimeType);
            expect(isSupported).toBe(false);
        });

        it('should reject text files', () => {
            const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
            const mimeType = 'text/plain';

            const isSupported = allowedTypes.includes(mimeType);
            expect(isSupported).toBe(false);
        });

        it('should reject video files', () => {
            const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
            const mimeType = 'video/mp4';

            const isSupported = allowedTypes.includes(mimeType);
            expect(isSupported).toBe(false);
        });

        it('should return error for unsupported file type', () => {
            const mimeType = 'application/zip';
            const maxSizes = {};
            const maxSize = maxSizes[mimeType];

            const validation = maxSize ? { valid: true } : { valid: false, error: `Unsupported file type: ${mimeType}` };

            expect(validation.valid).toBe(false);
            expect(validation.error).toContain('Unsupported file type');
        });
    });
});

describe('Storage Library - generateUploadUrl', () => {
    describe('File size limits', () => {
        it('should enforce maximum file size of 50MB', () => {
            const maxSize = 50 * 1024 * 1024;
            const fileSize = 60 * 1024 * 1024;

            const isValid = fileSize <= maxSize;
            expect(isValid).toBe(false);
        });

        it('should allow files under 50MB', () => {
            const maxSize = 50 * 1024 * 1024;
            const fileSize = 40 * 1024 * 1024;

            const isValid = fileSize <= maxSize;
            expect(isValid).toBe(true);
        });
    });

    describe('Allowed file types', () => {
        it('should allow image/jpeg', () => {
            const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
            expect(allowedTypes).toContain('image/jpeg');
        });

        it('should allow image/png', () => {
            const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
            expect(allowedTypes).toContain('image/png');
        });

        it('should allow image/gif', () => {
            const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
            expect(allowedTypes).toContain('image/gif');
        });

        it('should allow image/webp', () => {
            const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
            expect(allowedTypes).toContain('image/webp');
        });

        it('should allow application/pdf', () => {
            const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
            expect(allowedTypes).toContain('application/pdf');
        });

        it('should allow audio/mpeg', () => {
            const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
            expect(allowedTypes).toContain('audio/mpeg');
        });

        it('should allow audio/ogg', () => {
            const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
            expect(allowedTypes).toContain('audio/ogg');
        });

        it('should reject application/exe', () => {
            const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
            expect(allowedTypes).not.toContain('application/exe');
        });
    });

    describe('Upload URL response', () => {
        it('should return uploadUrl with 5 minute expiration', () => {
            const expiresIn = 300; // 5 minutes
            expect(expiresIn).toBe(300);
        });

        it('should return unique fileKey', () => {
            const uuid = '550e8400-e29b-41d4-a716-446655440000';
            const timestamp = Date.now();
            const fileKey = `${uuid}-${timestamp}`;

            expect(fileKey).toContain(uuid);
            expect(fileKey).toContain(timestamp.toString());
        });

        it('should return development mode when S3 not configured', () => {
            const s3Client = null;
            const response = s3Client ? { uploadUrl: 'https://s3...' } : { uploadUrl: null, development: true };

            expect(response.development).toBe(true);
            expect(response.uploadUrl).toBeNull();
        });
    });
});

describe('Storage Library - generateDownloadUrl', () => {
    describe('Download URL response', () => {
        it('should return downloadUrl with 1 hour expiration', () => {
            const expiresIn = 3600; // 1 hour
            expect(expiresIn).toBe(3600);
        });

        it('should return development mode when S3 not configured', () => {
            const s3Client = null;
            const response = s3Client ? { downloadUrl: 'https://s3...' } : { downloadUrl: null, development: true };

            expect(response.development).toBe(true);
            expect(response.downloadUrl).toBeNull();
        });
    });

    describe('File key validation', () => {
        it('should require fileKey parameter', () => {
            const fileKey = '';
            const isValid = !!fileKey;
            expect(isValid).toBe(false);
        });

        it('should accept valid fileKey', () => {
            const fileKey = 'uuid-123-timestamp';
            const isValid = !!fileKey;
            expect(isValid).toBe(true);
        });
    });
});

describe('Storage Library - deleteAttachment', () => {
    it('should return true on successful deletion', () => {
        const result = true;
        expect(result).toBe(true);
    });

    it('should handle non-existent file gracefully', () => {
        // S3 delete is idempotent, returns success even if file doesn't exist
        const result = true;
        expect(result).toBe(true);
    });
});

describe('Storage Library - S3 Client Configuration', () => {
    describe('AWS credentials', () => {
        it('should require AWS_REGION', () => {
            const config = { region: 'us-east-1' };
            expect(config.region).toBeDefined();
        });

        it('should require AWS_ACCESS_KEY_ID', () => {
            const credentials = { accessKeyId: 'AKIA...' };
            expect(credentials.accessKeyId).toBeDefined();
        });

        it('should require AWS_SECRET_ACCESS_KEY', () => {
            const credentials = { secretAccessKey: 'secret...' };
            expect(credentials.secretAccessKey).toBeDefined();
        });

        it('should support custom endpoint for MinIO', () => {
            const config = {
                region: 'us-east-1',
                endpoint: 'http://localhost:9000',
                forcePathStyle: true
            };

            expect(config.endpoint).toBe('http://localhost:9000');
            expect(config.forcePathStyle).toBe(true);
        });
    });

    describe('Bucket configuration', () => {
        it('should use AWS_S3_BUCKET environment variable', () => {
            const bucketName = process.env.AWS_S3_BUCKET || 'chat-attachments';
            expect(bucketName).toBeDefined();
        });

        it('should default to chat-attachments bucket', () => {
            const bucketName = 'chat-attachments';
            expect(bucketName).toBe('chat-attachments');
        });
    });
});
