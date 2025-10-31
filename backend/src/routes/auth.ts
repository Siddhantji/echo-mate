import express from 'express';
import jwt from 'jsonwebtoken';
import User from '../models/User';
import { auth, AuthRequest } from '../middleware/auth';

const router = express.Router();

// Register
router.post('/register', async (req, res) => {
  try {
    // Basic request validation so we return clear 400 messages for bad requests
    const { username, email, password, fullName } = req.body || {};

    const missing: string[] = [];
    if (!username) missing.push('username');
    if (!email) missing.push('email');
    if (!password) missing.push('password');
    if (!fullName) missing.push('fullName');

    if (missing.length > 0) {
      return res.status(400).json({ message: `Missing required field(s): ${missing.join(', ')}` });
    }

    // Normalize inputs a little
    const normalizedEmail = (email as string).toLowerCase().trim();

    // Log attempt for easier debugging (don't log passwords in production)
    console.log('Register attempt:', { username, email: normalizedEmail, fullName });

    // Check if user already exists
    const existingUser = await User.findOne({ 
      $or: [{ email: normalizedEmail }, { username }] 
    });
    
    if (existingUser) {
      return res.status(400).json({ 
        message: 'User with this email or username already exists' 
      });
    }

    // Create new user
    const user = new User({
      username,
      email: normalizedEmail,
      password,
      fullName
    });

    await user.save();

    // Generate JWT token
    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET || 'fallback_secret',
      { expiresIn: '7d' }
    );

    res.status(201).json({
      message: 'User created successfully',
      token,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        fullName: user.fullName,
        profilePicture: user.profilePicture
      }
    });
  } catch (error: any) {
    console.error('Registration error:', error);
    res.status(500).json({ message: 'Server error during registration' });
  }
});

// Login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body || {};

    if (!email || !password) {
      return res.status(400).json({ message: 'Missing email or password' });
    }

    const normalizedEmail = (email as string).toLowerCase().trim();

    // Log login attempt (do not log password in production)
    console.log('Login attempt:', { email: normalizedEmail });

    // Find user by email
    const user = await User.findOne({ email: normalizedEmail });
    if (!user) {
      // Use 401 Unauthorized for invalid credentials
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET || 'fallback_secret',
      { expiresIn: '7d' }
    );

    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        fullName: user.fullName,
        profilePicture: user.profilePicture
      }
    });
  } catch (error: any) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Server error during login' });
  }
});

// Get current user
router.get('/me', auth, async (req: AuthRequest, res) => {
  try {
    res.json({
      user: {
        id: req.user?._id,
        username: req.user?.username,
        email: req.user?.email,
        fullName: req.user?.fullName,
        bio: req.user?.bio,
        profilePicture: req.user?.profilePicture,
        followers: req.user?.followers?.length || 0,
        following: req.user?.following?.length || 0
      }
    });
  } catch (error: any) {
    console.error('Get user error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

export default router;
