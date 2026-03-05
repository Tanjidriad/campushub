const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Generate access token
const generateAccessToken = (userId) => {
    return jwt.sign({ id: userId }, process.env.JWT_SECRET, {
        expiresIn: process.env.JWT_EXPIRES_IN || '1h',
    });
};

// Generate refresh token
const generateRefreshToken = (userId) => {
    return jwt.sign({ id: userId }, process.env.JWT_REFRESH_SECRET, {
        expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d',
    });
};

// Generate both tokens
const generateTokens = (userId) => {
    return {
        accessToken: generateAccessToken(userId),
        refreshToken: generateRefreshToken(userId),
    };
};

module.exports = { generateAccessToken, generateRefreshToken, generateTokens };
