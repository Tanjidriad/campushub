const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema(
    {
        user: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
            index: true,
        },
        type: {
            type: String,
            required: true,
            enum: [
                'new_message',
                'listing_approved',
                'listing_rejected',
                'listing_expired',
                'new_review',
                'price_drop',
                'wishlist_sold',
                'account_warning',
                'system',
                'new_offer',
                'offer_accepted',
                'offer_declined',
                'offer_countered',
                'new_report',
            ],
        },
        title: {
            type: String,
            required: true,
            maxlength: [100, 'Title cannot exceed 100 characters'],
        },
        body: {
            type: String,
            required: true,
            maxlength: [300, 'Body cannot exceed 300 characters'],
        },
        data: {
            // Additional data for navigation/linking
            listingId: {
                type: mongoose.Schema.Types.ObjectId,
                ref: 'Listing',
            },
            conversationId: {
                type: mongoose.Schema.Types.ObjectId,
                ref: 'Conversation',
            },
            userId: {
                type: mongoose.Schema.Types.ObjectId,
                ref: 'User',
            },
            offerId: {
                type: mongoose.Schema.Types.ObjectId,
                ref: 'Offer',
            },
            url: String,
        },
        isRead: {
            type: Boolean,
            default: false,
        },
        readAt: Date,
    },
    {
        timestamps: true,
    }
);

// Indexes for efficient queries
notificationSchema.index({ user: 1, isRead: 1, createdAt: -1 });
notificationSchema.index({ createdAt: -1 });

// Auto-delete old notifications (30 days)
notificationSchema.index({ createdAt: 1 }, { expireAfterSeconds: 30 * 24 * 60 * 60 });

// Static method to create and (optionally) trigger a push notification.
// NOTE: This template only persists notifications to MongoDB.
// If you want to send push notifications, wire this up to your
// FCM/OneSignal service in notificationService.js.
notificationSchema.statics.createNotification = async function ({
    userId,
    type,
    title,
    body,
    data = {},
}) {
    const notification = await this.create({
        user: userId,
        type,
        title,
        body,
        data,
    });

    // TODO: Add push notification logic here if FCM/OneSignal is integrated
    // For now, we just store the notification

    return notification;
};

// Static method to mark notifications as read
notificationSchema.statics.markAsRead = async function (userId, notificationIds) {
    return await this.updateMany(
        {
            _id: { $in: notificationIds },
            user: userId,
        },
        {
            $set: { isRead: true, readAt: new Date() },
        }
    );
};

// Static method to mark all as read for a user
notificationSchema.statics.markAllAsRead = async function (userId) {
    return await this.updateMany(
        {
            user: userId,
            isRead: false,
        },
        {
            $set: { isRead: true, readAt: new Date() },
        }
    );
};

// Static method to get unread count
notificationSchema.statics.getUnreadCount = async function (userId) {
    return await this.countDocuments({
        user: userId,
        isRead: false,
    });
};

module.exports = mongoose.model('Notification', notificationSchema);
