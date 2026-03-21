const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { protect } = require('../middleware/auth');
const { requireVerified } = require('../middleware/roles');
const { validate, rules } = require('../middleware/validate');

// Public routes
router.get('/search', rules.pagination, validate, userController.searchUsers);
router.get('/check-username/:username', userController.checkUsername);
router.get('/u/:username', userController.getUserByUsername);
router.get('/:id', rules.mongoId, validate, userController.getUserProfile);

// Protected routes
router.put('/username', protect, requireVerified, userController.setUsername);
router.post('/fcm-token', protect, requireVerified, userController.registerFcmToken);
router.delete('/fcm-token', protect, requireVerified, userController.removeFcmToken);

module.exports = router;
