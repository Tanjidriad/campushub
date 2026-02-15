const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema(
    {
        reviewer: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
        },
        seller: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
            index: true,
        },
        listing: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Listing',
        },
        rating: {
            type: Number,
            required: [true, 'Rating is required'],
            min: [1, 'Rating must be at least 1'],
            max: [5, 'Rating cannot exceed 5'],
        },
        comment: {
            type: String,
            maxlength: [500, 'Comment cannot exceed 500 characters'],
        },
        isVerifiedPurchase: {
            type: Boolean,
            default: false,
        },
    },
    {
        timestamps: true,
    }
);

// Prevent duplicate reviews
reviewSchema.index({ reviewer: 1, seller: 1, listing: 1 }, { unique: true });

// Update seller's average rating after review save
reviewSchema.post('save', async function () {
    await this.constructor.calculateAverageRating(this.seller);
});

// Update seller's average rating after review delete
reviewSchema.post('findOneAndDelete', async function (doc) {
    if (doc) {
        await mongoose.model('Review').calculateAverageRating(doc.seller);
    }
});

// Static method to calculate average rating
reviewSchema.statics.calculateAverageRating = async function (sellerId) {
    const stats = await this.aggregate([
        { $match: { seller: sellerId } },
        {
            $group: {
                _id: '$seller',
                averageRating: { $avg: '$rating' },
                totalReviews: { $sum: 1 },
            },
        },
    ]);

    if (stats.length > 0) {
        await mongoose.model('User').findByIdAndUpdate(sellerId, {
            averageRating: Math.round(stats[0].averageRating * 10) / 10, // Round to 1 decimal
            totalReviews: stats[0].totalReviews,
        });
    } else {
        await mongoose.model('User').findByIdAndUpdate(sellerId, {
            averageRating: 0,
            totalReviews: 0,
        });
    }
};

module.exports = mongoose.model('Review', reviewSchema);
