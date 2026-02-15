// Role-based access control middleware

// Require specific roles
const requireRole = (...roles) => {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({
                success: false,
                message: 'Authentication required',
            });
        }

        if (!roles.includes(req.user.role)) {
            return res.status(403).json({
                success: false,
                message: 'Access denied. Insufficient permissions.',
            });
        }

        next();
    };
};

// Require admin access (admin or superadmin)
const requireAdmin = (req, res, next) => {
    if (!req.user) {
        return res.status(401).json({
            success: false,
            message: 'Authentication required',
        });
    }

    if (!['admin', 'superadmin'].includes(req.user.role)) {
        return res.status(403).json({
            success: false,
            message: 'Admin access required',
        });
    }

    next();
};

// Require superadmin access only
const requireSuperAdmin = (req, res, next) => {
    if (!req.user) {
        return res.status(401).json({
            success: false,
            message: 'Authentication required',
        });
    }

    if (req.user.role !== 'superadmin') {
        return res.status(403).json({
            success: false,
            message: 'Super admin access required',
        });
    }

    next();
};

// Require verified email
const requireVerified = (req, res, next) => {
    if (!req.user) {
        return res.status(401).json({
            success: false,
            message: 'Authentication required',
        });
    }

    if (!req.user.isVerified) {
        return res.status(403).json({
            success: false,
            message: 'Email verification required',
            code: 'EMAIL_NOT_VERIFIED',
        });
    }

    next();
};

module.exports = {
    requireRole,
    requireAdmin,
    requireSuperAdmin,
    requireVerified,
};
