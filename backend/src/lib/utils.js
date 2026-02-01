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
}