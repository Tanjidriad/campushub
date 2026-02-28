/**
 * Blocked Users Cache
 * Caches blocked user relationships in Redis to avoid DB queries on every message
 */
const { redis } = require('../config/redisClient');
const User = require('../models/User');

const BLOCKED_PREFIX = 'blocked:';
const BLOCKED_TTL = 300; // 5 minutes cache

/**
 * Check if user A has blocked user B (or vice versa)
 * Uses Redis cache with fallback to DB
 * @param {string} userA - First user ID
 * @param {string} userB - Second user ID
 * @returns {Promise<boolean>} - True if either user has blocked the other
 */
const isBlocked = async (userA, userB) => {
    // Normalize order for consistent cache keys
    const [id1, id2] = [userA, userB].sort();
    const cacheKey = `${BLOCKED_PREFIX}${id1}:${id2}`;

    // Try Redis first
    if (redis) {
        try {
            const cached = await redis.get(cacheKey);
            if (cached !== null) {
                return cached === '1';
            }
        } catch (error) {
            console.error('Redis cache error:', error.message);
        }
    }

    // Fallback to DB
    const [user1, user2] = await Promise.all([
        User.findById(id1).select('blockedUsers').lean(),
        User.findById(id2).select('blockedUsers').lean(),
    ]);

    const blocked =
        user1?.blockedUsers?.some(id => id.toString() === id2) ||
        user2?.blockedUsers?.some(id => id.toString() === id1) ||
        false;

    // Cache result
    if (redis) {
        try {
            await redis.setex(cacheKey, BLOCKED_TTL, blocked ? '1' : '0');
        } catch (error) {
            console.error('Redis cache set error:', error.message);
        }
    }

    return blocked;
};

/**
 * Invalidate blocked cache when user blocks/unblocks someone
 * @param {string} userA - User who performed the action
 * @param {string} userB - User who was blocked/unblocked
 */
const invalidateBlockedCache = async (userA, userB) => {
    if (!redis) return;

    const [id1, id2] = [userA, userB].sort();
    const cacheKey = `${BLOCKED_PREFIX}${id1}:${id2}`;

    try {
        await redis.del(cacheKey);
    } catch (error) {
        console.error('Redis cache invalidate error:', error.message);
    }
};

/**
 * Get all users blocked by a specific user (from cache or DB)
 * @param {string} userId - User ID
 * @returns {Promise<string[]>} - Array of blocked user IDs
 */
const getBlockedUsers = async (userId) => {
    const cacheKey = `${BLOCKED_PREFIX}list:${userId}`;

    // Try Redis first
    if (redis) {
        try {
            const cached = await redis.smembers(cacheKey);
            if (cached && cached.length > 0) {
                return cached;
            }
        } catch (error) {
            console.error('Redis cache error:', error.message);
        }
    }

    // Fallback to DB
    const user = await User.findById(userId).select('blockedUsers').lean();
    const blockedIds = (user?.blockedUsers || []).map(id => id.toString());

    // Cache result
    if (redis && blockedIds.length > 0) {
        try {
            await redis.sadd(cacheKey, ...blockedIds);
            await redis.expire(cacheKey, BLOCKED_TTL);
        } catch (error) {
            console.error('Redis cache set error:', error.message);
        }
    }

    return blockedIds;
};

/**
 * Invalidate blocked list cache for a user
 * @param {string} userId - User ID
 */
const invalidateBlockedList = async (userId) => {
    if (!redis) return;

    const cacheKey = `${BLOCKED_PREFIX}list:${userId}`;

    try {
        await redis.del(cacheKey);
    } catch (error) {
        console.error('Redis cache invalidate error:', error.message);
    }
};

module.exports = {
    isBlocked,
    invalidateBlockedCache,
    getBlockedUsers,
    invalidateBlockedList,
};
