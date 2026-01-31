/**
 * Jest Test Setup for ES Modules
 * Configures mocks and environment for all tests
 */

import { jest } from '@jest/globals';

// Set test environment variables
process.env.JWT_SECRET = 'test-jwt-secret-key';
process.env.NODE_ENV = 'test';
process.env.CLOUDINARY_CLOUD_NAME = 'test-cloud';
process.env.CLOUDINARY_API_KEY = 'test-api-key';
process.env.CLOUDINARY_API_SECRET = 'test-api-secret';

// Make jest available globally for ESM
globalThis.jest = jest;
