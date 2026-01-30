import User from '../models/user.model.js';
import bcrypt from 'bcryptjs';
import {generateToken} from '../lib/utils.js';

export const signup = async (req, res) => {
  const {fullName, email, password} = req.body;
  try {
    if(!fullName || !email || !password){
      return res.status(400).json({message: "All fields are required."});
    }

    if (/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      // Email is valid
    }else {
      return res.status(400).json({message: "Invalid email format."});
    }

    if(password.length < 6){
      return res.status(400).json({message: "Password must be at least 6 characters long."});
    }

    const user = await User.findOne({email});
    if(user){
      return  res.status(400).json({message: "User with this email already exists."});
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);
    
    const newUser = new User({
      fullName,
      email,
      password: hashedPassword,
    });
    
    if(newUser){
      //generate JWT token
      generateToken(newUser._id, res);
      await newUser.save();
      return res.status(201).json({
        _id: newUser._id,
        fullName: newUser.fullName,
        email: newUser.email,
        profilePic: newUser.profilePic || null,
      });
    }else {
      return res.status(500).json({message: "Failed to create user."});
    }

  } catch (error) {
    console.error("Error during signup:", error);
    return res.status(500).json({message: "Server error during signup."});
  }
};

export const login = (req, res) => {
  res.send('Login Route');
};

export const logout = (req, res) => {
  res.send('Logout Route');
};