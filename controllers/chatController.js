const Conversation = require('../models/Conversation');
const ChatMessage = require('../models/ChatMessage');
const User = require('../models/User');
const Listing = require('../models/Listing');
const { asyncHandler } = require('../middleware/errorHandler');
const { paginate, paginationMeta } = require('../utils/pagination');
const { invalidateBlockedCache, invalidateBlockedList } = require('../utils/blockedCache');

// @desc    Get user's conversations
// @route   GET /api/chat/conversations
// @access  Private
exports.getConversations = asyncHandler(async (req, res) => {
    const { page, limit } = req.query;
    const { skip, limit: limitNum, page: pageNum } = paginate(page, limit);

    const [conversations, total] = await Promise.all([
        Conversation.find({
            participants: req.user._id,
            isActive: true,
            deletedFor: { $ne: req.user._id }, // Exclude conversations deleted by this user
        })
            .populate('participants', 'name avatar')
            .populate('listing', 'title price images status seller')
            .sort('-updatedAt')
            .skip(skip)
            .limit(limitNum)
            .lean(),
        Conversation.countDocuments({
            participants: req.user._id,
            isActive: true,
            deletedFor: { $ne: req.user._id },
        }),
    ]);

    // Add unread count and other participant info
    const formattedConversations = conversations.map(conv => {
        const otherParticipant = conv.participants.find(
            p => p._id.toString() !== req.user._id.toString()
        );

        return {
            ...conv,
            otherParticipant,
            unreadCount: conv.unreadCount?.[req.user._id.toString()] || 0,
        };
    });

    res.json({
        success: true,
        data: formattedConversations,
        pagination: paginationMeta(total, pageNum, limitNum),
    });
});

// @desc    Get or create conversation
// @route   POST /api/chat/conversations
// @access  Private
exports.createConversation = asyncHandler(async (req, res) => {
    const { listingId, sellerId } = req.body;

    // Validate listing exists
    const listing = await Listing.findById(listingId);
    if (!listing) {
        return res.status(404).json({
            success: false,
            message: 'Listing not found',
        });
    }

    // Can't chat with yourself
    if (sellerId === req.user._id.toString()) {
        return res.status(400).json({
            success: false,
            message: 'Cannot start conversation with yourself',
        });
    }

    // Check if blocked
    const seller = await User.findById(sellerId);
    if (req.user.blockedUsers.includes(sellerId) || seller.blockedUsers.includes(req.user._id)) {
        return res.status(403).json({
            success: false,
            message: 'Cannot message this user',
        });
    }

    // Find or create conversation
    const conversation = await Conversation.findOrCreate(
        req.user._id,
        sellerId,
        listingId
    );

    await conversation.populate('participants', 'name avatar');
    await conversation.populate('listing', 'title price images status seller');

    res.json({
        success: true,
        data: conversation,
    });
});

// @desc    Get messages in a conversation
// @route   GET /api/chat/conversations/:conversationId/messages
// @access  Private
exports.getMessages = asyncHandler(async (req, res) => {
    const { conversationId } = req.params;
    const { page, limit, before } = req.query;
    const { skip, limit: limitNum, page: pageNum } = paginate(page, limit);

    // Verify user is participant
    const conversation = await Conversation.findById(conversationId);
    if (!conversation || !conversation.participants.includes(req.user._id)) {
        return res.status(404).json({
            success: false,
            message: 'Conversation not found',
        });
    }

    // Build query
    const query = {
        conversation: conversationId,
        deletedFor: { $ne: req.user._id },
    };

    // For infinite scroll, get messages before a timestamp
    if (before) {
        query.createdAt = { $lt: new Date(before) };
    }

    const [messages, total] = await Promise.all([
        ChatMessage.find(query)
            .populate('sender', 'name avatar')
            .sort('-createdAt')
            .skip(skip)
            .limit(limitNum)
            .lean(),
        ChatMessage.countDocuments(query),
    ]);

    // Mark messages as read
    await ChatMessage.markRead(conversationId, req.user._id);

    // Reset unread count
    conversation.resetUnreadFor(req.user._id);
    await conversation.save();

    res.json({
        success: true,
        data: messages, // Return in descending order (Newest first) as expected by frontend
        pagination: paginationMeta(total, pageNum, limitNum),
    });
});

// @desc    Send a message (REST fallback)
// @route   POST /api/chat/conversations/:conversationId/messages
// @access  Private
exports.sendMessage = asyncHandler(async (req, res) => {
    const { conversationId } = req.params;
    const { text } = req.body;

    // Verify user is participant
    const conversation = await Conversation.findById(conversationId);
    if (!conversation || !conversation.participants.includes(req.user._id)) {
        return res.status(404).json({
            success: false,
            message: 'Conversation not found',
        });
    }

    // Check if blocked
    const otherParticipantId = conversation.participants.find(
        p => p.toString() !== req.user._id.toString()
    );
    const otherUser = await User.findById(otherParticipantId);

    if (req.user.blockedUsers.includes(otherParticipantId) ||
        otherUser.blockedUsers.includes(req.user._id)) {
        return res.status(403).json({
            success: false,
            message: 'Cannot message this user',
        });
    }

    // Create message
    const messageData = {
        conversation: conversationId,
        sender: req.user._id,
        text,
        messageType: 'text',
    };

    // Handle image upload
    if (req.file) {
        messageData.image = {
            url: req.file.path,
            publicId: req.file.filename,
        };
        messageData.messageType = 'image';
        if (text) messageData.messageType = 'text'; // Has both
    }

    const message = await ChatMessage.create(messageData);

    // Update conversation
    conversation.incrementUnreadFor(req.user._id);
    await conversation.save();

    await message.populate('sender', 'name avatar');

    res.status(201).json({
        success: true,
        data: message,
    });
});

// @desc    Upload chat image
// @route   POST /api/chat/conversations/:conversationId/images
// @access  Private
exports.uploadChatImage = asyncHandler(async (req, res) => {
    if (!req.file) {
        return res.status(400).json({
            success: false,
            message: 'Please upload an image',
        });
    }

    res.json({
        success: true,
        imageUrl: req.file.path,
        data: {
            url: req.file.path,
            publicId: req.file.filename,
        },
    });
});

// @desc    Mark messages as read
// @route   PUT /api/chat/conversations/:conversationId/read
// @access  Private
exports.markAsRead = asyncHandler(async (req, res) => {
    const { conversationId } = req.params;

    const conversation = await Conversation.findById(conversationId);
    if (!conversation || !conversation.participants.includes(req.user._id)) {
        return res.status(404).json({
            success: false,
            message: 'Conversation not found',
        });
    }

    await ChatMessage.markRead(conversationId, req.user._id);

    conversation.resetUnreadFor(req.user._id);
    await conversation.save();

    res.json({
        success: true,
        message: 'Messages marked as read',
    });
});

// @desc    Edit a message
// @route   PUT /api/chat/messages/:messageId
// @access  Private
exports.editMessage = asyncHandler(async (req, res) => {
    const { messageId } = req.params;
    const { text } = req.body;

    if (!text || text.trim() === '') {
        return res.status(400).json({
            success: false,
            message: 'Message text is required',
        });
    }

    const message = await ChatMessage.findById(messageId);

    if (!message) {
        return res.status(404).json({
            success: false,
            message: 'Message not found',
        });
    }

    // Only sender can edit
    if (message.sender.toString() !== req.user._id.toString()) {
        return res.status(403).json({
            success: false,
            message: 'You can only edit your own messages',
        });
    }

    // Can't edit after 15 minutes
    const fifteenMinutes = 15 * 60 * 1000;
    if (Date.now() - message.createdAt > fifteenMinutes) {
        return res.status(400).json({
            success: false,
            message: 'Cannot edit messages older than 15 minutes',
        });
    }

    // Can't edit image-only messages
    if (message.messageType === 'image' && !message.text) {
        return res.status(400).json({
            success: false,
            message: 'Cannot edit image-only messages',
        });
    }

    // Sanitize text
    const { sanitizeMessage } = require('../utils/sanitize');
    const { text: sanitizedText } = sanitizeMessage(text);

    message.text = sanitizedText;
    message.isEdited = true;
    message.editedAt = new Date();
    await message.save();

    res.json({
        success: true,
        message: 'Message updated',
        data: message,
    });
});

// @desc    Delete a message (soft delete for sender)
// @route   DELETE /api/chat/messages/:messageId
// @access  Private
exports.deleteMessage = asyncHandler(async (req, res) => {
    const { messageId } = req.params;
    const { forEveryone } = req.query;

    const message = await ChatMessage.findById(messageId);

    if (!message) {
        return res.status(404).json({
            success: false,
            message: 'Message not found',
        });
    }

    // Check if user is part of the conversation
    const conversation = await Conversation.findById(message.conversation);
    if (!conversation || !conversation.participants.includes(req.user._id)) {
        return res.status(403).json({
            success: false,
            message: 'Not authorized',
        });
    }

    // Delete for everyone (only sender can do this, within 1 hour)
    if (forEveryone === 'true') {
        if (message.sender.toString() !== req.user._id.toString()) {
            return res.status(403).json({
                success: false,
                message: 'Only sender can delete for everyone',
            });
        }

        const oneHour = 60 * 60 * 1000;
        if (Date.now() - message.createdAt > oneHour) {
            return res.status(400).json({
                success: false,
                message: 'Cannot delete for everyone after 1 hour',
            });
        }

        // Mark as deleted for all participants
        message.deletedFor = conversation.participants;
        message.isDeletedForEveryone = true;
        await message.save();

        return res.json({
            success: true,
            message: 'Message deleted for everyone',
        });
    }

    // Delete for self only
    if (!message.deletedFor.includes(req.user._id)) {
        message.deletedFor.push(req.user._id);
        await message.save();
    }

    res.json({
        success: true,
        message: 'Message deleted',
    });
});

// @desc    Delete conversation (hide from user)
// @route   DELETE /api/chat/conversations/:conversationId
// @access  Private
exports.deleteConversation = asyncHandler(async (req, res) => {
    const { conversationId } = req.params;

    const conversation = await Conversation.findById(conversationId);
    if (!conversation || !conversation.participants.includes(req.user._id)) {
        return res.status(404).json({
            success: false,
            message: 'Conversation not found',
        });
    }

    // Mark conversation as deleted for this user
    await Conversation.updateOne(
        { _id: conversationId },
        { $addToSet: { deletedFor: req.user._id } }
    );

    // Mark all messages as deleted for this user
    await ChatMessage.updateMany(
        { conversation: conversationId },
        { $addToSet: { deletedFor: req.user._id } }
    );

    res.json({
        success: true,
        message: 'Conversation deleted',
    });
});

// @desc    Block user
// @route   POST /api/chat/block/:userId
// @access  Private
exports.blockUser = asyncHandler(async (req, res) => {
    const { userId } = req.params;

    if (userId === req.user._id.toString()) {
        return res.status(400).json({
            success: false,
            message: 'Cannot block yourself',
        });
    }

    if (req.user.blockedUsers.includes(userId)) {
        return res.status(400).json({
            success: false,
            message: 'User already blocked',
        });
    }

    req.user.blockedUsers.push(userId);
    await req.user.save();

    // Invalidate cache
    await invalidateBlockedCache(req.user._id.toString(), userId);
    await invalidateBlockedList(req.user._id.toString());

    res.json({
        success: true,
        message: 'User blocked',
    });
});

// @desc    Unblock user
// @route   DELETE /api/chat/block/:userId
// @access  Private
exports.unblockUser = asyncHandler(async (req, res) => {
    const { userId } = req.params;

    const index = req.user.blockedUsers.indexOf(userId);
    if (index === -1) {
        return res.status(400).json({
            success: false,
            message: 'User not blocked',
        });
    }

    req.user.blockedUsers.splice(index, 1);
    await req.user.save();

    // Invalidate cache
    await invalidateBlockedCache(req.user._id.toString(), userId);
    await invalidateBlockedList(req.user._id.toString());

    res.json({
        success: true,
        message: 'User unblocked',
    });
});

// @desc    Get blocked users
// @route   GET /api/chat/blocked
// @access  Private
exports.getBlockedUsers = asyncHandler(async (req, res) => {
    const user = await User.findById(req.user._id)
        .populate('blockedUsers', 'name avatar');

    res.json({
        success: true,
        data: user.blockedUsers,
    });
});
