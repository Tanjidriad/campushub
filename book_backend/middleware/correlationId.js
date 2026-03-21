const { randomUUID } = require('crypto');

/**
 * Middleware that adds a unique correlation ID to every request.
 * - Checks for incoming `x-correlation-id` header (from upstream services)
 * - Falls back to generating a new UUID v4
 * - Attaches to response headers for tracing
 */
const correlationId = (req, res, next) => {
    const id = req.headers['x-correlation-id'] || randomUUID();
    req.correlationId = id;
    res.setHeader('x-correlation-id', id);
    next();
};

module.exports = correlationId;
