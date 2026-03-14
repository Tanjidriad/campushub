const crypto = require('crypto');
const User = require('../models/User');
const Listing = require('../models/Listing');
const { generateTokens } = require('../utils/generateToken');
const hashToken = require('../utils/hashToken');
const { sendVerificationEmail, sendPasswordResetEmail } = require('../utils/sendEmail');
const { asyncHandler } = require('../middleware/errorHandler');

// @desc    Register new user
// @route   POST /api/auth/register
// @access  Public
exports.register = asyncHandler(async (req, res) => {
    const { email, password, name } = req.body;

    // Check if user exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
        return res.status(400).json({
            success: false,
            message: 'Email already registered',
        });
    }

    // Create user
    const user = await User.create({
        email,
        password,
        name,
    });

    // Generate verification token
    const verificationToken = user.generateVerificationToken();
    await user.save();

    // Send verification email
    await sendVerificationEmail(user, verificationToken);

    // Generate tokens
    const tokens = generateTokens(user._id);
    user.refreshToken = hashToken(tokens.refreshToken);
    await user.save();

    res.status(201).json({
        success: true,
        message: 'Registration successful. Please verify your email.',
        data: {
            user: {
                id: user._id,
                email: user.email,
                name: user.name,
                role: user.role,
                isVerified: user.isVerified,
            },
            ...tokens,
        },
    });
});

// @desc    Login user
// @route   POST /api/auth/login
// @access  Public
exports.login = asyncHandler(async (req, res) => {
    const { email, password } = req.body;

    // Find user with password
    const user = await User.findOne({ email }).select('+password');

    if (!user) {
        return res.status(401).json({
            success: false,
            message: 'Invalid credentials',
        });
    }

    // Check if user is blocked
    if (user.isBlocked) {
        return res.status(403).json({
            success: false,
            message: 'Your account has been suspended',
        });
    }

    // Check if user has password (might be Google-only account)
    if (!user.password) {
        return res.status(401).json({
            success: false,
            message: 'Please login with Google',
        });
    }

    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
        return res.status(401).json({
            success: false,
            message: 'Invalid credentials',
        });
    }

    // Generate tokens
    const tokens = generateTokens(user._id);
    user.refreshToken = hashToken(tokens.refreshToken);
    await user.save();

    res.json({
        success: true,
        data: {
            user: {
                id: user._id,
                email: user.email,
                name: user.name,
                avatar: user.avatar,
                role: user.role,
                isVerified: user.isVerified,
            },
            ...tokens,
        },
    });
});

// @desc    Verify email
// @route   GET /api/auth/verify/:token
// @access  Public
exports.verifyEmail = asyncHandler(async (req, res) => {
    const hashedToken = crypto
        .createHash('sha256')
        .update(req.params.token)
        .digest('hex');

    const user = await User.findOne({
        verificationToken: hashedToken,
        verificationTokenExpires: { $gt: Date.now() },
    });

    if (!user) {
        // Return HTML error page for browser access
        return res.status(400).send(`
            <!DOCTYPE html>
            <html>
            <head>
                <title>Verification Failed</title>
                <style>
                    body { font-family: Arial, sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background: #f5f5f5; }
                    .container { text-align: center; padding: 40px; background: white; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); max-width: 400px; }
                    .icon { font-size: 60px; margin-bottom: 20px; }
                    h1 { color: #ef4444; margin-bottom: 16px; }
                    p { color: #666; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="icon">❌</div>
                    <h1>Verification Failed</h1>
                    <p>Invalid or expired verification token. Please request a new verification email from the app.</p>
                </div>
            </body>
            </html>
        `);
    }

    user.isVerified = true;
    user.verificationToken = undefined;
    user.verificationTokenExpires = undefined;
    await user.save();

    // Return HTML success page for browser access
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Email Verified!</title>
            <style>
                body { font-family: Arial, sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background: #f5f5f5; }
                .container { text-align: center; padding: 40px; background: white; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); max-width: 400px; }
                .icon { font-size: 60px; margin-bottom: 20px; }
                h1 { color: #22c55e; margin-bottom: 16px; }
                p { color: #666; }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="icon">✅</div>
                <h1>Email Verified!</h1>
                <p>Your email has been verified successfully. You can now close this page and log in to the app.</p>
            </div>
        </body>
        </html>
    `);
});

// @desc    Resend verification email
// @route   POST /api/auth/resend-verification
// @access  Private
exports.resendVerification = asyncHandler(async (req, res) => {
    const user = await User.findById(req.user.id);

    if (user.isVerified) {
        return res.status(400).json({
            success: false,
            message: 'Email already verified',
        });
    }

    const verificationToken = user.generateVerificationToken();
    await user.save();

    await sendVerificationEmail(user, verificationToken);

    res.json({
        success: true,
        message: 'Verification email sent',
    });
});

// @desc    Forgot password
// @route   POST /api/auth/forgot-password
// @access  Public
exports.forgotPassword = asyncHandler(async (req, res) => {
    const user = await User.findOne({ email: req.body.email });

    if (!user) {
        // Don't reveal if email exists
        return res.json({
            success: true,
            message: 'If an account exists, a reset email has been sent',
        });
    }

    const resetToken = user.generatePasswordResetToken();
    await user.save();

    await sendPasswordResetEmail(user, resetToken);

    res.json({
        success: true,
        message: 'If an account exists, a reset email has been sent',
    });
});

// @desc    Reset password
// @route   POST /api/auth/reset-password/:token
// @access  Public
exports.resetPassword = asyncHandler(async (req, res) => {
    const hashedToken = crypto
        .createHash('sha256')
        .update(req.params.token)
        .digest('hex');

    const user = await User.findOne({
        passwordResetToken: hashedToken,
        passwordResetExpires: { $gt: Date.now() },
    });

    if (!user) {
        return res.status(400).json({
            success: false,
            message: 'Invalid or expired reset token',
        });
    }

    user.password = req.body.password;
    user.passwordResetToken = undefined;
    user.passwordResetExpires = undefined;
    await user.save();

    res.json({
        success: true,
        message: 'Password reset successful',
    });
});

// @desc    Refresh access token (with rotation — old refresh token is invalidated)
// @route   POST /api/auth/refresh-token
// @access  Public
exports.refreshToken = asyncHandler(async (req, res) => {
    // req.user is set by verifyRefreshToken middleware
    // Rotate: generate brand-new token pair and invalidate the old refresh token
    const tokens = generateTokens(req.user._id);
    req.user.refreshToken = hashToken(tokens.refreshToken);
    await req.user.save();

    res.json({
        success: true,
        data: tokens,
    });
});

// @desc    Logout
// @route   POST /api/auth/logout
// @access  Private
exports.logout = asyncHandler(async (req, res) => {
    req.user.refreshToken = undefined;
    req.user.isOnline = false;
    await req.user.save();

    res.json({
        success: true,
        message: 'Logged out successfully',
    });
});

// @desc    Get current user
// @route   GET /api/auth/me
// @access  Private
exports.getMe = asyncHandler(async (req, res) => {
    const user = await User.findById(req.user.id)
        .select('-password -refreshToken -verificationToken -passwordResetToken');

    // Only activeListings needs a live count — totalListings & totalSold are already
    // denormalized onto the User document and updated incrementally, so no extra queries needed.
    const activeListings = await Listing.countDocuments({ seller: req.user.id, status: 'approved' });

    res.json({
        success: true,
        data: {
            ...user.toObject(),
            activeListings,
            totalSold: user.totalSold,
            totalListings: user.totalListings,
        },
    });
});

// @desc    Update profile
// @route   PUT /api/auth/profile
// @access  Private
exports.updateProfile = asyncHandler(async (req, res) => {
    const { name, username, phone, bio, location } = req.body;

    // If username is being updated, check if it's already taken
    if (username) {
        const existingUser = await User.findOne({
            username: username.toLowerCase(),
            _id: { $ne: req.user.id } // Exclude current user
        });

        if (existingUser) {
            return res.status(400).json({
                success: false,
                message: 'Username is already taken',
            });
        }
    }

    const updateData = {};
    if (name !== undefined) updateData.name = name;
    if (username !== undefined) updateData.username = username.toLowerCase();
    if (phone !== undefined) updateData.phone = phone;
    if (bio !== undefined) updateData.bio = bio;
    if (location !== undefined) updateData.location = location;

    const user = await User.findByIdAndUpdate(
        req.user.id,
        updateData,
        { new: true, runValidators: true }
    ).select('-password -refreshToken');

    res.json({
        success: true,
        data: user,
    });
});

// @desc    Check if username is available
// @route   GET /api/auth/check-username/:username
// @access  Public
exports.checkUsername = asyncHandler(async (req, res) => {
    const { username } = req.params;

    // Validate username format
    const usernameRegex = /^[a-z0-9_]+$/;
    if (!usernameRegex.test(username.toLowerCase())) {
        return res.status(400).json({
            success: false,
            available: false,
            message: 'Username can only contain letters, numbers, and underscores',
        });
    }

    if (username.length < 3) {
        return res.status(400).json({
            success: false,
            available: false,
            message: 'Username must be at least 3 characters',
        });
    }

    if (username.length > 20) {
        return res.status(400).json({
            success: false,
            available: false,
            message: 'Username cannot exceed 20 characters',
        });
    }

    const existingUser = await User.findOne({ username: username.toLowerCase() });

    res.json({
        success: true,
        available: !existingUser,
        message: existingUser ? 'Username is already taken' : 'Username is available',
    });
});

// @desc    Update avatar
// @route   PUT /api/auth/avatar
// @access  Private
exports.updateAvatar = asyncHandler(async (req, res) => {
    if (!req.file) {
        return res.status(400).json({
            success: false,
            message: 'Please upload an image',
        });
    }

    const user = await User.findByIdAndUpdate(
        req.user.id,
        { avatar: req.file.path },
        { new: true }
    ).select('-password -refreshToken');

    res.json({
        success: true,
        data: user,
    });
});

// @desc    Change password
// @route   PUT /api/auth/password
// @access  Private
exports.changePassword = asyncHandler(async (req, res) => {
    const { currentPassword, newPassword } = req.body;

    const user = await User.findById(req.user.id).select('+password');

    if (user.password) {
        const isMatch = await user.comparePassword(currentPassword);
        if (!isMatch) {
            return res.status(400).json({
                success: false,
                message: 'Current password is incorrect',
            });
        }
    }

    user.password = newPassword;
    await user.save();

    res.json({
        success: true,
        message: 'Password changed successfully',
    });
});

// @desc    Update push token
// @route   PUT /api/auth/push-token
// @access  Private
exports.updatePushToken = asyncHandler(async (req, res) => {
    const { pushToken } = req.body;

    await User.findByIdAndUpdate(req.user.id, { pushToken });

    res.json({
        success: true,
        message: 'Push token updated',
    });
});

// @desc    Google OAuth callback
// @route   GET /api/auth/google/callback
// @access  Public
exports.googleCallback = asyncHandler(async (req, res) => {
    // req.user is set by Passport
    const tokens = generateTokens(req.user._id);
    req.user.refreshToken = hashToken(tokens.refreshToken);
    await req.user.save();

    // Redirect to app with tokens via a bridge page (avoids leaking tokens in URL)
    const appUrl = (process.env.APP_URL || '').replace(/["'<>]/g, '');
    res.send(`
        <!DOCTYPE html>
        <html>
        <head><title>Redirecting...</title></head>
        <body>
            <p>Signing you in...</p>
            <script>
                var url = ${JSON.stringify(appUrl)} + 'auth/callback?accessToken=' + encodeURIComponent(${JSON.stringify(tokens.accessToken)}) + '&refreshToken=' + encodeURIComponent(${JSON.stringify(tokens.refreshToken)});
                window.location.href = url;
            </script>
        </body>
        </html>
    `);
});


// @desc    Delete account
// @route   DELETE /api/auth/me
// @access  Private
exports.deleteAccount = asyncHandler(async (req, res) => {
    const { password } = req.body;

    const user = await User.findById(req.user.id).select('+password');

    if (!user) {
        return res.status(404).json({
            success: false,
            message: 'User not found',
        });
    }

    // Require re-authentication: password for email users, skip for Google-only
    if (user.password) {
        if (!password) {
            return res.status(400).json({
                success: false,
                message: 'Password is required to delete your account',
            });
        }

        const isMatch = await user.comparePassword(password);
        if (!isMatch) {
            return res.status(401).json({
                success: false,
                message: 'Incorrect password',
            });
        }
    }

    // Delete all listings by this user
    await Listing.deleteMany({ seller: user._id });

    // Delete the user
    await user.deleteOne();

    res.json({
        success: true,
        message: 'Account deleted successfully',
    });
});
