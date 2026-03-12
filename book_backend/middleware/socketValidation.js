/**
 * Socket Event Validation Middleware
 * Validates and sanitizes socket event data
 */
const validator = require('validator');
const mongoose = require('mongoose');

// Validation schemas
const schemas = {
    'message:send': {
        conversationId: { type: 'objectId', required: true },
        text: { type: 'string', maxLength: 2000 },
        image: { type: 'imageObject' },
        location: { type: 'locationObject' },
    },
    'conversation:join': {
        conversationId: { type: 'objectId', required: true },
    },
    'conversation:leave': {
        conversationId: { type: 'objectId', required: true },
    },
    'typing:start': {
        conversationId: { type: 'objectId', required: true },
    },
    'typing:stop': {
        conversationId: { type: 'objectId', required: true },
    },
    'message:read': {
        conversationId: { type: 'objectId', required: true },
    },
    'user:check-online': {
        userIds: { type: 'array', items: 'objectId', maxLength: 50 },
    },
};

/**
 * Validate a single field
 */
const validateField = (value, schema, fieldName) => {
    const errors = [];

    // Check required
    if (schema.required && (value === undefined || value === null || value === '')) {
        errors.push(`${fieldName} is required`);
        return { valid: false, errors, value: null };
    }

    // Skip if not provided and not required
    if (value === undefined || value === null) {
        return { valid: true, errors: [], value: null };
    }

    switch (schema.type) {
        case 'objectId':
            if (!mongoose.Types.ObjectId.isValid(value)) {
                errors.push(`${fieldName} must be a valid ID`);
            }
            break;

        case 'string':
            if (typeof value !== 'string') {
                errors.push(`${fieldName} must be a string`);
            } else {
                // Sanitize - escape HTML
                value = validator.escape(value.trim());

                if (schema.maxLength && value.length > schema.maxLength) {
                    errors.push(`${fieldName} exceeds maximum length of ${schema.maxLength}`);
                }

                if (schema.minLength && value.length < schema.minLength) {
                    errors.push(`${fieldName} must be at least ${schema.minLength} characters`);
                }
            }
            break;

        case 'imageObject':
            if (typeof value !== 'object') {
                errors.push(`${fieldName} must be an object`);
            } else {
                if (value.url && !validator.isURL(value.url, { protocols: ['https'] })) {
                    errors.push(`${fieldName}.url must be a valid HTTPS URL`);
                }
            }
            break;

        case 'locationObject':
            if (typeof value !== 'object') {
                errors.push(`${fieldName} must be an object`);
            } else {
                if (typeof value.latitude !== 'number' || value.latitude < -90 || value.latitude > 90) {
                    errors.push(`${fieldName}.latitude must be a number between -90 and 90`);
                }
                if (typeof value.longitude !== 'number' || value.longitude < -180 || value.longitude > 180) {
                    errors.push(`${fieldName}.longitude must be a number between -180 and 180`);
                }
            }
            break;

        case 'array':
            if (!Array.isArray(value)) {
                errors.push(`${fieldName} must be an array`);
            } else {
                if (schema.maxLength && value.length > schema.maxLength) {
                    errors.push(`${fieldName} exceeds maximum length of ${schema.maxLength}`);
                }

                if (schema.items === 'objectId') {
                    for (let i = 0; i < value.length; i++) {
                        if (!mongoose.Types.ObjectId.isValid(value[i])) {
                            errors.push(`${fieldName}[${i}] must be a valid ID`);
                        }
                    }
                }
            }
            break;
    }

    return { valid: errors.length === 0, errors, value };
};

/**
 * Validate socket event data against schema
 */
const validateSocketEvent = (eventName, data) => {
    const schema = schemas[eventName];

    if (!schema) {
        // Fail-closed: reject events without a defined schema
        return { valid: false, errors: [`Unknown or unvalidated event: ${eventName}`], sanitizedData: null };
    }

    if (!data || typeof data !== 'object') {
        return { valid: false, errors: ['Invalid data format'], sanitizedData: null };
    }

    const errors = [];
    const sanitizedData = {};

    // Validate each field in schema
    for (const [fieldName, fieldSchema] of Object.entries(schema)) {
        const result = validateField(data[fieldName], fieldSchema, fieldName);
        if (!result.valid) {
            errors.push(...result.errors);
        }
        if (result.value !== null) {
            sanitizedData[fieldName] = result.value;
        } else if (data[fieldName] !== undefined) {
            sanitizedData[fieldName] = data[fieldName];
        }
    }

    return {
        valid: errors.length === 0,
        errors,
        sanitizedData,
    };
};

/**
 * Create validation middleware for socket events
 */
const createSocketValidationMiddleware = (socket) => {
    return (eventName, data, callback) => {
        const result = validateSocketEvent(eventName, data);

        if (!result.valid) {
            console.warn(`Socket validation failed for ${eventName}:`, result.errors);
            socket.emit('error', {
                message: 'Validation failed',
                errors: result.errors,
            });
            return null;
        }

        return result.sanitizedData;
    };
};

module.exports = {
    validateSocketEvent,
    createSocketValidationMiddleware,
    schemas,
};
