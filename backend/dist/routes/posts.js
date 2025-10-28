"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const Post_1 = __importDefault(require("../models/Post"));
const User_1 = __importDefault(require("../models/User"));
const auth_1 = require("../middleware/auth");
const router = express_1.default.Router();
// Create a new post
router.post('/', auth_1.auth, async (req, res) => {
    try {
        const { content, image } = req.body;
        const userId = req.user?._id;
        if (!content || content.trim().length === 0) {
            return res.status(400).json({ message: 'Post content is required' });
        }
        const post = new Post_1.default({
            author: userId,
            content: content.trim(),
            image: image || ''
        });
        await post.save();
        // Populate author information
        await post.populate('author', 'username fullName profilePicture');
        res.status(201).json({
            message: 'Post created successfully',
            post
        });
    }
    catch (error) {
        console.error('Create post error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});
// Get feed posts (posts from followed users + own posts)
router.get('/feed', auth_1.auth, async (req, res) => {
    try {
        const userId = req.user?._id;
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;
        // Get current user's following list
        const currentUser = await User_1.default.findById(userId);
        if (!currentUser) {
            return res.status(404).json({ message: 'User not found' });
        }
        // Create array of user IDs to get posts from (following + self)
        const feedUserIds = [...currentUser.following, userId];
        const posts = await Post_1.default.find({ author: { $in: feedUserIds } })
            .populate('author', 'username fullName profilePicture')
            .populate('comments.user', 'username fullName profilePicture')
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit);
        res.json({ posts, page, hasMore: posts.length === limit });
    }
    catch (error) {
        console.error('Get feed error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});
// Get all posts (public timeline)
router.get('/timeline', async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;
        const posts = await Post_1.default.find()
            .populate('author', 'username fullName profilePicture')
            .populate('comments.user', 'username fullName profilePicture')
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit);
        res.json({ posts, page, hasMore: posts.length === limit });
    }
    catch (error) {
        console.error('Get timeline error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});
// Get posts by user
router.get('/user/:username', async (req, res) => {
    try {
        const { username } = req.params;
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;
        const user = await User_1.default.findOne({ username });
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        const posts = await Post_1.default.find({ author: user._id })
            .populate('author', 'username fullName profilePicture')
            .populate('comments.user', 'username fullName profilePicture')
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit);
        res.json({ posts, page, hasMore: posts.length === limit });
    }
    catch (error) {
        console.error('Get user posts error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});
// Like/Unlike a post
router.post('/:postId/like', auth_1.auth, async (req, res) => {
    try {
        const { postId } = req.params;
        const userId = req.user?._id;
        const post = await Post_1.default.findById(postId);
        if (!post) {
            return res.status(404).json({ message: 'Post not found' });
        }
        const isLiked = post.likes.includes(userId);
        if (isLiked) {
            // Unlike
            post.likes = post.likes.filter(id => id.toString() !== userId?.toString());
        }
        else {
            // Like
            post.likes.push(userId);
        }
        await post.save();
        res.json({
            message: isLiked ? 'Post unliked' : 'Post liked',
            isLiked: !isLiked,
            likesCount: post.likes.length
        });
    }
    catch (error) {
        console.error('Like/Unlike post error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});
// Add comment to post
router.post('/:postId/comment', auth_1.auth, async (req, res) => {
    try {
        const { postId } = req.params;
        const { text } = req.body;
        const userId = req.user?._id;
        if (!text || text.trim().length === 0) {
            return res.status(400).json({ message: 'Comment text is required' });
        }
        const post = await Post_1.default.findById(postId);
        if (!post) {
            return res.status(404).json({ message: 'Post not found' });
        }
        const comment = {
            user: userId,
            text: text.trim(),
            createdAt: new Date()
        };
        post.comments.push(comment);
        await post.save();
        // Populate the new comment with user info
        await post.populate('comments.user', 'username fullName profilePicture');
        res.status(201).json({
            message: 'Comment added successfully',
            comment: post.comments[post.comments.length - 1]
        });
    }
    catch (error) {
        console.error('Add comment error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});
// Delete a post
router.delete('/:postId', auth_1.auth, async (req, res) => {
    try {
        const { postId } = req.params;
        const userId = req.user?._id;
        const post = await Post_1.default.findById(postId);
        if (!post) {
            return res.status(404).json({ message: 'Post not found' });
        }
        // Check if user is the author of the post
        if (post.author.toString() !== userId?.toString()) {
            return res.status(403).json({ message: 'Not authorized to delete this post' });
        }
        await Post_1.default.findByIdAndDelete(postId);
        res.json({ message: 'Post deleted successfully' });
    }
    catch (error) {
        console.error('Delete post error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});
exports.default = router;
