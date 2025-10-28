"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const User_1 = __importDefault(require("../models/User"));
const auth_1 = require("../middleware/auth");
const router = express_1.default.Router();
// Get user profile
router.get('/profile/:username', async (req, res) => {
    try {
        const { username } = req.params;
        const user = await User_1.default.findOne({ username })
            .select('-password -email')
            .populate('followers', 'username fullName profilePicture')
            .populate('following', 'username fullName profilePicture');
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.json({
            user: {
                id: user._id,
                username: user.username,
                fullName: user.fullName,
                bio: user.bio,
                profilePicture: user.profilePicture,
                followers: user.followers,
                following: user.following,
                followersCount: user.followers.length,
                followingCount: user.following.length,
                createdAt: user.createdAt
            }
        });
    }
    catch (error) {
        console.error('Get profile error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});
// Update user profile
router.put('/profile', auth_1.auth, async (req, res) => {
    try {
        const { fullName, bio, profilePicture } = req.body;
        const userId = req.user?._id;
        const updatedUser = await User_1.default.findByIdAndUpdate(userId, { fullName, bio, profilePicture }, { new: true, runValidators: true }).select('-password');
        if (!updatedUser) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.json({
            message: 'Profile updated successfully',
            user: {
                id: updatedUser._id,
                username: updatedUser.username,
                email: updatedUser.email,
                fullName: updatedUser.fullName,
                bio: updatedUser.bio,
                profilePicture: updatedUser.profilePicture
            }
        });
    }
    catch (error) {
        console.error('Update profile error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});
// Follow/Unfollow user
router.post('/follow/:userId', auth_1.auth, async (req, res) => {
    try {
        const { userId } = req.params;
        const currentUserId = req.user?._id;
        if (userId === currentUserId?.toString()) {
            return res.status(400).json({ message: 'You cannot follow yourself' });
        }
        const userToFollow = await User_1.default.findById(userId);
        const currentUser = await User_1.default.findById(currentUserId);
        if (!userToFollow || !currentUser) {
            return res.status(404).json({ message: 'User not found' });
        }
        const isFollowing = currentUser.following.includes(userToFollow._id);
        if (isFollowing) {
            // Unfollow
            currentUser.following = currentUser.following.filter(id => id.toString() !== userId);
            userToFollow.followers = userToFollow.followers.filter(id => id.toString() !== currentUserId?.toString());
        }
        else {
            // Follow
            currentUser.following.push(userToFollow._id);
            userToFollow.followers.push(currentUser._id);
        }
        await currentUser.save();
        await userToFollow.save();
        res.json({
            message: isFollowing ? 'Unfollowed successfully' : 'Followed successfully',
            isFollowing: !isFollowing
        });
    }
    catch (error) {
        console.error('Follow/Unfollow error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});
// Search users
router.get('/search', async (req, res) => {
    try {
        const { q } = req.query;
        if (!q || typeof q !== 'string') {
            return res.status(400).json({ message: 'Search query is required' });
        }
        const users = await User_1.default.find({
            $or: [
                { username: { $regex: q, $options: 'i' } },
                { fullName: { $regex: q, $options: 'i' } }
            ]
        })
            .select('username fullName profilePicture')
            .limit(10);
        res.json({ users });
    }
    catch (error) {
        console.error('Search users error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});
exports.default = router;
