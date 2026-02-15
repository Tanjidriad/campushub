const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema(
    {
        reporter: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
        },
        targetType: {
            type: String,
            required: true,
            enum: ['user', 'listing', 'message'],
        },
        targetId: {
            type: mongoose.Schema.Types.ObjectId,
            required: true,
            refPath: 'targetModel',
        },
        targetModel: {
            type: String,
            required: true,
            enum: ['User', 'Listing', 'ChatMessage'],
        },
        reason: {
            type: String,
            required: [true, 'Reason is required'],
            enum: [
                'spam',
                'inappropriate',
                'fraud',
                'harassment',
                'prohibited_item',
                'wrong_category',
                'duplicate',
                'other',
            ],
        },
        description: {
            type: String,
            maxlength: [500, 'Description cannot exceed 500 characters'],
        },
        status: {
            type: String,
            enum: ['pending', 'reviewed', 'resolved', 'dismissed'],
            default: 'pending',
        },
        reviewedBy: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
        },
        reviewedAt: Date,
        resolution: {
            type: String,
            maxlength: [500, 'Resolution cannot exceed 500 characters'],
        },
        actionTaken: {
            type: String,
            enum: ['none', 'warning', 'content_removed', 'user_banned'],
        },
    },
    {
        timestamps: true,
    }
);

// Indexes
reportSchema.index({ status: 1, createdAt: -1 });
reportSchema.index({ targetType: 1, targetId: 1 });
reportSchema.index({ reporter: 1 });

// Prevent duplicate reports
reportSchema.index(
    { reporter: 1, targetType: 1, targetId: 1 },
    { unique: true }
);

module.exports = mongoose.model('Report', reportSchema);
