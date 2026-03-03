const mongoose = require('mongoose');

const listingSchema = new mongoose.Schema(
    {
        seller: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
            index: true,
        },
        title: {
            type: String,
            required: [true, 'Title is required'],
            trim: true,
            maxlength: [100, 'Title cannot exceed 100 characters'],
        },
        description: {
            type: String,
            required: [true, 'Description is required'],
            maxlength: [2000, 'Description cannot exceed 2000 characters'],
        },
        images: [{
            url: {
                type: String,
                required: true,
            },
            publicId: {
                type: String,
                required: true,
            },
        }],
        category: {
            type: String,
            required: [true, 'Category is required'],
            index: true,
        },
        priceType: {
            type: String,
            required: true,
            enum: ['fixed', 'negotiable', 'free', 'auction'],
            default: 'fixed',
        },
        price: {
            type: Number,
            required: function () { return this.priceType !== 'free'; },
            min: [0, 'Price cannot be negative'],
        },
        currency: {
            type: String,
            default: 'USD',
        },
        condition: {
            type: String,
            enum: ['new', 'like-new', 'good', 'fair', 'poor'],
            default: 'good',
        },
        // Location with GeoJSON for map support
        location: {
            name: {
                type: String,
                trim: true,
            },
            address: {
                type: String,
                trim: true,
            },
            type: {
                type: String,
                enum: ['Point'],
                default: 'Point',
            },
            coordinates: {
                type: [Number], // [longitude, latitude]
                default: undefined,
            },
        },
        // Meetup preferences
        meetupPreferences: {
            type: String,
            enum: ['public', 'campus', 'flexible'],
            default: 'public',
        },
        status: {
            type: String,
            enum: ['pending', 'approved', 'rejected', 'sold', 'expired', 'hidden', 'removed'],
            default: 'pending',
            index: true,
        },
        // Sold tracking
        soldTo: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            default: null,
        },
        soldPrice: {
            type: Number,
            default: null,
        },
        soldAt: {
            type: Date,
            default: null,
        },
        rejectionReason: {
            type: String,
            default: null,
        },
        removedReason: {
            type: String,
            default: null,
        },
        removedAt: {
            type: Date,
            default: null,
        },
        removedBy: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            default: null,
        },

        // Engagement stats
        views: {
            type: Number,
            default: 0,
        },
        wishlistCount: {
            type: Number,
            default: 0,
        },
        inquiries: {
            type: Number,
            default: 0,
        },

        // Moderation / Promotion
        isFeatured: {
            type: Boolean,
            default: false,
        },
        featuredUntil: {
            type: Date,
            default: null,
        },
        featuredPlan: {
            type: String,
            enum: ['3days', '7days', '30days', null],
            default: null,
        },
        approvedBy: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
        },
        approvedAt: Date,

        // Auto-expiry
        expiresAt: {
            type: Date,
            default: function () {
                const days = parseInt(process.env.LISTING_EXPIRY_DAYS) || 30;
                return new Date(Date.now() + days * 24 * 60 * 60 * 1000);
            },
            index: true,
        },

        // Tags for enhanced search
        tags: [{
            type: String,
            lowercase: true,
            trim: true,
        }],

        // ── Education metadata (for book listings) ──────────────────────
        educationLevel: {
            type: String,
            trim: true,
            default: null,
            index: true,
        },
        // "Class 6", "Class 10", "HSC 1st Year", "Semester 3", etc.
        classOrSemester: {
            type: String,
            trim: true,
            default: null,
        },
        subject: {
            type: String,
            trim: true,
            default: null,
        },
        bookType: {
            type: String,
            trim: true,
            default: null,
        },

        // ── Bangladesh-specific location ─────────────────────────────────
        division: {
            type: String,
            trim: true,
            default: null,
        },
        district: {
            type: String,
            trim: true,
            default: null,
        },
        upazila: {
            type: String,
            trim: true,
            default: null,
        },
    },
    {
        timestamps: true,
        toJSON: { virtuals: true },
        toObject: { virtuals: true },
    }
);

// Compound indexes for efficient queries
listingSchema.index({ title: 'text', description: 'text', tags: 'text' });
listingSchema.index({ category: 1, status: 1, createdAt: -1 });
listingSchema.index({ seller: 1, status: 1 });
listingSchema.index({ price: 1 });
listingSchema.index({ status: 1, expiresAt: 1 });
listingSchema.index({ 'location.coordinates': '2dsphere' }); // Geo-spatial index for nearby search

// Virtual for seller info
listingSchema.virtual('sellerInfo', {
    ref: 'User',
    localField: 'seller',
    foreignField: '_id',
    justOne: true,
});

// Auto-expire listings
listingSchema.statics.expireListings = async function () {
    const result = await this.updateMany(
        {
            status: 'approved',
            expiresAt: { $lte: new Date() },
        },
        {
            $set: { status: 'expired' },
        }
    );
    return result.modifiedCount;
};

// Auto-expire featured/promoted listings
listingSchema.statics.expireFeatured = async function () {
    const result = await this.updateMany(
        { isFeatured: true, featuredUntil: { $lte: new Date(), $ne: null } },
        { $set: { isFeatured: false, featuredUntil: null, featuredPlan: null } }
    );
    return result.modifiedCount;
};

// Pre-save hook to update seller stats
listingSchema.post('save', async function () {
    if (this.isNew) {
        await mongoose.model('User').findByIdAndUpdate(
            this.seller,
            { $inc: { totalListings: 1 } }
        );
    }
});

module.exports = mongoose.model('Listing', listingSchema);
