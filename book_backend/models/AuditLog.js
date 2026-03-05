const mongoose = require('mongoose');

const auditLogSchema = new mongoose.Schema(
    {
        action: {
            type: String,
            required: true,
            enum: [
                'user_banned',
                'user_unbanned',
                'user_role_changed',
                'listing_approved',
                'listing_rejected',
                'listing_deleted',
                'listing_featured',
                'listing_unfeatured',
                'report_reviewed',
                'category_created',
                'category_updated',
                'category_deleted',
                'bulk_approve',
                'bulk_reject',
                'bulk_delete',
            ],
            index: true,
        },
        performedBy: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
            index: true,
        },
        targetType: {
            type: String,
            required: true,
            enum: ['User', 'Listing', 'Report', 'Category'],
        },
        targetId: {
            type: mongoose.Schema.Types.ObjectId,
            required: true,
        },
        details: {
            type: mongoose.Schema.Types.Mixed,
            default: {},
        },
        ip: String,
    },
    {
        timestamps: true,
    }
);

// Indexes for efficient querying
auditLogSchema.index({ createdAt: -1 });
auditLogSchema.index({ action: 1, createdAt: -1 });
auditLogSchema.index({ performedBy: 1, createdAt: -1 });

// Auto-delete logs older than 90 days
auditLogSchema.index({ createdAt: 1 }, { expireAfterSeconds: 90 * 24 * 60 * 60 });

module.exports = mongoose.model('AuditLog', auditLogSchema);
