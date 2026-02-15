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
 * @param {string} conversationId - Conversation ID
 */
const sendChatNotification = async (recipientId, sender, message, conversationId) => {
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
                conversationId: conversationId.toString(),
                senderId: sender.id?.toString() || '',
                senderName: sender.name,
                messageType: message.messageType || 'text',
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
 * Send notification for new listing match (future feature)
 */
const sendListingMatchNotification = async (userId, listing) => {
    // TODO: Implement when adding saved searches feature
};

/**
 * Send notification for order/transaction updates (future feature)
 */
const sendTransactionNotification = async (userId, transaction, type) => {
    // TODO: Implement when adding transactions
};

module.exports = {
    sendChatNotification,
    sendListingMatchNotification,
    sendTransactionNotification,
};
