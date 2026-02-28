const { body, param, query, validationResult } = require('express-validator');
const Category = require('../models/Category');

// Validation result middleware
const validate = (req, res, next) => {
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
        const messages = errors.array().map(e => e.msg);
        return res.status(400).json({
            success: false,
            message: messages.length === 1 ? messages[0] : messages,
            errors: errors.array(),
        });
    }

    next();
};

// Common validation rules
const rules = {
    // Auth validations
    register: [
        body('email')
            .isEmail()
            .withMessage('Please enter a valid email')
            .normalizeEmail(),
        body('password')
            .isLength({ min: 6 })
            .withMessage('Password must be at least 6 characters'),
        body('name')
            .trim()
            .notEmpty()
            .withMessage('Name is required')
            .isLength({ max: 50 })
            .withMessage('Name cannot exceed 50 characters'),
    ],

    login: [
        body('email')
            .isEmail()
            .withMessage('Please enter a valid email')
            .normalizeEmail(),
        body('password')
            .notEmpty()
            .withMessage('Password is required'),
    ],

    forgotPassword: [
        body('email')
            .isEmail()
            .withMessage('Please enter a valid email')
            .normalizeEmail(),
    ],

    resetPassword: [
        body('password')
            .isLength({ min: 6 })
            .withMessage('Password must be at least 6 characters'),
    ],

    // Listing validations
    createListing: [
        body('title')
            .trim()
            .notEmpty()
            .withMessage('Title is required')
            .isLength({ max: 100 })
            .withMessage('Title cannot exceed 100 characters'),
        body('description')
            .trim()
            .notEmpty()
            .withMessage('Description is required')
            .isLength({ max: 2000 })
            .withMessage('Description cannot exceed 2000 characters'),
        body('category')
            .trim()
            .notEmpty()
            .withMessage('Category is required')
            .custom(async (value) => {
                const category = await Category.findOne({ slug: value, isActive: true });
                if (!category) {
                    throw new Error('Invalid or inactive category');
                }
                return true;
            }),
        body('priceType')
            .isIn(['fixed', 'negotiable', 'free', 'auction'])
            .withMessage('Invalid price type'),
        body('price')
            .if(body('priceType').not().equals('free'))
            .isNumeric()
            .withMessage('Price must be a number')
            .custom((value) => value >= 0)
            .withMessage('Price cannot be negative'),
        body('condition')
            .optional()
            .isIn(['new', 'like-new', 'good', 'fair', 'poor'])
            .withMessage('Invalid condition'),
    ],

    updateListing: [
        body('title')
            .optional()
            .trim()
            .isLength({ max: 100 })
            .withMessage('Title cannot exceed 100 characters'),
        body('description')
            .optional()
            .trim()
            .isLength({ max: 2000 })
            .withMessage('Description cannot exceed 2000 characters'),
        body('category')
            .optional()
            .trim()
            .custom(async (value) => {
                if (value) {
                    const category = await Category.findOne({ slug: value, isActive: true });
                    if (!category) {
                        throw new Error('Invalid or inactive category');
                    }
                }
                return true;
            }),
        body('priceType')
            .optional()
            .isIn(['fixed', 'negotiable', 'free', 'auction'])
            .withMessage('Invalid price type'),
        body('price')
            .optional()
            .isNumeric()
            .withMessage('Price must be a number'),
        body('condition')
            .optional()
            .isIn(['new', 'like-new', 'good', 'fair', 'poor'])
            .withMessage('Invalid condition'),
    ],

    // Review validations
    createReview: [
        body('rating')
            .isInt({ min: 1, max: 5 })
            .withMessage('Rating must be between 1 and 5'),
        body('comment')
            .optional()
            .trim()
            .isLength({ max: 500 })
            .withMessage('Comment cannot exceed 500 characters'),
    ],

    // Report validations
    createReport: [
        body('targetType')
            .notEmpty()
            .withMessage('Target type is required')
            .isIn(['user', 'listing', 'message'])
            .withMessage('Target type must be user, listing, or message'),
        body('targetId')
            .notEmpty()
            .withMessage('Target ID is required')
            .isMongoId()
            .withMessage('Invalid target ID format'),
        body('reason')
            .isIn(['spam', 'inappropriate', 'fraud', 'harassment', 'prohibited_item', 'wrong_category', 'duplicate', 'other'])
            .withMessage('Invalid reason'),
        body('description')
            .optional()
            .trim()
            .isLength({ max: 500 })
            .withMessage('Description cannot exceed 500 characters'),
    ],

    // Common validations
    mongoId: [
        param('id')
            .isMongoId()
            .withMessage('Invalid ID format'),
    ],

    pagination: [
        query('page')
            .optional()
            .isInt({ min: 1 })
            .withMessage('Page must be a positive integer'),
        query('limit')
            .optional()
            .isInt({ min: 1, max: 50 })
            .withMessage('Limit must be between 1 and 50'),
    ],
};

module.exports = { validate, rules };
