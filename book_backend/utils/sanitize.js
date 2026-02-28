/**
 * Content Sanitization Utility
 * Prevents XSS attacks and cleans user-generated content
 */
const xss = require('xss');

// XSS filter options
const xssOptions = {
    whiteList: {}, // No HTML tags allowed
    stripIgnoreTag: true, // Remove unknown tags
    stripIgnoreTagBody: ['script', 'style'], // Remove script/style completely
};

// Create custom XSS filter
const xssFilter = new xss.FilterXSS(xssOptions);

/**
 * Sanitize text content (removes all HTML)
 * @param {string} text - User input text
 * @returns {string} - Sanitized text
 */
const sanitizeText = (text) => {
    if (!text || typeof text !== 'string') return '';

    // Trim and normalize whitespace
    let sanitized = text.trim();

    // Remove null bytes
    sanitized = sanitized.replace(/\0/g, '');

    // Apply XSS filter
    sanitized = xssFilter.process(sanitized);

    // Decode HTML entities that might have been double-encoded
    sanitized = sanitized
        .replace(/&amp;/g, '&')
        .replace(/&lt;/g, '<')
        .replace(/&gt;/g, '>')
        .replace(/&quot;/g, '"')
        .replace(/&#x27;/g, "'");

    // Re-escape for safety
    sanitized = sanitized
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;');

    return sanitized;
};

/**
 * Sanitize message content for chat
 * Allows emojis and basic text, removes HTML
 * @param {string} message - Chat message
 * @param {number} maxLength - Maximum length (default 2000)
 * @returns {object} - { text, truncated }
 */
const sanitizeMessage = (message, maxLength = 2000) => {
    if (!message || typeof message !== 'string') {
        return { text: '', truncated: false };
    }

    let text = sanitizeText(message);

    // Check for truncation
    const truncated = text.length > maxLength;
    if (truncated) {
        text = text.substring(0, maxLength);
    }

    return { text, truncated };
};

/**
 * Sanitize username/display name
 * More restrictive than general text
 * @param {string} name - Username or display name
 * @returns {string} - Sanitized name
 */
const sanitizeName = (name) => {
    if (!name || typeof name !== 'string') return '';

    // Remove any HTML/special chars, keep alphanumeric, spaces, underscores
    return name
        .trim()
        .replace(/<[^>]*>/g, '') // Remove HTML tags
        .replace(/[^\w\s\u00C0-\u024F\u1E00-\u1EFF]/g, '') // Keep letters, numbers, spaces
        .substring(0, 50);
};

/**
 * Sanitize URL (for image URLs, etc.)
 * @param {string} url - URL to sanitize
 * @returns {string|null} - Sanitized URL or null if invalid
 */
const sanitizeUrl = (url) => {
    if (!url || typeof url !== 'string') return null;

    try {
        const parsed = new URL(url);

        // Only allow https
        if (parsed.protocol !== 'https:') {
            return null;
        }

        // Block javascript: and data: schemes (shouldn't reach here but double-check)
        if (parsed.protocol === 'javascript:' || parsed.protocol === 'data:') {
            return null;
        }

        return parsed.href;
    } catch {
        return null;
    }
};

/**
 * Check for spam patterns
 * @param {string} text - Text to check
 * @returns {object} - { isSpam, reason }
 */
const checkSpamPatterns = (text) => {
    if (!text) return { isSpam: false, reason: null };

    // Repeated characters (more than 10 of the same char)
    if (/(.)\1{10,}/i.test(text)) {
        return { isSpam: true, reason: 'repeated_characters' };
    }

    // Too many URLs (more than 3)
    const urlCount = (text.match(/https?:\/\//g) || []).length;
    if (urlCount > 3) {
        return { isSpam: true, reason: 'too_many_urls' };
    }

    // All caps (more than 80% caps in messages over 20 chars)
    if (text.length > 20) {
        const capsRatio = (text.match(/[A-Z]/g) || []).length / text.length;
        if (capsRatio > 0.8) {
            return { isSpam: true, reason: 'excessive_caps' };
        }
    }

    return { isSpam: false, reason: null };
};

module.exports = {
    sanitizeText,
    sanitizeMessage,
    sanitizeName,
    sanitizeUrl,
    checkSpamPatterns,
};
