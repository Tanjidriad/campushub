const Report = require('../models/Report');
const User = require('../models/User');
const Listing = require('../models/Listing');
const ChatMessage = require('../models/ChatMessage');
const { Notification } = require('../models');
const { asyncHandler } = require('../middleware/errorHandler');

// @desc    Create report
// @route   POST /api/reports
// @access  Private
exports.createReport = asyncHandler(async (req, res) => {
    const { targetType, targetId, reason, description } = req.body;

    // Determine target model and get the model reference
    let targetModel;
    let TargetModelRef;
    if (targetType === 'user') {
        targetModel = 'User';
        TargetModelRef = User;
    } else if (targetType === 'listing') {
        targetModel = 'Listing';
        TargetModelRef = Listing;
    } else if (targetType === 'message') {
        targetModel = 'ChatMessage';
        TargetModelRef = ChatMessage;
    } else {
        return res.status(400).json({
            success: false,
            message: 'Invalid target type',
        });
    }

    // Validate target exists
    const targetExists = await TargetModelRef.findById(targetId);
    if (!targetExists) {
        return res.status(404).json({
            success: false,
            message: `${targetType.charAt(0).toUpperCase() + targetType.slice(1)} not found`,
        });
    }

    // Prevent self-reporting (for user reports)
    if (targetType === 'user' && targetId === req.user._id.toString()) {
        return res.status(400).json({
            success: false,
            message: 'You cannot report yourself',
        });
    }

    // Prevent reporting own listing
    if (targetType === 'listing' && targetExists.seller.toString() === req.user._id.toString()) {
        return res.status(400).json({
            success: false,
            message: 'You cannot report your own listing',
        });
    }

    // Check for existing report
    const existingReport = await Report.findOne({
        reporter: req.user._id,
        targetType,
        targetId,
    });

    if (existingReport) {
        return res.status(400).json({
            success: false,
            message: 'You have already reported this item',
        });
    }

    const report = await Report.create({
        reporter: req.user._id,
        targetType,
        targetId,
        targetModel,
        reason,
        description,
    });

    // Notify all admin users about the new report
    const admins = await User.find({ role: { $in: ['admin', 'superadmin'] } }).select('_id').lean();
    const reporterName = req.user.name || 'A user';
    for (const admin of admins) {
        Notification.createNotification({
            userId: admin._id,
            type: 'new_report',
            title: 'New Report Submitted',
            body: `${reporterName} reported a ${targetType} for "${reason}"`,
            data: { reportId: report._id },
        }).catch(() => { }); // Fire-and-forget
    }

    res.status(201).json({
        success: true,
        message: 'Report submitted',
        data: report,
    });
});
