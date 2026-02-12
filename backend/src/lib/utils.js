import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config();

export const generateToken = (userId, res) => {
  const token = jwt.sign({ id: userId }, process.env.JWT_SECRET, {
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
      type: 'google_signup_pending',
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
    if (decoded.type !== 'google_signup_pending') {
      return null;
    }
    return decoded;
  } catch (error) {
    return null;
  }
};