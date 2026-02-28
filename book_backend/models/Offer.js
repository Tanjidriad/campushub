const mongoose = require('mongoose');

const offerSchema = new mongoose.Schema(
    {
        listing: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Listing',
            required: true,
            index: true,
        },
        buyer: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
            index: true,
        },
        seller: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
            index: true,
        },
        amount: {
            type: Number,
            required: [true, 'Offer amount is required'],
            min: [0, 'Offer amount cannot be negative'],
        },
        status: {
            type: String,
            enum: ['pending', 'accepted', 'declined', 'countered', 'expired', 'cancelled'],
            default: 'pending',
            index: true,
        },
        counterAmount: {
            type: Number,
            min: [0, 'Counter amount cannot be negative'],
        },
        roundNumber: {
            type: Number,
            default: 1,
            max: [3, 'Maximum 3 negotiation rounds allowed'],
        },
        parentOffer: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Offer',
        },
        message: {
            type: String,
            maxlength: [300, 'Message cannot exceed 300 characters'],
        },
        respondedAt: Date,
        expiresAt: {
            type: Date,
            required: true,
            index: true,
        },
    },
    {
        timestamps: true,
    }
);

// Compound indexes
offerSchema.index({ listing: 1, buyer: 1, status: 1 });
offerSchema.index({ seller: 1, status: 1, createdAt: -1 });
offerSchema.index({ buyer: 1, status: 1, createdAt: -1 });
offerSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 }); // TTL won't delete, we handle via status

// Pre-save: set expiresAt if not set
offerSchema.pre('save', function () {
    if (this.isNew && !this.expiresAt) {
        this.expiresAt = new Date(Date.now() + 48 * 60 * 60 * 1000); // 48 hours
    }
});

// Check if offer is expired
offerSchema.methods.isExpired = function () {
    return this.status === 'pending' && new Date() > this.expiresAt;
};

// Static: get active offers for a listing
offerSchema.statics.getActiveOffers = async function (listingId) {
    return await this.find({
        listing: listingId,
        status: { $in: ['pending', 'countered'] },
        expiresAt: { $gt: new Date() },
    })
        .populate('buyer', 'name avatar')
        .sort('-createdAt')
        .lean();
};

// Static: check if buyer already has pending offer on listing
offerSchema.statics.hasPendingOffer = async function (listingId, buyerId) {
    return await this.findOne({
        listing: listingId,
        buyer: buyerId,
        status: { $in: ['pending', 'countered'] },
        expiresAt: { $gt: new Date() },
    });
};

module.exports = mongoose.model('Offer', offerSchema);
