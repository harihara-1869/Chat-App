import { S3Client, PutObjectCommand, GetObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { v4 as uuidv4 } from 'uuid';
import crypto from 'crypto';
import dotenv from 'dotenv';

dotenv.config();

let s3Client = null;

function getS3Client() {
  if (s3Client) return s3Client;

  const region = process.env.AWS_REGION;
  const endpoint = process.env.AWS_ENDPOINT;
  const accessKeyId = process.env.AWS_ACCESS_KEY_ID;
  const secretAccessKey = process.env.AWS_SECRET_ACCESS_KEY;

  if (!region || !accessKeyId || !secretAccessKey) {
    console.warn('AWS credentials not configured. Using in-memory storage for development.');
    return null;
  }

  const config = {
    region,
    credentials: {
      accessKeyId,
      secretAccessKey,
    },
  };

  if (endpoint) {
    config.endpoint = endpoint;
    config.forcePathStyle = true;
  }

  s3Client = new S3Client(config);
  return s3Client;
}

const BUCKET_NAME = process.env.AWS_S3_BUCKET || 'chat-attachments';

/**
 * Virus/Malware Scanner Interface
 * 
 * This is a pluggable interface for virus scanning uploaded files.
 * Implement one of the following options based on your infrastructure:
 * 
 * Option 1: ClamAV (via TCP socket)
 * Option 2: VirusTotal API
 * Option 3: AWS Macie / S3 scanning
 * Option 4: Custom scanning service
 */
class VirusScanner {
  constructor(options = {}) {
    this.type = options.type || 'none'; // 'clamav', 'virustotal', 'aws', 'none'
    this.endpoint = options.endpoint;
    this.apiKey = options.apiKey;
  }

  /**
   * Scan file buffer for malware
   * @param {Buffer} buffer - File content to scan
   * @param {string} filename - Original filename for logging
   * @returns {Promise<{clean: boolean, threat?: string}>}
   */
  async scan(buffer, filename) {
    switch (this.type) {
      case 'clamav':
        return this._scanWithClamAV(buffer, filename);
      case 'virustotal':
        return this._scanWithVirusTotal(buffer, filename);
      case 'aws':
        return this._scanWithAWS(buffer, filename);
      case 'none':
      default:
        // No scanning in development mode
        console.warn('Virus scanning disabled - running in no-scan mode');
        return { clean: true };
    }
  }

  async _scanWithClamAV(buffer, filename) {
    // ClamAV scanner implementation
    // Requires: npm install clamav.js or similar
    // 
    // Example with clamd (TCP):
    // const clamd = require('clamd');
    // const scanner = clamd.createScanner('localhost', 3310);
    // const result = await scanner.scanStream(buffer);
    // return { clean: result !== 'FOUND', threat: result === 'FOUND' ? 'Malware detected' : undefined };

    console.warn('ClamAV scanning not implemented - configure endpoint');
    return { clean: true };
  }

  async _scanWithVirusTotal(buffer, filename) {
    // VirusTotal API implementation
    // Requires: VIRUSTOTAL_API_KEY in environment
    //
    // const FormData = require('form-data');
    // const fetch = require('node-fetch');
    // const form = new FormData();
    // form.append('file', buffer, filename);
    // 
    // const response = await fetch('https://www.virustotal.com/api/v3/files', {
    //   method: 'POST',
    //   headers: { 'x-apikey': this.apiKey },
    //   body: form
    // });
    // const result = await response.json();
    // const maliciousCount = result.data?.attributes?.last_analysis_stats?.malicious || 0;
    // return { 
    //   clean: maliciousCount === 0, 
    //   threat: maliciousCount > 0 ? `Detected by ${maliciousCount} engines` : undefined 
    // };

    console.warn('VirusTotal scanning not configured - add VIRUSTOTAL_API_KEY');
    return { clean: true };
  }

  async _scanWithAWS(buffer, filename) {
    // AWS S3 with Macie or GuardDuty integration
    // S3 automatically scans with Amazon Macie for sensitive data
    // For malware scanning, use S3 Antivirus or custom Lambda
    //
    // Option A: S3 Intelligent-Tiering with Macie
    // Option B: Lambda-triggered scanning on upload
    // Option C: S3 Antivirus partner integration

    console.warn('AWS malware scanning not configured');
    return { clean: true };
  }
}

// Initialize scanner based on environment
const virusScanner = new VirusScanner({
  type: process.env.VIRUS_SCANNER_TYPE || 'none',
  endpoint: process.env.CLAMAV_ENDPOINT,
  apiKey: process.env.VIRUSTOTAL_API_KEY,
});

/**
 * Scan a file buffer for malware before storage
 * @param {Buffer} buffer - File content to scan
 * @param {string} filename - Original filename
 * @throws {Error} If malware is detected
 */
export async function scanForMalware(buffer, filename) {
  try {
    const result = await virusScanner.scan(buffer, filename);

    if (!result.clean) {
      const error = new Error(`Malware detected in file ${filename}: ${result.threat}`);
      error.code = 'MALWARE_DETECTED';
      throw error;
    }

    return true;
  } catch (error) {
    if (error.code === 'MALWARE_DETECTED') {
      throw error;
    }
    // Log scanning errors but don't block upload - fail open for availability
    // In high-security environments, you might want to fail closed instead
    console.error('Virus scanning error:', error.message);
    return true;
  }
}

export async function generateUploadUrl(fileType, fileSize) {
  const client = getS3Client();
  const fileKey = `${uuidv4()}-${Date.now()}`;

  const maxSize = 50 * 1024 * 1024; // 50MB
  if (fileSize > maxSize) {
    throw new Error(`File size exceeds maximum allowed size of ${maxSize} bytes`);
  }

  const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf', 'audio/mpeg', 'audio/ogg'];
  if (!allowedTypes.includes(fileType)) {
    throw new Error(`File type ${fileType} is not allowed`);
  }

  if (client) {
    const command = new PutObjectCommand({
      Bucket: BUCKET_NAME,
      Key: fileKey,
      ContentType: fileType,
    });

    const uploadUrl = await getSignedUrl(client, command, { expiresIn: 300 });

    return {
      uploadUrl,
      fileKey,
      expiresIn: 300,
    };
  } else {
    return {
      fileKey,
      uploadUrl: null,
      expiresIn: 0,
      development: true,
    };
  }
}

export async function generateDownloadUrl(fileKey) {
  const client = getS3Client();

  if (client) {
    const command = new GetObjectCommand({
      Bucket: BUCKET_NAME,
      Key: fileKey,
    });

    const downloadUrl = await getSignedUrl(client, command, { expiresIn: 3600 });

    return {
      downloadUrl,
      expiresIn: 3600,
    };
  } else {
    return {
      downloadUrl: null,
      expiresIn: 0,
      development: true,
    };
  }
}

export async function deleteAttachment(fileKey) {
  const client = getS3Client();

  if (client) {
    const command = new DeleteObjectCommand({
      Bucket: BUCKET_NAME,
      Key: fileKey,
    });

    await client.send(command);
    return true;
  }

  return true;
}

export function validateAttachmentMeta(mimeType, size) {
  const maxSizes = {
    'image/jpeg': 10 * 1024 * 1024,
    'image/png': 10 * 1024 * 1024,
    'image/gif': 5 * 1024 * 1024,
    'image/webp': 5 * 1024 * 1024,
    'application/pdf': 25 * 1024 * 1024,
    'audio/mpeg': 15 * 1024 * 1024,
    'audio/ogg': 15 * 1024 * 1024,
  };

  const maxSize = maxSizes[mimeType];
  if (!maxSize) {
    return { valid: false, error: `Unsupported file type: ${mimeType}` };
  }

  if (size > maxSize) {
    return { valid: false, error: `File size exceeds limit for ${mimeType}` };
  }

  return { valid: true };
}
