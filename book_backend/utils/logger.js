/**
 * Structured Logger using Pino
 * Fast, JSON-structured logging for production
 */
const pino = require('pino');

// Determine if pretty printing should be enabled
const isDev = process.env.NODE_ENV !== 'production';

// Base configuration
const baseConfig = {
    level: process.env.LOG_LEVEL || (isDev ? 'debug' : 'info'),
    base: {
        service: 'campushub-api',
        version: process.env.npm_package_version || '1.0.0',
    },
    timestamp: pino.stdTimeFunctions.isoTime,
    formatters: {
        level: (label) => ({ level: label }),
    },
};

// Create logger with pretty printing in dev
const logger = isDev
    ? pino({
        ...baseConfig,
        transport: {
            target: 'pino-pretty',
            options: {
                colorize: true,
                translateTime: 'HH:MM:ss',
                ignore: 'pid,hostname,service,version',
            },
        },
    })
    : pino(baseConfig);

/**
 * Create a child logger with additional context
 * @param {object} context - Additional context to include in logs
 * @returns {object} - Child logger
 */
const createChildLogger = (context) => {
    return logger.child(context);
};

/**
 * Log a request with structured data
 * @param {object} req - Express request object
 * @param {string} message - Log message
 */
const logRequest = (req, message) => {
    logger.info({
        type: 'request',
        method: req.method,
        url: req.originalUrl,
        userId: req.user?._id?.toString(),
        ip: req.ip,
    }, message);
};

/**
 * Log a chat event with structured data
 * @param {string} event - Event name
 * @param {object} data - Event data
 */
const logChatEvent = (event, data) => {
    logger.info({
        type: 'chat',
        event,
        ...data,
    }, `Chat event: ${event}`);
};

/**
 * Log an error with structured data
 * @param {Error} error - Error object
 * @param {object} context - Additional context
 */
const logError = (error, context = {}) => {
    logger.error({
        type: 'error',
        error: {
            message: error.message,
            stack: error.stack,
            name: error.name,
        },
        ...context,
    }, error.message);
};

/**
 * Log a security event
 * @param {string} event - Security event name
 * @param {object} data - Event data
 */
const logSecurity = (event, data) => {
    logger.warn({
        type: 'security',
        event,
        ...data,
    }, `Security event: ${event}`);
};

/**
 * Log a performance metric
 * @param {string} operation - Operation name
 * @param {number} durationMs - Duration in milliseconds
 * @param {object} data - Additional data
 */
const logPerformance = (operation, durationMs, data = {}) => {
    logger.info({
        type: 'performance',
        operation,
        durationMs,
        ...data,
    }, `Performance: ${operation} took ${durationMs}ms`);
};

module.exports = {
    logger,
    createChildLogger,
    logRequest,
    logChatEvent,
    logError,
    logSecurity,
    logPerformance,
};
