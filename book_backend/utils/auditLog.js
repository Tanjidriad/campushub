const AuditLog = require('../models/AuditLog');

/**
 * Log an admin action for audit trail.
 * Fire-and-forget — never blocks the main request.
 *
 * @param {Object} options
 * @param {string} options.action - Action name (e.g. 'listing_approved')
 * @param {string} options.performedBy - Admin user ID
 * @param {string} options.targetType - 'User' | 'Listing' | 'Report' | 'Category'
 * @param {string} options.targetId - Target document ID
 * @param {Object} [options.details] - Additional context
 * @param {string} [options.ip] - Request IP
 */
const logAudit = ({ action, performedBy, targetType, targetId, details = {}, ip }) => {
    AuditLog.create({
        action,
        performedBy,
        targetType,
        targetId,
        details,
        ip,
    }).catch((err) => {
        console.error('Audit log error:', err.message);
    });
};

module.exports = logAudit;
