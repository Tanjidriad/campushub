const User = require('../models/User');
const Listing = require('../models/Listing');
const Report = require('../models/Report');
const { Notification, AuditLog } = require('../models');
const { asyncHandler } = require('../middleware/errorHandler');
const { paginate, paginationMeta } = require('../utils/pagination');
const { sendListingApprovedEmail, sendListingRejectedEmail } = require('../utils/sendEmail');
const escapeRegex = require('../utils/escapeRegex');
const logAudit = require('../utils/auditLog');
const { toCSV, sendCSV } = require('../utils/csvExport');

// ============== DASHBOARD ==============

// @desc    Get dashboard analytics
// @route   GET /api/admin/dashboard
// @access  Admin
exports.getDashboard = asyncHandler(async (req, res) => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const thisMonth = new Date(today.getFullYear(), today.getMonth(), 1);
    const lastMonth = new Date(today.getFullYear(), today.getMonth() - 1, 1);

    const [
        totalUsers,
        newUsersToday,
        newUsersThisMonth,
        totalListings,
        pendingListings,
        approvedListings,
        newListingsToday,
        pendingReports,
        usersByMonth,
        listingsByCategory,
    ] = await Promise.all([
        User.countDocuments({ role: 'student' }),
        User.countDocuments({ createdAt: { $gte: today } }),
        User.countDocuments({ createdAt: { $gte: thisMonth } }),
        Listing.countDocuments(),
        Listing.countDocuments({ status: 'pending' }),
        Listing.countDocuments({ status: 'approved' }),
        Listing.countDocuments({ createdAt: { $gte: today } }),
        Report.countDocuments({ status: 'pending' }),
        // Users growth by month (last 6 months)
        User.aggregate([
            { $match: { createdAt: { $gte: new Date(today.getFullYear(), today.getMonth() - 5, 1) } } },
            { $group: { _id: { $month: '$createdAt' }, count: { $sum: 1 } } },
            { $sort: { _id: 1 } },
        ]),
        // Listings by category
        Listing.aggregate([
            { $group: { _id: '$category', count: { $sum: 1 } } },
            { $sort: { count: -1 } },
        ]),
    ]);

    res.json({
        success: true,
        data: {
            users: {
                total: totalUsers,
                today: newUsersToday,
                thisMonth: newUsersThisMonth,
            },
            listings: {
                total: totalListings,
                pending: pendingListings,
                approved: approvedListings,
                today: newListingsToday,
            },
            reports: {
                pending: pendingReports,
            },
            charts: {
                usersByMonth,
                listingsByCategory,
            },
        },
    });
});

// ============== USER MANAGEMENT ==============

// @desc    Get recent activity for admin dashboard
// @route   GET /api/admin/activity
// @access  Admin
exports.getRecentActivity = asyncHandler(async (req, res) => {
    const limit = parseInt(req.query.limit) || 5;

    // Fetch recent activities from different sources in parallel
    const [recentUsers, recentListings, recentReports] = await Promise.all([
        // Recent user registrations
        User.find({ role: 'student' })
            .select('name email avatar createdAt')
            .sort('-createdAt')
            .limit(limit),

        // Recent listings (approved, pending, rejected)
        Listing.find()
            .select('title status seller createdAt updatedAt')
            .populate('seller', 'name')
            .sort('-updatedAt')
            .limit(limit),

        // Recent reports
        Report.find()
            .select('reason status targetType reporter createdAt')
            .populate('reporter', 'name')
            .sort('-createdAt')
            .limit(limit),
    ]);

    // Transform and combine activities into a unified format
    const activities = [];

    // Add user registrations
    recentUsers.forEach(user => {
        activities.push({
            id: user._id,
            type: 'user_registered',
            title: 'New User Registered',
            subtitle: user.name,
            icon: 'person_add',
            color: 'info',
            timestamp: user.createdAt,
        });
    });

    // Add listing activities
    recentListings.forEach(listing => {
        let title, icon, color;

        switch (listing.status) {
            case 'approved':
                title = 'Listing Approved';
                icon = 'check_circle';
                color = 'success';
                break;
            case 'rejected':
                title = 'Listing Rejected';
                icon = 'cancel';
                color = 'error';
                break;
            case 'pending':
                title = 'New Listing Pending';
                icon = 'pending';
                color = 'warning';
                break;
            default:
                title = 'Listing Updated';
                icon = 'edit';
                color = 'info';
        }

        activities.push({
            id: listing._id,
            type: `listing_${listing.status}`,
            title,
            subtitle: listing.title,
            icon,
            color,
            timestamp: listing.updatedAt,
        });
    });

    // Add report activities
    recentReports.forEach(report => {
        activities.push({
            id: report._id,
            type: 'report_created',
            title: `New ${report.targetType.charAt(0).toUpperCase() + report.targetType.slice(1)} Report`,
            subtitle: `Reported by ${report.reporter?.name || 'Unknown'}`,
            icon: 'flag',
            color: report.status === 'pending' ? 'warning' : 'info',
            timestamp: report.createdAt,
        });
    });

    // Sort all activities by timestamp (most recent first)
    activities.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

    // Return only the most recent ones
    const limitedActivities = activities.slice(0, limit);

    res.json({
        success: true,
        data: limitedActivities,
    });
});

// @desc    Get all users
// @route   GET /api/admin/users
// @access  Admin
exports.getUsers = asyncHandler(async (req, res) => {
    const { search, role, isBlocked, status, page, limit, sort = '-createdAt' } = req.query;

    // Allowlist sort fields to prevent arbitrary field injection
    const ALLOWED_SORT_FIELDS = ['createdAt', 'name', 'email', 'lastActive', '-createdAt', '-name', '-email', '-lastActive'];
    const safeSort = ALLOWED_SORT_FIELDS.includes(sort) ? sort : '-createdAt';
    const { skip, limit: limitNum, page: pageNum } = paginate(page, limit);

    const query = {};

    if (search) {
        const escaped = escapeRegex(search);
        query.$or = [
            { name: { $regex: escaped, $options: 'i' } },
            { email: { $regex: escaped, $options: 'i' } },
        ];
    }
    if (role) query.role = role;

    // Handle status filter: 'active', 'banned', 'offline'
    // Also support legacy isBlocked parameter
    if (status === 'banned') {
        query.isBlocked = true;
    } else if (status === 'active' || status === 'offline') {
        // For active/offline, we need to filter non-banned users first
        // Online status is calculated after fetching
        query.isBlocked = { $ne: true };
    } else if (isBlocked !== undefined) {
        query.isBlocked = isBlocked === 'true';
    }

    const [users, total] = await Promise.all([
        User.find(query)
            .select('-password -refreshToken -verificationToken -passwordResetToken')
            .sort(safeSort)
            .skip(skip)
            .limit(limitNum)
            .lean(),
        User.countDocuments(query),
    ]);

    // Determine online status based on lastActive (5 minutes threshold)
    const ONLINE_THRESHOLD = 5 * 60 * 1000; // 5 minutes
    const now = new Date();

    let usersWithStatus = users.map(user => {
        const lastActive = user.lastActive ? new Date(user.lastActive) : null;
        const isOnline = lastActive && (now - lastActive) < ONLINE_THRESHOLD;

        return {
            ...user,
            isOnline,
            lastActive: user.lastActive,
        };
    });

    // Further filter by online/offline status if needed
    if (status === 'active') {
        usersWithStatus = usersWithStatus.filter(u => u.isOnline === true);
    } else if (status === 'offline') {
        usersWithStatus = usersWithStatus.filter(u => u.isOnline === false);
    }

    // Calculate statistics for all users (not just current page)
    const [totalActive, totalBanned, totalAdmins] = await Promise.all([
        User.countDocuments({ isBlocked: { $ne: true } }),
        User.countDocuments({ isBlocked: true }),
        User.countDocuments({ role: 'admin' }),
    ]);

    res.json({
        success: true,
        data: usersWithStatus,
        pagination: paginationMeta(status === 'active' || status === 'offline' ? usersWithStatus.length : total, pageNum, limitNum),
        statistics: {
            total: await User.countDocuments({}),
            active: totalActive,
            banned: totalBanned,
            admins: totalAdmins,
        },
    });
});

// @desc    Get single user details
// @route   GET /api/admin/users/:id
// @access  Admin
exports.getUser = asyncHandler(async (req, res) => {
    const user = await User.findById(req.params.id)
        .select('-password -refreshToken')
        .lean();

    if (!user) {
        return res.status(404).json({
            success: false,
            message: 'User not found',
        });
    }

    // Get user's listings count
    const listingsCount = await Listing.countDocuments({ seller: user._id });

    res.json({
        success: true,
        data: {
            ...user,
            listingsCount,
        },
    });
});

// @desc    Ban/unban user
// @route   PUT /api/admin/users/:id/ban
// @access  Admin
exports.toggleBan = asyncHandler(async (req, res) => {
    const user = await User.findById(req.params.id);

    if (!user) {
        return res.status(404).json({
            success: false,
            message: 'User not found',
        });
    }

    // Can't ban admins (unless superadmin)
    if (['admin', 'superadmin'].includes(user.role) && req.user.role !== 'superadmin') {
        return res.status(403).json({
            success: false,
            message: 'Cannot ban admin users',
        });
    }

    const wasBanned = user.isBlocked;
    user.isBlocked = !user.isBlocked;

    let listingsAffected = 0;

    if (user.isBlocked) {
        // BANNING: Set offline and remove all their listings
        user.isOnline = false;

        const result = await Listing.updateMany(
            { seller: user._id, status: { $nin: ['removed', 'sold'] } },
            {
                $set: {
                    status: 'removed',
                    removedReason: 'Owner account banned',
                    removedAt: new Date(),
                    removedBy: req.user._id
                }
            }
        );
        listingsAffected = result.modifiedCount;
    } else {
        // UNBANNING: Restore listings that were removed due to ban
        const result = await Listing.updateMany(
            {
                seller: user._id,
                status: 'removed',
                removedReason: { $in: ['Owner account banned', 'Owner banned - all listings removed', 'User banned - all listings removed'] }
            },
            {
                $set: { status: 'approved' },
                $unset: { removedReason: '', removedAt: '', removedBy: '' }
            }
        );
        listingsAffected = result.modifiedCount;
    }

    await user.save();

    // Create notification
    await Notification.createNotification({
        userId: user._id,
        type: 'account_warning',
        title: user.isBlocked ? 'Account Suspended' : 'Account Restored',
        body: user.isBlocked
            ? 'Your account has been suspended. Contact support for more info.'
            : 'Your account has been restored. You can now use all features.',
    });

    // Return full user object (excluding sensitive fields)
    const userResponse = await User.findById(user._id)
        .select('-password -refreshToken -verificationToken -passwordResetToken')
        .lean();

    res.json({
        success: true,
        message: user.isBlocked
            ? `User banned and ${listingsAffected} listing(s) removed`
            : `User unbanned and ${listingsAffected} listing(s) restored`,
        data: userResponse,
    });

    // Audit log (fire-and-forget)
    logAudit({
        action: user.isBlocked ? 'user_banned' : 'user_unbanned',
        performedBy: req.user._id,
        targetType: 'User',
        targetId: user._id,
        details: { listingsAffected },
        ip: req.ip,
    });
});

// @desc    Change user role
// @route   PUT /api/admin/users/:id/role
// @access  SuperAdmin
exports.changeRole = asyncHandler(async (req, res) => {
    const { role } = req.body;

    if (!['student', 'admin', 'superadmin'].includes(role)) {
        return res.status(400).json({
            success: false,
            message: 'Invalid role',
        });
    }

    const user = await User.findByIdAndUpdate(
        req.params.id,
        { role },
        { new: true }
    ).select('-password -refreshToken');

    if (!user) {
        return res.status(404).json({
            success: false,
            message: 'User not found',
        });
    }

    res.json({
        success: true,
        data: user,
    });
});

// ============== LISTING MODERATION ==============

// @desc    Get all listings (admin view with search and filters)
// @route   GET /api/admin/listings
// @access  Admin
exports.getAllListings = asyncHandler(async (req, res) => {
    const {
        search,
        status,
        category,
        priceType,
        condition,
        isFeatured,
        minPrice,
        maxPrice,
        sellerId,
        page,
        limit,
        sort = '-createdAt'
    } = req.query;
    const ALLOWED_LISTING_SORTS = ['createdAt', 'title', 'price', 'updatedAt', '-createdAt', '-title', '-price', '-updatedAt'];
    const safeSort = ALLOWED_LISTING_SORTS.includes(sort) ? sort : '-createdAt';
    const { skip, limit: limitNum, page: pageNum } = paginate(page, limit);

    const query = {};

    // Search by title, description, or listing ID
    if (search) {
        const isObjectId = search.match(/^[0-9a-fA-F]{24}$/);
        if (isObjectId) {
            query._id = search;
        } else {
            query.$or = [
                { title: { $regex: escapeRegex(search), $options: 'i' } },
                { description: { $regex: escapeRegex(search), $options: 'i' } },
            ];
        }
    }

    // Filters
    if (status) query.status = status;
    if (category) query.category = category;
    if (priceType) query.priceType = priceType;
    if (condition) query.condition = condition;
    if (isFeatured !== undefined) query.isFeatured = isFeatured === 'true';
    if (sellerId) query.seller = sellerId;

    // Price range
    if (minPrice || maxPrice) {
        query.price = {};
        if (minPrice) query.price.$gte = parseFloat(minPrice);
        if (maxPrice) query.price.$lte = parseFloat(maxPrice);
    }

    const [listings, total, statistics] = await Promise.all([
        Listing.find(query)
            .populate('seller', 'name email avatar')
            .populate('approvedBy', 'name')
            .sort(safeSort)
            .skip(skip)
            .limit(limitNum)
            .lean(),
        Listing.countDocuments(query),
        // Get statistics
        Listing.aggregate([
            {
                $facet: {
                    byStatus: [
                        { $group: { _id: '$status', count: { $sum: 1 } } }
                    ],
                    byCategory: [
                        { $group: { _id: '$category', count: { $sum: 1 } } },
                        { $sort: { count: -1 } },
                        { $limit: 5 }
                    ],
                    total: [
                        { $count: 'count' }
                    ],
                    featured: [
                        { $match: { isFeatured: true } },
                        { $count: 'count' }
                    ]
                }
            }
        ])
    ]);

    // Format statistics
    const stats = {
        total: statistics[0].total[0]?.count || 0,
        pending: statistics[0].byStatus.find(s => s._id === 'pending')?.count || 0,
        approved: statistics[0].byStatus.find(s => s._id === 'approved')?.count || 0,
        rejected: statistics[0].byStatus.find(s => s._id === 'rejected')?.count || 0,
        featured: statistics[0].featured[0]?.count || 0,
        topCategories: statistics[0].byCategory,
    };

    res.json({
        success: true,
        data: listings,
        pagination: paginationMeta(total, pageNum, limitNum),
        statistics: stats,
    });
});

// @desc    Get pending listings
// @route   GET /api/admin/listings/pending
// @access  Admin
exports.getPendingListings = asyncHandler(async (req, res) => {
    const { page, limit } = req.query;
    const { skip, limit: limitNum, page: pageNum } = paginate(page, limit);

    const [listings, total] = await Promise.all([
        Listing.find({ status: 'pending' })
            .populate('seller', 'name email avatar')
            .sort('createdAt') // Oldest first
            .skip(skip)
            .limit(limitNum)
            .lean(),
        Listing.countDocuments({ status: 'pending' }),
    ]);

    res.json({
        success: true,
        data: listings,
        pagination: paginationMeta(total, pageNum, limitNum),
    });
});

// @desc    Approve listing
// @route   PUT /api/admin/listings/:id/approve
// @access  Admin
exports.approveListing = asyncHandler(async (req, res) => {
    const listing = await Listing.findById(req.params.id).populate('seller');

    if (!listing) {
        return res.status(404).json({
            success: false,
            message: 'Listing not found',
        });
    }

    listing.status = 'approved';
    listing.approvedBy = req.user._id;
    listing.approvedAt = new Date();
    listing.rejectionReason = undefined;
    await listing.save();

    // Send email notification
    await sendListingApprovedEmail(listing.seller, listing);

    // Create notification
    await Notification.createNotification({
        userId: listing.seller._id,
        type: 'listing_approved',
        title: 'Listing Approved! 🎉',
        body: `Your listing "${listing.title}" is now live`,
        data: { listingId: listing._id },
    });

    res.json({
        success: true,
        message: 'Listing approved',
        data: listing,
    });

    logAudit({
        action: 'listing_approved',
        performedBy: req.user._id,
        targetType: 'Listing',
        targetId: listing._id,
        details: { title: listing.title },
        ip: req.ip,
    });
});

// @desc    Reject listing
// @route   PUT /api/admin/listings/:id/reject
// @access  Admin
exports.rejectListing = asyncHandler(async (req, res) => {
    const { reason } = req.body;

    if (!reason) {
        return res.status(400).json({
            success: false,
            message: 'Rejection reason is required',
        });
    }

    const listing = await Listing.findById(req.params.id).populate('seller');

    if (!listing) {
        return res.status(404).json({
            success: false,
            message: 'Listing not found',
        });
    }

    listing.status = 'rejected';
    listing.rejectionReason = reason;
    await listing.save();

    // Send email notification
    await sendListingRejectedEmail(listing.seller, listing, reason);

    // Create notification
    await Notification.createNotification({
        userId: listing.seller._id,
        type: 'listing_rejected',
        title: 'Listing Needs Changes',
        body: `Your listing "${listing.title}" was not approved`,
        data: { listingId: listing._id },
    });

    res.json({
        success: true,
        message: 'Listing rejected',
        data: listing,
    });

    logAudit({
        action: 'listing_rejected',
        performedBy: req.user._id,
        targetType: 'Listing',
        targetId: listing._id,
        details: { title: listing.title, reason },
        ip: req.ip,
    });
});

// @desc    Delete listing (admin)
// @route   DELETE /api/admin/listings/:id
// @access  Admin
exports.deleteListing = asyncHandler(async (req, res) => {
    const listing = await Listing.findById(req.params.id);

    if (!listing) {
        return res.status(404).json({
            success: false,
            message: 'Listing not found',
        });
    }

    const { deleteImage } = require('../config/cloudinary');

    // Delete images from Cloudinary
    for (const image of listing.images) {
        await deleteImage(image.publicId);
    }

    await listing.deleteOne();

    logAudit({
        action: 'listing_deleted',
        performedBy: req.user._id,
        targetType: 'Listing',
        targetId: listing._id,
        details: { title: listing.title },
        ip: req.ip,
    });

    res.json({
        success: true,
        message: 'Listing deleted',
    });
});

// @desc    Feature/unfeature listing
// @route   PUT /api/admin/listings/:id/feature
// @access  Admin
exports.toggleFeature = asyncHandler(async (req, res) => {
    const listing = await Listing.findById(req.params.id);

    if (!listing) {
        return res.status(404).json({
            success: false,
            message: 'Listing not found',
        });
    }

    listing.isFeatured = !listing.isFeatured;
    await listing.save();

    res.json({
        success: true,
        message: listing.isFeatured ? 'Listing featured' : 'Listing unfeatured',
        data: { isFeatured: listing.isFeatured },
    });

    logAudit({
        action: listing.isFeatured ? 'listing_featured' : 'listing_unfeatured',
        performedBy: req.user._id,
        targetType: 'Listing',
        targetId: listing._id,
        ip: req.ip,
    });
});

// @desc    Bulk approve listings
// @route   POST /api/admin/listings/bulk-approve
// @access  Admin
exports.bulkApproveListings = asyncHandler(async (req, res) => {
    const { listingIds } = req.body;

    if (!Array.isArray(listingIds) || listingIds.length === 0) {
        return res.status(400).json({
            success: false,
            message: 'Please provide an array of listing IDs',
        });
    }

    // Find all listings
    const listings = await Listing.find({
        _id: { $in: listingIds },
        status: 'pending'
    }).populate('seller');

    if (listings.length === 0) {
        return res.status(404).json({
            success: false,
            message: 'No pending listings found',
        });
    }

    // Update all listings
    const updatePromises = listings.map(async (listing) => {
        listing.status = 'approved';
        listing.approvedBy = req.user._id;
        listing.approvedAt = new Date();
        listing.rejectionReason = undefined;
        await listing.save();

        // Send email notification
        await sendListingApprovedEmail(listing.seller, listing);

        // Create notification
        await Notification.createNotification({
            userId: listing.seller._id,
            type: 'listing_approved',
            title: 'Listing Approved! 🎉',
            body: `Your listing "${listing.title}" is now live`,
            data: { listingId: listing._id },
        });
    });

    await Promise.all(updatePromises);

    res.json({
        success: true,
        message: `${listings.length} listing(s) approved successfully`,
        data: { count: listings.length },
    });
});

// @desc    Bulk reject listings
// @route   POST /api/admin/listings/bulk-reject
// @access  Admin
exports.bulkRejectListings = asyncHandler(async (req, res) => {
    const { listingIds, reason } = req.body;

    if (!Array.isArray(listingIds) || listingIds.length === 0) {
        return res.status(400).json({
            success: false,
            message: 'Please provide an array of listing IDs',
        });
    }

    if (!reason) {
        return res.status(400).json({
            success: false,
            message: 'Rejection reason is required',
        });
    }

    // Find all listings
    const listings = await Listing.find({
        _id: { $in: listingIds },
        status: 'pending'
    }).populate('seller');

    if (listings.length === 0) {
        return res.status(404).json({
            success: false,
            message: 'No pending listings found',
        });
    }

    // Update all listings
    const updatePromises = listings.map(async (listing) => {
        listing.status = 'rejected';
        listing.rejectionReason = reason;
        await listing.save();

        // Send email notification
        await sendListingRejectedEmail(listing.seller, listing, reason);

        // Create notification
        await Notification.createNotification({
            userId: listing.seller._id,
            type: 'listing_rejected',
            title: 'Listing Needs Changes',
            body: `Your listing "${listing.title}" was not approved`,
            data: { listingId: listing._id },
        });
    });

    await Promise.all(updatePromises);

    res.json({
        success: true,
        message: `${listings.length} listing(s) rejected successfully`,
        data: { count: listings.length },
    });
});

// @desc    Bulk delete listings
// @route   POST /api/admin/listings/bulk-delete
// @access  Admin
exports.bulkDeleteListings = asyncHandler(async (req, res) => {
    const { listingIds } = req.body;

    if (!Array.isArray(listingIds) || listingIds.length === 0) {
        return res.status(400).json({
            success: false,
            message: 'Please provide an array of listing IDs',
        });
    }

    // Find all listings
    const listings = await Listing.find({ _id: { $in: listingIds } });

    if (listings.length === 0) {
        return res.status(404).json({
            success: false,
            message: 'No listings found',
        });
    }

    const { deleteImage } = require('../config/cloudinary');

    // Delete all listings and their images
    const deletePromises = listings.map(async (listing) => {
        // Delete images from Cloudinary
        for (const image of listing.images) {
            await deleteImage(image.publicId);
        }
        await listing.deleteOne();
    });

    await Promise.all(deletePromises);

    res.json({
        success: true,
        message: `${listings.length} listing(s) deleted successfully`,
        data: { count: listings.length },
    });
});

// ============== REPORTS ==============

// @desc    Get all reports
// @route   GET /api/admin/reports
// @access  Admin
exports.getReports = asyncHandler(async (req, res) => {
    const { status, targetType, page, limit } = req.query;
    const { skip, limit: limitNum, page: pageNum } = paginate(page, limit);

    const query = {};
    if (status) query.status = status;
    if (targetType) query.targetType = targetType;

    const [reports, total] = await Promise.all([
        Report.find(query)
            .populate('reporter', 'name email')
            .populate('reviewedBy', 'name')
            .sort('-createdAt')
            .skip(skip)
            .limit(limitNum)
            .lean(),
        Report.countDocuments(query),
    ]);

    // Optimized: Batch fetch targets instead of N+1 queries
    // Separate report IDs by target type
    const userTargetIds = [];
    const listingTargetIds = [];

    for (const report of reports) {
        if (report.targetType === 'user') {
            userTargetIds.push(report.targetId);
        } else if (report.targetType === 'listing') {
            listingTargetIds.push(report.targetId);
        }
    }

    // Batch fetch all targets in parallel (just 2 queries instead of N)
    const [userTargets, listingTargets] = await Promise.all([
        userTargetIds.length > 0
            ? User.find({ _id: { $in: userTargetIds } })
                .select('name email avatar')
                .lean()
            : Promise.resolve([]),
        listingTargetIds.length > 0
            ? Listing.find({ _id: { $in: listingTargetIds } })
                .select('title images')
                .lean()
            : Promise.resolve([]),
    ]);

    // Create lookup maps for O(1) access
    const userMap = new Map(userTargets.map(u => [u._id.toString(), u]));
    const listingMap = new Map(listingTargets.map(l => [l._id.toString(), l]));

    // Attach targets to reports
    for (const report of reports) {
        if (report.targetType === 'user') {
            report.target = userMap.get(report.targetId.toString()) || null;
        } else if (report.targetType === 'listing') {
            report.target = listingMap.get(report.targetId.toString()) || null;
        }
    }

    res.json({
        success: true,
        data: reports,
        pagination: paginationMeta(total, pageNum, limitNum),
    });
});

// @desc    Review report
// @route   PUT /api/admin/reports/:id
// @access  Admin
exports.reviewReport = asyncHandler(async (req, res) => {
    const { status, resolution, actionTaken } = req.body;

    const report = await Report.findById(req.params.id);

    if (!report) {
        return res.status(404).json({
            success: false,
            message: 'Report not found',
        });
    }

    // Perform the actual action based on actionTaken
    let actionResult = null;

    if (actionTaken === 'user_banned') {
        // Ban the user who was reported (if it's a user report)
        // Or ban the owner of the listing (if it's a listing report)
        let userToBan = null;
        let reportedListing = null;

        if (report.targetType === 'user') {
            userToBan = await User.findById(report.targetId);
        } else if (report.targetType === 'listing') {
            reportedListing = await Listing.findById(report.targetId);
            if (reportedListing) {
                userToBan = await User.findById(reportedListing.seller);
            }
        }

        if (userToBan) {
            // 1. Block the user
            userToBan.isBlocked = true;
            await userToBan.save();

            // 2. Remove ALL listings by this user
            const removedListings = await Listing.updateMany(
                { seller: userToBan._id, status: { $nin: ['removed', 'sold'] } },
                {
                    $set: {
                        status: 'removed',
                        removedReason: resolution || 'User banned - all listings removed',
                        removedAt: new Date(),
                        removedBy: req.user._id
                    }
                }
            );

            actionResult = {
                type: 'user_banned',
                userId: userToBan._id,
                userName: userToBan.name,
                listingsRemoved: removedListings.modifiedCount
            };
        }
    } else if (actionTaken === 'content_removed') {
        // Remove/delete the listing if it's a listing report
        if (report.targetType === 'listing') {
            const listing = await Listing.findById(report.targetId);
            if (listing) {
                // Soft delete - mark as removed instead of hard delete
                listing.status = 'removed';
                listing.removedReason = resolution || 'Removed due to report violation';
                listing.removedAt = new Date();
                listing.removedBy = req.user._id;
                await listing.save();
                actionResult = { type: 'content_removed', listingId: listing._id, listingTitle: listing.title };
            }
        }
    } else if (actionTaken === 'warning') {
        // Send a warning notification to the user
        let userToWarn = null;

        if (report.targetType === 'user') {
            userToWarn = await User.findById(report.targetId);
        } else if (report.targetType === 'listing') {
            const listing = await Listing.findById(report.targetId);
            if (listing) {
                userToWarn = await User.findById(listing.seller);
            }
        }

        if (userToWarn) {
            // Create a notification for the user (if Notification model exists)
            try {
                const Notification = require('../models/Notification');
                await Notification.create({
                    user: userToWarn._id,
                    type: 'warning',
                    title: 'Warning from Admin',
                    message: resolution || 'You have received a warning regarding a report filed against you. Please review our community guidelines.',
                });
                actionResult = { type: 'warning_sent', userId: userToWarn._id, userName: userToWarn.name };
            } catch (e) {
                // Notification model might not exist, just log warning
                actionResult = { type: 'warning_logged', userId: userToWarn._id };
            }
        }
    }

    // Update the report record
    report.status = status || 'reviewed';
    report.resolution = resolution;
    report.actionTaken = actionTaken || 'none';
    report.reviewedBy = req.user._id;
    report.reviewedAt = new Date();
    await report.save();

    // Build a detailed success message based on the action taken
    let message = `Report ${status} successfully`;
    if (actionResult) {
        if (actionResult.type === 'user_banned') {
            message = `User "${actionResult.userName}" has been banned and ${actionResult.listingsRemoved} listing(s) have been removed`;
        } else if (actionResult.type === 'content_removed') {
            message = `Listing "${actionResult.listingTitle}" has been removed`;
        } else if (actionResult.type === 'warning_sent') {
            message = `Warning sent to user "${actionResult.userName}"`;
        } else {
            message = `Report ${status} and action "${actionTaken}" executed successfully`;
        }
    }

    res.json({
        success: true,
        data: report,
        actionResult,
        message,
    });

    logAudit({
        action: 'report_reviewed',
        performedBy: req.user._id,
        targetType: 'Report',
        targetId: report._id,
        details: { status, actionTaken, resolution },
        ip: req.ip,
    });
});

// ============== AUDIT LOG ==============

// @desc    Get audit logs
// @route   GET /api/admin/audit-logs
// @access  Admin
exports.getAuditLogs = asyncHandler(async (req, res) => {
    const { action, performedBy, page, limit } = req.query;
    const { skip, limit: limitNum, page: pageNum } = paginate(page, limit);

    const query = {};
    if (action) query.action = action;
    if (performedBy) query.performedBy = performedBy;

    const [logs, total] = await Promise.all([
        AuditLog.find(query)
            .populate('performedBy', 'name email avatar')
            .sort('-createdAt')
            .skip(skip)
            .limit(limitNum)
            .lean(),
        AuditLog.countDocuments(query),
    ]);

    res.json({
        success: true,
        data: logs,
        pagination: paginationMeta(total, pageNum, limitNum),
    });
});

// ============== DATA EXPORT ==============

// @desc    Export users as CSV
// @route   GET /api/admin/export/users
// @access  Admin
exports.exportUsers = asyncHandler(async (req, res) => {
    const users = await User.find()
        .select('name email username role isBlocked isOnline lastActive createdAt')
        .lean();

    const data = users.map((u) => ({
        Name: u.name,
        Email: u.email,
        Username: u.username || '',
        Role: u.role,
        Blocked: u.isBlocked ? 'Yes' : 'No',
        Online: u.isOnline ? 'Yes' : 'No',
        'Last Active': u.lastActive ? new Date(u.lastActive).toISOString() : '',
        'Registered At': new Date(u.createdAt).toISOString(),
    }));

    const csv = toCSV(data);
    sendCSV(res, csv, `campushub-users-${Date.now()}.csv`);
});

// @desc    Export listings as CSV
// @route   GET /api/admin/export/listings
// @access  Admin
exports.exportListings = asyncHandler(async (req, res) => {
    const listings = await Listing.find()
        .populate('seller', 'name email')
        .select('title price priceType condition status seller category createdAt')
        .lean();

    const data = listings.map((l) => ({
        Title: l.title,
        Price: l.price || '',
        'Price Type': l.priceType,
        Condition: l.condition,
        Status: l.status,
        Category: l.category || '',
        'Seller Name': l.seller?.name || '',
        'Seller Email': l.seller?.email || '',
        'Created At': new Date(l.createdAt).toISOString(),
    }));

    const csv = toCSV(data);
    sendCSV(res, csv, `campushub-listings-${Date.now()}.csv`);
});

// ============== DETAIL ENDPOINTS ==============

// @desc    Get single listing detail (admin)
// @route   GET /api/admin/listings/:id
// @access  Admin
exports.getListingDetail = asyncHandler(async (req, res) => {
    const listing = await Listing.findById(req.params.id)
        .populate('seller', 'name email avatar phone')
        .populate('approvedBy', 'name email')
        .lean();

    if (!listing) {
        return res.status(404).json({
            success: false,
            message: 'Listing not found',
        });
    }

    res.json({
        success: true,
        data: listing,
    });
});

// @desc    Get single report detail (admin)
// @route   GET /api/admin/reports/:id
// @access  Admin
exports.getReportDetail = asyncHandler(async (req, res) => {
    const report = await Report.findById(req.params.id)
        .populate('reporter', 'name email avatar')
        .populate('reviewedBy', 'name email')
        .lean();

    if (!report) {
        return res.status(404).json({
            success: false,
            message: 'Report not found',
        });
    }

    // Populate the target based on type
    if (report.targetType === 'user') {
        report.target = await User.findById(report.targetId)
            .select('name email avatar isBlocked')
            .lean();
    } else if (report.targetType === 'listing') {
        report.target = await Listing.findById(report.targetId)
            .select('title images price status seller')
            .populate('seller', 'name email')
            .lean();
    }

    res.json({
        success: true,
        data: report,
    });
});
