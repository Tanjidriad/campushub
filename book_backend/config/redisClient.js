/**
 * Redis Client Configuration
 * Uses Upstash Redis or local Redis for:
 * - Online users tracking
 * - Typing indicators
 * - Rate limiting
 * - Cross-server pub/sub
 */
const Redis = require('ioredis');

// Create Redis client
const createRedisClient = () => {
    const redisUrl = process.env.REDIS_URL;

    if (!redisUrl) {
        console.warn('⚠️  REDIS_URL not set. Using in-memory fallback (not recommended for production)');
        return null;
    }

    const redis = new Redis(redisUrl, {
        maxRetriesPerRequest: 3,
        retryDelayOnFailover: 100,
        lazyConnect: true,
        enableReadyCheck: true,
        connectTimeout: 10000,
    });

    redis.on('connect', () => {
        console.log('🔴 Redis connected');
    });

    redis.on('error', (err) => {
        console.error('Redis error:', err.message);
    });

    redis.on('close', () => {
        console.log('Redis connection closed');
    });

    return redis;
};

// Main Redis client
const redis = createRedisClient();

// Pub/Sub clients (separate connections required)
const pubClient = redis ? redis.duplicate() : null;
const subClient = redis ? redis.duplicate() : null;

// ============== ONLINE USERS ==============

const ONLINE_PREFIX = 'chat:online:';
const ONLINE_TTL = 300; // 5 minutes

const onlineUsers = {
    /**
     * Add a socket to user's online set
     */
    async add(userId, socketId) {
        if (!redis) return;
        const key = `${ONLINE_PREFIX}${userId}`;
        await redis.sadd(key, socketId);
        await redis.expire(key, ONLINE_TTL);
    },

    /**
     * Remove a socket from user's online set
     */
    async remove(userId, socketId) {
        if (!redis) return;
        const key = `${ONLINE_PREFIX}${userId}`;
        await redis.srem(key, socketId);

        // Check if user has no more sockets
        const remaining = await redis.scard(key);
        if (remaining === 0) {
            await redis.del(key);
            return true; // User is now offline
        }
        return false;
    },

    /**
     * Check if user is online
     */
    async isOnline(userId) {
        if (!redis) return false;
        const key = `${ONLINE_PREFIX}${userId}`;
        const count = await redis.scard(key);
        return count > 0;
    },

    /**
     * Get online status for multiple users
     */
    async getOnlineStatus(userIds) {
        if (!redis) return {};
        const pipeline = redis.pipeline();
        userIds.forEach(id => {
            pipeline.scard(`${ONLINE_PREFIX}${id}`);
        });
        const results = await pipeline.exec();
        const status = {};
        userIds.forEach((id, index) => {
            status[id] = (results[index][1] || 0) > 0;
        });
        return status;
    },

    /**
     * Refresh user's TTL (heartbeat)
     */
    async refresh(userId) {
        if (!redis) return;
        const key = `${ONLINE_PREFIX}${userId}`;
        await redis.expire(key, ONLINE_TTL);
    },
};

// ============== TYPING INDICATORS ==============

const TYPING_PREFIX = 'chat:typing:';
const TYPING_TTL = 10; // 10 seconds

const typingUsers = {
    /**
     * Add user to typing set for a conversation
     */
    async start(conversationId, userId) {
        if (!redis) return;
        const key = `${TYPING_PREFIX}${conversationId}`;
        await redis.sadd(key, userId);
        await redis.expire(key, TYPING_TTL);
    },

    /**
     * Remove user from typing set
     */
    async stop(conversationId, userId) {
        if (!redis) return;
        const key = `${TYPING_PREFIX}${conversationId}`;
        await redis.srem(key, userId);
    },

    /**
     * Get all users typing in a conversation
     */
    async getTyping(conversationId) {
        if (!redis) return [];
        const key = `${TYPING_PREFIX}${conversationId}`;
        return await redis.smembers(key);
    },

    /**
     * Remove user from all typing indicators
     */
    async removeFromAll(userId) {
        if (!redis) return [];
        const affectedConversations = [];

        // Use SCAN instead of KEYS to avoid blocking Redis
        const stream = redis.scanStream({ match: `${TYPING_PREFIX}*`, count: 100 });
        const keys = [];
        await new Promise((resolve) => {
            stream.on('data', (batch) => keys.push(...batch));
            stream.on('end', resolve);
        });

        for (const key of keys) {
            const removed = await redis.srem(key, userId);
            if (removed > 0) {
                affectedConversations.push(key.replace(TYPING_PREFIX, ''));
            }
        }

        return affectedConversations;
    },
};

// ============== IN-MEMORY FALLBACK ==============

// Fallback for when Redis is not available
const MAX_FALLBACK_ENTRIES = 10000; // Prevent unbounded memory growth
const inMemoryOnline = new Map();
const inMemoryTyping = new Map();

const fallbackOnlineUsers = {
    async add(userId, socketId) {
        if (inMemoryOnline.size >= MAX_FALLBACK_ENTRIES && !inMemoryOnline.has(userId)) return;
        if (!inMemoryOnline.has(userId)) {
            inMemoryOnline.set(userId, new Set());
        }
        inMemoryOnline.get(userId).add(socketId);
    },
    async remove(userId, socketId) {
        const sockets = inMemoryOnline.get(userId);
        if (sockets) {
            sockets.delete(socketId);
            if (sockets.size === 0) {
                inMemoryOnline.delete(userId);
                return true;
            }
        }
        return false;
    },
    async isOnline(userId) {
        return inMemoryOnline.has(userId) && inMemoryOnline.get(userId).size > 0;
    },
    async getOnlineStatus(userIds) {
        const status = {};
        userIds.forEach(id => {
            status[id] = inMemoryOnline.has(id) && inMemoryOnline.get(id).size > 0;
        });
        return status;
    },
    async refresh() { },
};

const fallbackTypingUsers = {
    async start(conversationId, userId) {
        if (inMemoryTyping.size >= MAX_FALLBACK_ENTRIES && !inMemoryTyping.has(conversationId)) return;
        if (!inMemoryTyping.has(conversationId)) {
            inMemoryTyping.set(conversationId, new Set());
        }
        inMemoryTyping.get(conversationId).add(userId);
    },
    async stop(conversationId, userId) {
        const typing = inMemoryTyping.get(conversationId);
        if (typing) typing.delete(userId);
    },
    async getTyping(conversationId) {
        return Array.from(inMemoryTyping.get(conversationId) || []);
    },
    async removeFromAll(userId) {
        const affected = [];
        for (const [convId, users] of inMemoryTyping.entries()) {
            if (users.has(userId)) {
                users.delete(userId);
                affected.push(convId);
            }
        }
        return affected;
    },
};

module.exports = {
    redis,
    pubClient,
    subClient,
    onlineUsers: redis ? onlineUsers : fallbackOnlineUsers,
    typingUsers: redis ? typingUsers : fallbackTypingUsers,
    isRedisAvailable: () => !!redis,
};
