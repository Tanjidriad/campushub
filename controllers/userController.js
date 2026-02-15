const User = require('../models/User');
const Listing = require('../models/Listing');
const Review = require('../models/Review');
const { asyncHandler } = require('../middleware/errorHandler');
const { paginate, paginationMeta } = require('../utils/pagination');

// @desc    Get user profile
// @route   GET /api/users/:id
// @access  Public
exports.getUserProfile = asyncHandler(async (req, res) => {
    const user = await User.findById(req.params.id)
        .select('name avatar bio location createdAt averageRating totalReviews totalListings totalSold');

    if (!user) {
        return res.status(404).json({
            success: false,
            message: 'User not found',
        });
    }

    // Get active listings count
    const activeListings = await Listing.countDocuments({
        seller: user._id,
        status: 'approved',
    });

    res.json({
        success: true,
        data: {
            ...user.toObject(),
            activeListings,
        },
    });
});

// @desc    Search users
// @route   GET /api/users/search
// @access  Public
exports.searchUsers = asyncHandler(async (req, res) => {
    const { q, page, limit } = req.query;

    if (!q || q.length < 2) {
        return res.status(400).json({
            success: false,
            message: 'Search query must be at least 2 characters',
        });
    }

    const { skip, limit: limitNum, page: pageNum } = paginate(page, limit);

    const query = {
        $or: [
            { name: { $regex: q, $options: 'i' } },
            { username: { $regex: q, $options: 'i' } },
        ],
        role: 'student',
        isBlocked: false,
    };

    const [users, total] = await Promise.all([
        User.find(query)
            .select('name username avatar averageRating totalReviews')
            .skip(skip)
            .limit(limitNum)
            .lean(),
        User.countDocuments(query),
    ]);

    res.json({
        success: true,
        data: users,
        pagination: paginationMeta(total, pageNum, limitNum),
    });
});

// @desc    Check if username is available
// @route   GET /api/users/check-username/:username
// @access  Public
exports.checkUsername = asyncHandler(async (req, res) => {
    const { username } = req.params;

    // Validate format
    const usernameRegex = /^[a-z0-9_]+$/;
    if (!username || username.length < 3 || username.length > 20) {
        return res.status(400).json({
            success: false,
            available: false,
            message: 'Username must be 3-20 characters',
        });
    }

    if (!usernameRegex.test(username.toLowerCase())) {
        return res.status(400).json({
            success: false,
            available: false,
            message: 'Username can only contain letters, numbers, and underscores',
        });
    }

    // Check if taken
    const existingUser = await User.findOne({ username: username.toLowerCase() });

    res.json({
        success: true,
        available: !existingUser,
        message: existingUser ? 'Username is already taken' : 'Username is available',
    });
});

// @desc    Set or update username
// @route   PUT /api/users/username
// @access  Protected
exports.setUsername = asyncHandler(async (req, res) => {
    const { username } = req.body;

    // Validate
    const usernameRegex = /^[a-z0-9_]+$/;
    if (!username || username.length < 3 || username.length > 20) {
        return res.status(400).json({
            success: false,
            message: 'Username must be 3-20 characters',
        });
    }

    if (!usernameRegex.test(username.toLowerCase())) {
        return res.status(400).json({
            success: false,
            message: 'Username can only contain letters, numbers, and underscores',
        });
    }

    // Check if taken by someone else
    const existingUser = await User.findOne({
        username: username.toLowerCase(),
        _id: { $ne: req.user._id }
    });

    if (existingUser) {
        return res.status(409).json({
            success: false,
            message: 'Username is already taken',
        });
    }

    // Update user's username
    req.user.username = username.toLowerCase();
    await req.user.save();

    res.json({
        success: true,
        message: 'Username updated successfully',
        data: {
            username: req.user.username,
        },
    });
});

// @desc    Get user by username
// @route   GET /api/users/u/:username
// @access  Public
exports.getUserByUsername = asyncHandler(async (req, res) => {
    const user = await User.findOne({ username: req.params.username.toLowerCase() })
        .select('name username avatar bio location createdAt averageRating totalReviews totalListings totalSold');

    if (!user) {
        return res.status(404).json({
            success: false,
            message: 'User not found',
        });
    }

    // Get active listings count
    const activeListings = await Listing.countDocuments({
        seller: user._id,
        status: 'approved',
    });

    res.json({
        success: true,
        data: {
            ...user.toObject(),
            activeListings,
        },
    });
});

// @desc    Register FCM token for push notifications
// @route   POST /api/users/fcm-token
// @access  Protected
exports.registerFcmToken = asyncHandler(async (req, res) => {
    const { token } = req.body;

    if (!token || typeof token !== 'string') {
        return res.status(400).json({
            success: false,
            message: 'FCM token is required',
        });
    }

    // Add token if not already present (using $addToSet to prevent duplicates)
    await User.findByIdAndUpdate(req.user._id, {
        $addToSet: { fcmTokens: token },
    });

    res.json({
        success: true,
        message: 'FCM token registered successfully',
    });
});

// @desc    Remove FCM token (on logout or token refresh)
// @route   DELETE /api/users/fcm-token
// @access  Protected
exports.removeFcmToken = asyncHandler(async (req, res) => {
    const { token } = req.body;

    if (!token) {
        return res.status(400).json({
            success: false,
            message: 'FCM token is required',
        });
    }

    await User.findByIdAndUpdate(req.user._id, {
        $pull: { fcmTokens: token },
    });

    res.json({
        success: true,
        message: 'FCM token removed successfully',
    });
});
