const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { protect } = require('../middleware/auth');
const { validate, rules } = require('../middleware/validate');

// Public routes
router.get('/search', rules.pagination, validate, userController.searchUsers);
router.get('/check-username/:username', userController.checkUsername);
router.get('/u/:username', userController.getUserByUsername);
router.get('/:id', rules.mongoId, validate, userController.getUserProfile);

// Protected routes
router.put('/username', protect, userController.setUsername);
router.post('/fcm-token', protect, userController.registerFcmToken);
router.delete('/fcm-token', protect, userController.removeFcmToken);

module.exports = router;
