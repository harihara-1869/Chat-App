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
