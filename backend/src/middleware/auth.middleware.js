import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';
import User from '../models/user.model.js';
import { generateTempToken, sanitizeForLogging } from '../lib/utils.js';

dotenv.config();

export const protectRoute = async (req, res, next) => {
  try {
    const token = req.cookies.jwt;

    if (!token) {
      return res.status(401).json({ message: 'No token provided, authorization denied.' });
    }

    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (jwtError) {
      if (jwtError instanceof jwt.TokenExpiredError) {
        return res.status(401).json({ message: 'Token has expired.' });
      }
      if (jwtError instanceof jwt.JsonWebTokenError) {
        return res.status(401).json({ message: 'Invalid token format.' });
      }
      return res.status(401).json({ message: 'Token verification failed.' });
    }

    if (!decoded || !decoded.id) {
      return res.status(401).json({ message: 'Token is not valid.' });
    }

    if (decoded.type !== 'access_token') {
      return res.status(401).json({ message: 'Token is not valid.' });
    }

    const user = await User.findById(decoded.id).select("-password")

    if (!user) {
      return res.status(404).json({ message: "User not found" })
    }

    if (!user.privacyPolicyAccepted || !user.termsAndConditionsAccepted) {
      const tempToken = generateTempToken(user);
      return res.status(403).json({ message: "Policy not accepted", redirectTo: `/accept-policies?email=${encodeURIComponent(user.email)}&token=${encodeURIComponent(tempToken)}` });
    }

    req.user = user

    next()
  } catch (error) {
    const sanitizedError = sanitizeForLogging(error);
    console.error("Token verification error:", sanitizedError);
    return res.status(401).json({ message: 'Token verification failed.' });
  }
}