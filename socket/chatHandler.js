const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Conversation = require('../models/Conversation');
const ChatMessage = require('../models/ChatMessage');
const { onlineUsers, typingUsers, isRedisAvailable } = require('../config/redisClient');
const { validateSocketEvent } = require('../middleware/socketValidation');
const { RateLimiterMemory } = require('rate-limiter-flexible');
const { sendChatNotification } = require('../utils/notificationService');
const { sanitizeMessage, checkSpamPatterns } = require('../utils/sanitize');
const { isBlocked } = require('../utils/blockedCache');
const { logChatEvent, logError, logSecurity } = require('../utils/logger');

// Rate limiter for socket events (10 messages per second per user)
const rateLimiter = new RateLimiterMemory({
    points: 10,
    duration: 1,
});

const chatHandler = (io) => {
    // Middleware: Authenticate socket connection
    io.use(async (socket, next) => {
        try {
            const token = socket.handshake.auth.token || socket.handshake.query.token;

            if (!token) {
                return next(new Error('Authentication required'));
            }

            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            const user = await User.findById(decoded.id).select('-password');

            if (!user) {
                return next(new Error('User not found'));
            }

            if (user.isBlocked) {
                return next(new Error('Account suspended'));
            }

            socket.user = user;
            next();
        } catch (error) {
            next(new Error('Invalid token'));
        }
    });

    io.on('connection', async (socket) => {
        const userId = socket.user._id.toString();
        logChatEvent('user:connected', { userId, userName: socket.user.name });

        // Add to online users (Redis or in-memory)
        await onlineUsers.add(userId, socket.id);

        // Broadcast online status
        socket.broadcast.emit('user:online', { userId });

        // Join user's personal room for notifications
        socket.join(`user:${userId}`);

        // ============== HELPER FUNCTIONS ==============

        // Rate limit check
        const checkRateLimit = async () => {
            try {
                await rateLimiter.consume(userId);
                return true;
            } catch {
                socket.emit('error', { message: 'Too many requests. Please slow down.' });
                return false;
            }
        };

        // Validate event data
        const validate = (eventName, data) => {
            const result = validateSocketEvent(eventName, data);
            if (!result.valid) {
                socket.emit('error', {
                    message: 'Validation failed',
                    errors: result.errors
                });
                return null;
            }
            return result.sanitizedData;
        };

        // ============== EVENTS ==============

        // Join conversation room
        socket.on('conversation:join', async (data) => {
            const validated = validate('conversation:join', data);
            if (!validated) return;

            const { conversationId } = validated;

            try {
                const conversation = await Conversation.findById(conversationId);

                if (!conversation || !conversation.participants.includes(socket.user._id)) {
                    return socket.emit('error', { message: 'Conversation not found' });
                }

                socket.join(`conversation:${conversationId}`);

                // Mark messages as delivered
                await ChatMessage.markDelivered(conversationId, userId);

                console.log(`📥 ${socket.user.name} joined conversation ${conversationId}`);
            } catch (error) {
                socket.emit('error', { message: 'Failed to join conversation' });
            }
        });

        // Leave conversation room
        socket.on('conversation:leave', async (data) => {
            const validated = validate('conversation:leave', data);
            if (!validated) return;

            const { conversationId } = validated;
            socket.leave(`conversation:${conversationId}`);

            // Remove from typing
            await typingUsers.stop(conversationId, userId);
            const typing = await typingUsers.getTyping(conversationId);
            io.to(`conversation:${conversationId}`).emit('typing:update', {
                conversationId,
                users: typing,
            });
        });

        // Send message
        socket.on('message:send', async (data) => {
            // Rate limit check
            if (!await checkRateLimit()) return;

            const validated = validate('message:send', data);
            if (!validated) return;

            const { conversationId, text, image } = validated;

            try {
                const conversation = await Conversation.findById(conversationId);

                if (!conversation || !conversation.participants.includes(socket.user._id)) {
                    return socket.emit('error', { message: 'Conversation not found' });
                }

                // Check if blocked (using cache)
                const otherParticipantId = conversation.participants.find(
                    p => p.toString() !== userId
                );

                const blocked = await isBlocked(userId, otherParticipantId.toString());
                if (blocked) {
                    return socket.emit('error', { message: 'Cannot message this user' });
                }

                // Sanitize message content
                let sanitizedText = null;
                if (text) {
                    // Check for spam patterns
                    const spamCheck = checkSpamPatterns(text);
                    if (spamCheck.isSpam) {
                        return socket.emit('error', {
                            message: 'Message flagged as spam',
                            reason: spamCheck.reason
                        });
                    }

                    // Sanitize the text
                    const { text: cleanText, truncated } = sanitizeMessage(text);
                    sanitizedText = cleanText;

                    if (!sanitizedText || sanitizedText.trim() === '') {
                        return socket.emit('error', { message: 'Message cannot be empty' });
                    }
                }

                // Create message
                const messageData = {
                    conversation: conversationId,
                    sender: socket.user._id,
                    messageType: 'text',
                };

                if (sanitizedText) messageData.text = sanitizedText;
                if (image) {
                    messageData.image = image;
                    messageData.messageType = image && sanitizedText ? 'text' : 'image';
                }

                const message = await ChatMessage.create(messageData);
                await message.populate('sender', 'name avatar');

                // Update conversation unread count and restore if was deleted
                conversation.incrementUnreadFor(userId);
                // Remove both participants from deletedFor so they can see the conversation again
                if (conversation.deletedFor && conversation.deletedFor.length > 0) {
                    conversation.deletedFor = [];
                }
                await conversation.save();

                // Emit to conversation room
                io.to(`conversation:${conversationId}`).emit('message:new', {
                    message: message.toObject(),
                    conversationId,
                });

                // Check if recipient is online
                const isRecipientOnline = await onlineUsers.isOnline(otherParticipantId.toString());

                // Don't send to self (sender === recipient check)
                const isSelfMessage = otherParticipantId.toString() === userId;

                // Emit to recipient's personal room for notification
                io.to(`user:${otherParticipantId}`).emit('message:notification', {
                    conversationId,
                    message: message.toObject(),
                    sender: {
                        id: socket.user._id,
                        name: socket.user.name,
                        avatar: socket.user.avatar,
                    },
                });

                // Send push notification (skip if sending to self)
                if (!isSelfMessage) {
                    sendChatNotification(
                        otherParticipantId.toString(),
                        {
                            id: socket.user._id,
                            name: socket.user.name,
                            avatar: socket.user.avatar,
                        },
                        {
                            text: messageData.text,
                            messageType: messageData.messageType,
                        },
                        conversationId
                    ).catch(err => console.error('Push notification failed:', err));
                }

                // Confirm delivery to sender
                socket.emit('message:sent', {
                    messageId: message._id,
                    conversationId,
                });

                // Stop typing indicator
                await typingUsers.stop(conversationId, userId);
                const typing = await typingUsers.getTyping(conversationId);
                io.to(`conversation:${conversationId}`).emit('typing:update', {
                    conversationId,
                    users: typing,
                });

            } catch (error) {
                console.error('Message send error:', error);
                socket.emit('error', { message: 'Failed to send message' });
            }
        });

        // Typing indicator
        socket.on('typing:start', async (data) => {
            const validated = validate('typing:start', data);
            if (!validated) return;

            const { conversationId } = validated;
            await typingUsers.start(conversationId, userId);
            const typing = await typingUsers.getTyping(conversationId);

            socket.to(`conversation:${conversationId}`).emit('typing:update', {
                conversationId,
                users: typing,
            });
        });

        socket.on('typing:stop', async (data) => {
            const validated = validate('typing:stop', data);
            if (!validated) return;

            const { conversationId } = validated;
            await typingUsers.stop(conversationId, userId);
            const typing = await typingUsers.getTyping(conversationId);

            socket.to(`conversation:${conversationId}`).emit('typing:update', {
                conversationId,
                users: typing,
            });
        });

        // Mark messages as read
        socket.on('message:read', async (data) => {
            const validated = validate('message:read', data);
            if (!validated) return;

            const { conversationId } = validated;

            try {
                await ChatMessage.markRead(conversationId, userId);

                const conversation = await Conversation.findById(conversationId);
                if (conversation) {
                    conversation.resetUnreadFor(userId);
                    await conversation.save();
                }

                // Notify other participants
                socket.to(`conversation:${conversationId}`).emit('message:read', {
                    conversationId,
                    readBy: userId,
                    readAt: new Date(),
                });
            } catch (error) {
                logError(error, { event: 'message:read', conversationId });
            }
        });

        // Check if user is online
        socket.on('user:check-online', async (data) => {
            const validated = validate('user:check-online', data);
            if (!validated) return;

            const { userIds } = validated;
            const onlineStatus = await onlineUsers.getOnlineStatus(userIds);
            socket.emit('user:online-status', onlineStatus);
        });

        // Disconnect
        socket.on('disconnect', async () => {
            logChatEvent('user:disconnected', { userId, userName: socket.user.name });

            // Remove socket from online users
            const isNowOffline = await onlineUsers.remove(userId, socket.id);

            if (isNowOffline) {
                socket.broadcast.emit('user:offline', { userId });
            }

            // Remove from all typing indicators
            const affectedConversations = await typingUsers.removeFromAll(userId);

            for (const convId of affectedConversations) {
                const typing = await typingUsers.getTyping(convId);
                io.to(`conversation:${convId}`).emit('typing:update', {
                    conversationId: convId,
                    users: typing,
                });
            }
        });
    });

    // Log Redis status
    const { logger } = require('../utils/logger');
    if (isRedisAvailable()) {
        logger.info({ type: 'startup', component: 'chat' }, 'Chat handler using Redis for state management');
    } else {
        logger.warn({ type: 'startup', component: 'chat' }, 'Chat handler using in-memory fallback (not scalable)');
    }

    return io;
};

module.exports = chatHandler;
