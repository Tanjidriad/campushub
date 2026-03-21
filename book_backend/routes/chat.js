const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const { protect } = require('../middleware/auth');
const { requireVerified } = require('../middleware/roles');
const { uploadChatImage } = require('../config/cloudinary');
const { validate, rules } = require('../middleware/validate');

// All routes require authentication
router.use(protect);
router.use(requireVerified);

// Conversations
router.get('/conversations', rules.pagination, validate, chatController.getConversations);
router.post('/conversations', chatController.createConversation);

// Messages
router.get('/conversations/:conversationId/messages', rules.pagination, validate, chatController.getMessages);
router.post('/conversations/:conversationId/messages', uploadChatImage, chatController.sendMessage);
router.post('/conversations/:conversationId/images', uploadChatImage, chatController.uploadChatImage);
router.put('/conversations/:conversationId/read', chatController.markAsRead);
router.put('/messages/:messageId', chatController.editMessage);
router.delete('/messages/:messageId', chatController.deleteMessage);
router.delete('/conversations/:conversationId', chatController.deleteConversation);

// Blocking
router.get('/blocked', chatController.getBlockedUsers);
router.post('/block/:userId', chatController.blockUser);
router.delete('/block/:userId', chatController.unblockUser);

module.exports = router;
