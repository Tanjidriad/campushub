const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const { protect } = require('../middleware/auth');
const { requireVerified } = require('../middleware/roles');
const { validate, rules } = require('../middleware/validate');

router.use(protect);
router.use(requireVerified);

router.get('/', rules.pagination, validate, notificationController.getNotifications);
router.get('/unread-count', notificationController.getUnreadCount);
router.put('/read', notificationController.markAsRead);
router.delete('/:id', rules.mongoId, validate, notificationController.deleteNotification);

module.exports = router;
