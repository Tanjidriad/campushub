const Review = require('../models/Review');
const User = require('../models/User');
const Listing = require('../models/Listing');
const { Notification } = require('../models');
const { asyncHandler } = require('../middleware/errorHandler');
const { paginate, paginationMeta } = require('../utils/pagination');

// @desc    Get reviews for a seller
// @route   GET /api/reviews/seller/:sellerId
// @access  Public
exports.getSellerReviews = asyncHandler(async (req, res) => {
    const { sellerId } = req.params;
    const { page, limit } = req.query;
    const { skip, limit: limitNum, page: pageNum } = paginate(page, limit);

    const [reviews, total] = await Promise.all([
        Review.find({ seller: sellerId })
            .populate('reviewer', 'name avatar')
            .populate('listing', 'title')
            .sort('-createdAt')
            .skip(skip)
            .limit(limitNum)
            .lean(),
        Review.countDocuments({ seller: sellerId }),
    ]);

    // Get seller's rating stats
    const seller = await User.findById(sellerId).select('averageRating totalReviews');

    res.json({
        success: true,
        data: {
            reviews,
            stats: {
                averageRating: seller?.averageRating || 0,
                totalReviews: seller?.totalReviews || 0,
            },
        },
        pagination: paginationMeta(total, pageNum, limitNum),
    });
});

// @desc    Create review
// @route   POST /api/reviews
// @access  Private
exports.createReview = asyncHandler(async (req, res) => {
    const { sellerId, listingId, rating, comment } = req.body;

    // Can't review yourself
    if (sellerId === req.user._id.toString()) {
        return res.status(400).json({
            success: false,
            message: 'Cannot review yourself',
        });
    }

    // Check if seller exists
    const seller = await User.findById(sellerId);
    if (!seller) {
        return res.status(404).json({
            success: false,
            message: 'Seller not found',
        });
    }

    // Check for existing review
    const existingReview = await Review.findOne({
        reviewer: req.user._id,
        seller: sellerId,
        listing: listingId || { $exists: false },
    });

    if (existingReview) {
        return res.status(400).json({
            success: false,
            message: 'You have already reviewed this seller',
        });
    }

    const review = await Review.create({
        reviewer: req.user._id,
        seller: sellerId,
        listing: listingId || undefined,
        rating,
        comment,
    });

    await review.populate('reviewer', 'name avatar');

    // Notify seller
    await Notification.createNotification({
        userId: sellerId,
        type: 'new_review',
        title: 'New Review Received',
        body: `${req.user.name} gave you a ${rating}-star review`,
        data: { userId: req.user._id },
    });

    res.status(201).json({
        success: true,
        data: review,
    });
});

// @desc    Update review
// @route   PUT /api/reviews/:id
// @access  Private (owner only)
exports.updateReview = asyncHandler(async (req, res) => {
    const { rating, comment } = req.body;

    const review = await Review.findById(req.params.id);

    if (!review) {
        return res.status(404).json({
            success: false,
            message: 'Review not found',
        });
    }

    if (review.reviewer.toString() !== req.user._id.toString()) {
        return res.status(403).json({
            success: false,
            message: 'Not authorized',
        });
    }

    if (rating) review.rating = rating;
    if (comment !== undefined) review.comment = comment;
    await review.save();

    // Recalculate seller average
    await Review.calculateAverageRating(review.seller);

    res.json({
        success: true,
        data: review,
    });
});

// @desc    Delete review
// @route   DELETE /api/reviews/:id
// @access  Private (owner or admin)
exports.deleteReview = asyncHandler(async (req, res) => {
    const review = await Review.findById(req.params.id);

    if (!review) {
        return res.status(404).json({
            success: false,
            message: 'Review not found',
        });
    }

    // Only owner or admin can delete
    if (
        review.reviewer.toString() !== req.user._id.toString() &&
        !['admin', 'superadmin'].includes(req.user.role)
    ) {
        return res.status(403).json({
            success: false,
            message: 'Not authorized',
        });
    }

    const sellerId = review.seller;
    await review.deleteOne();

    // Recalculate seller average
    await Review.calculateAverageRating(sellerId);

    res.json({
        success: true,
        message: 'Review deleted',
    });
});

// @desc    Get my reviews (given by user)
// @route   GET /api/reviews/my-reviews
// @access  Private
exports.getMyReviews = asyncHandler(async (req, res) => {
    const { page, limit } = req.query;
    const { skip, limit: limitNum, page: pageNum } = paginate(page, limit);

    const [reviews, total] = await Promise.all([
        Review.find({ reviewer: req.user._id })
            .populate('seller', 'name avatar')
            .populate('listing', 'title')
            .sort('-createdAt')
            .skip(skip)
            .limit(limitNum)
            .lean(),
        Review.countDocuments({ reviewer: req.user._id }),
    ]);

    res.json({
        success: true,
        data: reviews,
        pagination: paginationMeta(total, pageNum, limitNum),
    });
});
