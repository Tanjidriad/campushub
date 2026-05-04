const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema(
    {
        email: {
            type: String,
            required: [true, 'Email is required'],
            unique: true,
            lowercase: true,
            trim: true,
            match: [/^\S+@\S+\.\S+$/, 'Please enter a valid email'],
        },
        username: {
            type: String,
            unique: true,
            sparse: true, // Allows null until user sets it
            lowercase: true,
            trim: true,
            minlength: [3, 'Username must be at least 3 characters'],
            maxlength: [20, 'Username cannot exceed 20 characters'],
            match: [/^[a-z0-9_]+$/, 'Username can only contain letters, numbers, and underscores'],
        },
        password: {
            type: String,
            minlength: [6, 'Password must be at least 6 characters'],
            select: false, // Don't include password in queries by default
        },
        name: {
            type: String,
            required: [true, 'Name is required'],
            trim: true,
            maxlength: [50, 'Name cannot exceed 50 characters'],
        },
        avatar: {
            type: String,
            default: null,
        },
        phone: {
            type: String,
            trim: true,
            default: null,
        },
        bio: {
            type: String,
            maxlength: [500, 'Bio cannot exceed 500 characters'],
            default: null,
        },
        location: {
            type: String,
            trim: true,
            default: null,
        },
        
        // Education Profile
        educationLevel: {
            type: String,
            default: null,
            index: true,
        },
        stream: {
            type: String,
            default: null,
        },
        department: {
            type: String,
            default: null,
            index: true,
        },
        classOrSemester: {
            type: String,
            default: null,
            index: true,
        },

        // Authentication
        role: {
            type: String,
            enum: ['student', 'admin', 'superadmin'],
            default: 'student',
        },
        // When enabled, admin user is locked into a read-only demo experience.
        // Used by `demoGuard` middleware to block state-mutating admin actions.
        isDemo: {
            type: Boolean,
            default: false,
            index: true,
        },
        isVerified: {
            type: Boolean,
            default: false,
        },
        isBlocked: {
            type: Boolean,
            default: false,
        },

        // Online status tracking
        isOnline: {
            type: Boolean,
            default: false,
        },
        lastActive: {
            type: Date,
            default: Date.now,
        },

        googleId: {
            type: String,
            unique: true,
            sparse: true, // Allows null values to be non-unique
        },

        // Verification & Reset tokens
        verificationToken: String,
        verificationTokenExpires: Date,
        passwordResetToken: String,
        passwordResetExpires: Date,

        // Refresh token for JWT
        refreshToken: String,

        // Push notifications - supports multiple devices
        fcmTokens: [{
            type: String,
        }],
        // Legacy field - kept for backwards compatibility
        pushToken: {
            type: String,
            default: null,
        },

        // Wishlist
        wishlist: [{
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Listing',
        }],

        // Blocked users
        blockedUsers: [{
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
        }],

        // Stats
        totalListings: {
            type: Number,
            default: 0,
        },
        totalSold: {
            type: Number,
            default: 0,
        },
        averageRating: {
            type: Number,
            default: 0,
        },
        totalReviews: {
            type: Number,
            default: 0,
        },
    },
    {
        timestamps: true,
        toJSON: { virtuals: true },
        toObject: { virtuals: true },
    }
);

// Index for search
userSchema.index({ name: 'text', email: 'text' });

// Hash password before saving
userSchema.pre('save', async function () {
    if (!this.isModified('password')) return;

    if (this.password) {
        const salt = await bcrypt.genSalt(12);
        this.password = await bcrypt.hash(this.password, salt);
    }
});

// Compare password method
userSchema.methods.comparePassword = async function (candidatePassword) {
    return await bcrypt.compare(candidatePassword, this.password);
};

// Generate verification token
userSchema.methods.generateVerificationToken = function () {
    const crypto = require('crypto');
    const token = crypto.randomBytes(32).toString('hex');
    this.verificationToken = crypto.createHash('sha256').update(token).digest('hex');
    this.verificationTokenExpires = Date.now() + 24 * 60 * 60 * 1000; // 24 hours
    return token;
};

// Generate password reset token
userSchema.methods.generatePasswordResetToken = function () {
    const crypto = require('crypto');
    const token = crypto.randomBytes(32).toString('hex');
    this.passwordResetToken = crypto.createHash('sha256').update(token).digest('hex');
    this.passwordResetExpires = Date.now() + 60 * 60 * 1000; // 1 hour
    return token;
};

// Virtual for user's listings
userSchema.virtual('listings', {
    ref: 'Listing',
    localField: '_id',
    foreignField: 'seller',
});

module.exports = mongoose.model('User', userSchema);
