const express = require('express');
const router = express.Router();
const passport = require('passport');
const authController = require('../controllers/authController');
const { protect, verifyRefreshToken } = require('../middleware/auth');
const { validate, rules } = require('../middleware/validate');
const { uploadAvatar } = require('../config/cloudinary');

// Public routes
router.post('/register', rules.register, validate, authController.register);
router.post('/login', rules.login, validate, authController.login);
router.get('/verify/:token', authController.verifyEmail);
router.post('/forgot-password', rules.forgotPassword, validate, authController.forgotPassword);
router.post('/reset-password/:token', rules.resetPassword, validate, authController.resetPassword);
router.post('/refresh-token', verifyRefreshToken, authController.refreshToken);
router.get('/check-username/:username', authController.checkUsername);

// Google OAuth routes
router.get(
    '/google',
    passport.authenticate('google', { scope: ['profile', 'email'] })
);

router.get(
    '/google/callback',
    passport.authenticate('google', { session: false, failureRedirect: '/login' }),
    authController.googleCallback
);

router.post('/google/mobile', authController.googleMobile);

// Protected routes
router.use(protect);

router.post('/resend-verification', authController.resendVerification);
router.post('/logout', authController.logout);
router.get('/me', authController.getMe);
router.delete('/me', authController.deleteAccount);
router.put('/profile', authController.updateProfile);
router.put('/avatar', uploadAvatar, authController.updateAvatar);
router.put('/password', authController.changePassword);
router.put('/push-token', authController.updatePushToken);

module.exports = router;
