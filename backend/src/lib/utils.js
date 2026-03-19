import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config();

export const generateToken = (userId, res) => {
  const token = jwt.sign({ id: userId, type: 'access_token' }, process.env.JWT_SECRET, {
    expiresIn: '3h',
  });
  res.cookie("jwt", token, {
    httpOnly: true,
    maxAge: 3 * 60 * 60 * 1000, // 3 hours in milliseconds
    sameSite: 'strict',
    secure: process.env.NODE_ENV === 'production',
  });

  return token;
};

export const generateTempToken = (userData) => {
  const token = jwt.sign(
    {
      type: 'temp_token',
      googleId: userData.googleId,
      email: userData.email,
      fullName: userData.fullName,
      profilePic: userData.profilePic,
      emailVerified: userData.emailVerified,
    },
    process.env.JWT_SECRET,
    {
      expiresIn: '10m', // 10 minutes
    }
  );

  return token;
};

export const verifyTempToken = (token) => {
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    if (decoded.type !== 'temp_token') {
      return null;
    }
    return decoded;
  } catch (error) {
    return null;
  }
};

/**
 * Sanitize user input before logging to prevent log injection attacks
 * and sensitive data exposure.
 * 
 * @param {any} input - The input to sanitize
 * @returns {string} - Sanitized string safe for logging
 */
export const sanitizeForLogging = (input) => {
  if (input === null || input === undefined) {
    return '[null/undefined]';
  }

  if (typeof input === 'object') {
    // For Error objects, extract safe properties only
    if (input instanceof Error) {
      return `[Error: ${input.name}]`;
    }
    
    // For objects, recursively sanitize and filter sensitive fields
    const sensitiveFields = [
      'password', 'token', 'secret', 'key', 'authorization', 
      'cookie', 'jwt', 'private', 'credential', 'ssn', 'credit'
    ];
    
    const sanitized = {};
    for (const [key, value] of Object.entries(input)) {
      const lowerKey = key.toLowerCase();
      if (sensitiveFields.some(field => lowerKey.includes(field))) {
        sanitized[key] = '[REDACTED]';
      } else {
        sanitized[key] = sanitizeForLogging(value);
      }
    }
    return JSON.stringify(sanitized);
  }

  if (typeof input === 'string') {
    // Remove potential log injection attempts (newlines in log context)
    // Allow unicode but remove control characters that could manipulate logs
    return input
      .replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, '')
      .slice(0, 1000); // Limit length to prevent DoS
  }

  return String(input).slice(0, 1000);
};