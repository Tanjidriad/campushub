/**
 * Demo guard middleware (admin-only).
 *
 * When `req.user.isDemo === true`, block state-mutating HTTP methods (POST/PUT/PATCH/DELETE)
 * to keep the CodeCanyon demo environment stable and review-proof.
 */
const demoGuard = (req, res, next) => {
    const method = (req.method || '').toUpperCase();
    const isStateMutating = ['POST', 'PUT', 'PATCH', 'DELETE'].includes(method);

    if (!isStateMutating) return next();

    // Fail closed (only for mutations): if a user is unexpectedly missing, don't allow mutations.
    if (!req.user) {
        return res.status(401).json({
            success: false,
            message: 'Authentication required',
        });
    }

    const isDemo = req.user && req.user.isDemo === true;
    if (!isDemo) return next();

    return res.status(403).json({
        success: false,
        message: 'Action disabled in Demo Mode',
        code: 'DEMO_MODE',
    });
};

module.exports = { demoGuard };

