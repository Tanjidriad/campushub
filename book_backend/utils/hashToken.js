/**
 * Hash a token using SHA-256.
 * Used to hash refresh tokens before storing in DB.
 * @param {string} token - Raw token string
 * @returns {string} - SHA-256 hex hash
 */
const crypto = require('crypto');

const hashToken = (token) => {
    if (!token) return null;
    return crypto.createHash('sha256').update(token).digest('hex');
};

module.exports = hashToken;
