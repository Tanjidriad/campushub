const Notification = require('../models/Notification');
const { asyncHandler } = require('../middleware/errorHandler');
const { paginate, paginationMeta } = require('../utils/pagination');

// @desc    Get user's notifications
// @route   GET /api/notifications
// @access  Private
exports.getNotifications = asyncHandler(async (req, res) => {
    const { page, limit, unreadOnly } = req.query;
    const { skip, limit: limitNum, page: pageNum } = paginate(page, limit);

    const query = { user: req.user._id };
    if (unreadOnly === 'true') query.isRead = false;

    const [notifications, total, unreadCount] = await Promise.all([
        Notification.find(query)
            .sort('-createdAt')
            .skip(skip)
            .limit(limitNum)
            .lean(),
        Notification.countDocuments(query),
        Notification.getUnreadCount(req.user._id),
    ]);

    res.json({
        success: true,
        data: notifications,
        unreadCount,
        pagination: paginationMeta(total, pageNum, limitNum),
    });
});

// @desc    Mark notifications as read
// @route   PUT /api/notifications/read
// @access  Private
exports.markAsRead = asyncHandler(async (req, res) => {
    const { ids } = req.body;

    if (ids && ids.length > 0) {
        await Notification.markAsRead(req.user._id, ids);
    } else {
        await Notification.markAllAsRead(req.user._id);
    }

    res.json({
        success: true,
        message: 'Notifications marked as read',
    });
});

// @desc    Delete notification
// @route   DELETE /api/notifications/:id
// @access  Private
exports.deleteNotification = asyncHandler(async (req, res) => {
    const notification = await Notification.findOneAndDelete({
        _id: req.params.id,
        user: req.user._id,
    });

    if (!notification) {
        return res.status(404).json({
            success: false,
            message: 'Notification not found',
        });
    }

    res.json({
        success: true,
        message: 'Notification deleted',
    });
});

// @desc    Get unread count
// @route   GET /api/notifications/unread-count
// @access  Private
exports.getUnreadCount = asyncHandler(async (req, res) => {
    const count = await Notification.getUnreadCount(req.user._id);

    res.json({
        success: true,
        data: { count },
    });
});
