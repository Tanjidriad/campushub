// Global error handler middleware

const errorHandler = (err, req, res, next) => {
    // Log error for debugging
    console.error('Error:', err);

    // Default error
    let statusCode = err.statusCode || 500;
    let message = err.message || 'Internal Server Error';

    // Mongoose validation error
    if (err.name === 'ValidationError') {
        statusCode = 400;
        const messages = Object.values(err.errors).map(e => e.message);
        message = messages.length === 1 ? messages[0] : messages;
    }

    // Mongoose duplicate key error
    if (err.code === 11000) {
        statusCode = 400;
        const field = Object.keys(err.keyValue)[0];
        message = `${field.charAt(0).toUpperCase() + field.slice(1)} already exists`;
    }

    // Mongoose cast error (invalid ObjectId)
    if (err.name === 'CastError') {
        statusCode = 400;
        message = 'Invalid ID format';
    }

    // JWT errors
    if (err.name === 'JsonWebTokenError') {
        statusCode = 401;
        message = 'Invalid token';
    }

    if (err.name === 'TokenExpiredError') {
        statusCode = 401;
        message = 'Token expired';
    }

    // Multer file upload errors
    if (err.name === 'MulterError') {
        statusCode = 400;
        if (err.code === 'LIMIT_FILE_SIZE') {
            message = 'File too large';
        } else if (err.code === 'LIMIT_FILE_COUNT') {
            message = 'Too many files';
        } else if (err.code === 'LIMIT_UNEXPECTED_FILE') {
            message = 'Unexpected file field';
        }
    }

    // In production, hide internal error messages for 500-level errors
    if (process.env.NODE_ENV === 'production' && statusCode >= 500) {
        message = 'Internal Server Error';
    }

    res.status(statusCode).json({
        success: false,
        message,
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    });
};

// Not found handler
const notFound = (req, res, next) => {
    res.status(404).json({
        success: false,
        message: `Route not found: ${req.originalUrl}`,
    });
};

// Async handler wrapper (eliminates try-catch in controllers)
const asyncHandler = (fn) => (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
};

module.exports = { errorHandler, notFound, asyncHandler };
