/**
 * Notification Service
 * Handles sending push notifications for various app events
 */
const { sendToMultipleDevices, isFirebaseAvailable } = require('../config/firebaseAdmin');
const User = require('../models/User');

/**
 * Send chat message notification to offline user
 * @param {string} recipientId - User ID of the recipient
 * @param {object} sender - Sender info { name, avatar }
 * @param {object} message - Message content { text, messageType }
 * @param {object} conversation/conversationId - Populated conversation object or ID
 */
const sendChatNotification = async (recipientId, sender, message, conversation) => {
    if (!isFirebaseAvailable()) {
        return { sent: false, reason: 'firebase_not_available' };
    }

    try {
        // Get recipient's FCM tokens
        const recipient = await User.findById(recipientId).select('fcmTokens name');

        if (!recipient || !recipient.fcmTokens || recipient.fcmTokens.length === 0) {
            return { sent: false, reason: 'no_tokens' };
        }

        // Build notification payload
        const messagePreview = message.messageType === 'image'
            ? '📷 Sent an image'
            : (message.text?.substring(0, 100) || 'New message');

        const payload = {
            title: sender.name,
            body: messagePreview,
            data: {
                type: 'chat_message',
                // Support both populated conversation and raw ID
                conversationId: conversation._id ? conversation._id.toString() : conversation.toString(),
                senderId: sender.id?.toString() || '',
                senderName: sender.name || '',
                senderAvatar: sender.avatar || '',
                messageType: message.messageType || 'text',
                listingId: conversation.listing?._id?.toString() || conversation.listing?.toString() || '',
                listingTitle: conversation.listing?.title || '',
                listingImage: conversation.listing?.images && conversation.listing.images.length > 0 
                    ? (conversation.listing.images[0].url || conversation.listing.images[0] || '').toString() 
                    : '',
                listingPrice: conversation.listing?.price?.toString() || '',
                sellerId: conversation.listing?.seller?.toString() || '',
            },
            badge: 1,
        };

        // Send to all user's devices
        const result = await sendToMultipleDevices(recipient.fcmTokens, payload);

        // Clean up invalid tokens
        if (result.invalidTokens.length > 0) {
            await User.findByIdAndUpdate(recipientId, {
                $pull: { fcmTokens: { $in: result.invalidTokens } },
            });
            console.log(`🧹 Cleaned ${result.invalidTokens.length} invalid FCM tokens`);
        }

        return {
            sent: result.successCount > 0,
            successCount: result.successCount,
            failureCount: result.failureCount,
        };
    } catch (error) {
        console.error('Chat notification error:', error);
        return { sent: false, reason: 'error', error: error.message };
    }
};

/**
 * Send notification for new listing match (future feature).
 *
 * NOTE: This is intentionally left as a stub in this template.
 * Saved searches / listing match notifications are not implemented
 * in the mobile app and are out of scope for the base product.
 */
const sendListingMatchNotification = async (userId, listing) => {
    return { sent: false, reason: 'not_implemented_in_template' };
};

/**
 * Send notification for order/transaction updates (future feature).
 *
 * NOTE: This is intentionally left as a stub in this template.
 * If you add transactions/orders later, you can implement this
 * using your FCM/notification provider.
 */
const sendTransactionNotification = async (userId, transaction, type) => {
    return { sent: false, reason: 'not_implemented_in_template' };
};

/**
 * Send offer-related push notification
 * @param {string} recipientId - User ID of the recipient
 * @param {object} offerData - { type, buyerName, amount, listingTitle, offerId, listingId }
 */
const sendOfferNotification = async (recipientId, offerData) => {
    if (!isFirebaseAvailable()) {
        return { sent: false, reason: 'firebase_not_available' };
    }

    try {
        const recipient = await User.findById(recipientId).select('fcmTokens');

        if (!recipient || !recipient.fcmTokens || recipient.fcmTokens.length === 0) {
            return { sent: false, reason: 'no_tokens' };
        }

        let title, body;
        switch (offerData.type) {
            case 'new_offer':
                title = '💰 New Offer Received';
                body = `${offerData.buyerName} offered $${offerData.amount.toFixed(2)} for "${offerData.listingTitle}"`;
                break;
            case 'offer_accepted':
                title = '🎉 Offer Accepted!';
                body = `Your offer of $${offerData.amount.toFixed(2)} for "${offerData.listingTitle}" was accepted!`;
                break;
            case 'offer_declined':
                title = 'Offer Declined';
                body = `Your offer for "${offerData.listingTitle}" was declined.`;
                break;
            case 'offer_countered':
                title = '🔄 Counter Offer';
                body = `Counter offer of $${offerData.amount.toFixed(2)} for "${offerData.listingTitle}"`;
                break;
            default:
                title = 'Offer Update';
                body = `Update on your offer for "${offerData.listingTitle}"`;
        }

        const payload = {
            title,
            body,
            data: {
                type: offerData.type,
                offerId: offerData.offerId,
                listingId: offerData.listingId,
                ...(offerData.conversationId && { conversationId: offerData.conversationId }),
                senderId: offerData.buyerId || '',
                senderName: offerData.buyerName || '',
            },
            badge: 1,
        };

        const result = await sendToMultipleDevices(recipient.fcmTokens, payload);

        if (result.invalidTokens.length > 0) {
            await User.findByIdAndUpdate(recipientId, {
                $pull: { fcmTokens: { $in: result.invalidTokens } },
            });
        }

        return {
            sent: result.successCount > 0,
            successCount: result.successCount,
            failureCount: result.failureCount,
        };
    } catch (error) {
        console.error('Offer notification error:', error);
        return { sent: false, reason: 'error', error: error.message };
    }
};

module.exports = {
    sendChatNotification,
    sendListingMatchNotification,
    sendTransactionNotification,
    sendOfferNotification,
};
