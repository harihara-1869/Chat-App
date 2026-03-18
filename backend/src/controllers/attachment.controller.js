import { generateUploadUrl, generateDownloadUrl, validateAttachmentMeta } from "../lib/storage.js";

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
    console.error("Error in getUploadUrl:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

export const getDownloadUrl = async (req, res) => {
  try {
    const { fileKey } = req.params;

    if (!fileKey) {
      return res.status(400).json({ error: "fileKey is required" });
    }

    const result = await generateDownloadUrl(fileKey);

    res.status(200).json(result);
  } catch (error) {
    console.error("Error in getDownloadUrl:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};
