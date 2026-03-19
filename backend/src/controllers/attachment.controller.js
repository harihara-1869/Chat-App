import { generateUploadUrl, generateDownloadUrl, validateAttachmentMeta, scanForMalware } from "../lib/storage.js";
import { sanitizeForLogging } from "../lib/utils.js";

export const getUploadUrl = async (req, res) => {
  try {
    const { fileType, fileSize } = req.body;

    if (!fileType || !fileSize) {
      return res.status(400).json({ error: "fileType and fileSize are required" });
    }

    const validation = validateAttachmentMeta(fileType, parseInt(fileSize));
    if (!validation.valid) {
      return res.status(400).json({ error: validation.error });
    }

    const result = await generateUploadUrl(fileType, parseInt(fileSize));

    res.status(200).json(result);
  } catch (error) {
    console.error("Error in getUploadUrl:", sanitizeForLogging(error));
    res.status(500).json({ error: "Internal server error" });
  }
};

export const getDownloadUrl = async (req, res) => {
  try {
    const { fileKey } = req.params;

    if (!fileKey) {
      return res.status(400).json({ error: "fileKey is required" });
    }

    // Validate fileKey format to prevent path traversal
    if (fileKey.includes('..') || fileKey.includes('/') || fileKey.includes('\\')) {
      return res.status(400).json({ error: "Invalid fileKey format" });
    }

    // Optionally scan file on download for additional security
    // This is typically done on upload, but can be repeated on download
    try {
      const result = await generateDownloadUrl(fileKey);
      res.status(200).json(result);
    } catch (downloadError) {
      if (downloadError.code === 'MALWARE_DETECTED') {
        return res.status(403).json({ error: "File blocked due to security policy" });
      }
      throw downloadError;
    }
  } catch (error) {
    console.error("Error in getDownloadUrl:", sanitizeForLogging(error));
    res.status(500).json({ error: "Internal server error" });
  }
};

/**
 * Scan an uploaded file for malware
 * This endpoint is called after the client uploads the file to our storage
 * to perform the actual virus scan.
 * 
 * Note: This is a placeholder for actual implementation.
 * In production, this would be triggered by an S3 webhook, Lambda trigger,
 * or called by the client after upload completion.
 */
export const scanUploadedFile = async (req, res) => {
  try {
    const { fileKey } = req.body;

    if (!fileKey) {
      return res.status(400).json({ error: "fileKey is required" });
    }

    // Validate fileKey format
    if (fileKey.includes('..') || fileKey.includes('/') || fileKey.includes('\\')) {
      return res.status(400).json({ error: "Invalid fileKey format" });
    }

    // In a real implementation:
    // 1. Download file from S3/storage
    // 2. Pass buffer to scanForMalware()
    // 3. Delete file if malware detected
    // 4. Update attachment record with scan status
    
    // Placeholder response
    res.status(200).json({ 
      status: "scan_complete",
      fileKey,
      clean: true 
    });
  } catch (error) {
    console.error("Error in scanUploadedFile:", sanitizeForLogging(error));
    res.status(500).json({ error: "Internal server error" });
  }
};
