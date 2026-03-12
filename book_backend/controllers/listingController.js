const mongoose = require('mongoose');
const Listing = require('../models/Listing');
const User = require('../models/User');
const Offer = require('../models/Offer');
const { Notification } = require('../models');
const Category = require('../models/Category');
const { asyncHandler } = require('../middleware/errorHandler');
const { paginate, paginationMeta } = require('../utils/pagination');
const { deleteImage, getPublicIdFromUrl } = require('../config/cloudinary');
const SearchService = require('../utils/searchService');
const { sendOfferNotification } = require('../utils/notificationService');

// @desc    Get all listings (with filters)
// @route   GET /api/listings
// @access  Public
exports.getListings = asyncHandler(async (req, res) => {
    const {
        category,
        priceType,
        condition,
        minPrice,
        maxPrice,
        search,
        sort = '-createdAt',
        page,
        limit,
        sellerId,
        isFeatured,
        sortBy,
        sortOrder,
        // Education filters
        educationLevel,
        classOrSemester,
        subject,
        bookType,
        // BD location filters
        division,
        district,
        upazila,
    } = req.query;

    // Build standard filters
    const filters = {};
    if (category) filters.category = category;
    if (priceType) filters.priceType = priceType;
    if (condition) filters.condition = condition;
    if (sellerId) filters.seller = new mongoose.Types.ObjectId(sellerId);
    if (minPrice) filters.minPrice = minPrice;
    if (maxPrice) filters.maxPrice = maxPrice;
    if (isFeatured === 'true') {
        filters.isFeatured = true;
        // Only show featured listings that haven't expired
        // (featuredUntil is null for admin-curated, or in the future for self-promoted)
        filters.$or = [
            { featuredUntil: null },
            { featuredUntil: { $gt: new Date() } },
        ];
    }
    if (educationLevel) filters.educationLevel = educationLevel;
    if (classOrSemester) filters.classOrSemester = classOrSemester;
    if (subject) filters.subject = { $regex: subject, $options: 'i' };
    if (bookType) filters.bookType = bookType;
    if (division) filters.division = division;
    if (district) filters.district = district;
    if (upazila) filters.upazila = upazila;

    // Determine sort parameter
    let sortParam = sort;
    if (sortBy) {
        sortParam = sortOrder === 'desc' ? `-${sortBy}` : sortBy;
    }

    // Pagination setup
    const { skip, limit: limitNum, page: pageNum } = paginate(page, limit);

    // Use SearchService
    const { listings, total } = await SearchService.searchListings(
        search,
        filters,
        { skip, limit: limitNum },
        sortParam
    );

    // Add isWishlisted flag if user is authenticated
    if (req.user) {
        const wishlistIds = req.user.wishlist.map(id => id.toString());
        listings.forEach(listing => {
            listing.isWishlisted = wishlistIds.includes(listing._id.toString());
        });
    }

    res.json({
        success: true,
        data: listings,
        pagination: paginationMeta(total, pageNum, limitNum),
    });
});

// @desc    Get single listing
// @route   GET /api/listings/:id
// @access  Public
exports.getListing = asyncHandler(async (req, res) => {
    const listing = await Listing.findById(req.params.id)
        .populate('seller', 'name avatar phone averageRating totalReviews createdAt');

    if (!listing) {
        return res.status(404).json({
            success: false,
            message: 'Listing not found',
        });
    }

    // Increment view count (unless owner is viewing)
    if (!req.user || req.user._id.toString() !== listing.seller._id.toString()) {
        listing.views += 1;
        await listing.save();
    }

    // Add isWishlisted flag
    let isWishlisted = false;
    if (req.user) {
        isWishlisted = req.user.wishlist.some(
            id => id.toString() === listing._id.toString()
        );
    }

    res.json({
        success: true,
        data: {
            ...listing.toObject(),
            isWishlisted,
        },
    });
});

// @desc    Create listing
// @route   POST /api/listings
// @access  Private
exports.createListing = asyncHandler(async (req, res) => {
    const { title, description, category, priceType, price, condition, location, tags,
        educationLevel, classOrSemester, subject, bookType, division, district, upazila } = req.body;

    // Validate category exists and is active
    const categoryExists = await Category.findOne({ slug: category, isActive: true });
    if (!categoryExists) {
        return res.status(400).json({
            success: false,
            message: 'Invalid or inactive category',
        });
    }

    // Process uploaded images
    const images = req.files?.map(file => ({
        url: file.path,
        publicId: file.filename,
    })) || [];

    // Parse location if it comes as strings (multipart/form-data quirk)
    let parsedLocation = location;
    if (!parsedLocation && req.body['location[name]']) {
        parsedLocation = {
            name: req.body['location[name]'],
            address: req.body['location[address]']
        };
        // Parse GPS coordinates from FormData (location[coordinates][0], location[coordinates][1])
        const lng = parseFloat(req.body['location[coordinates][0]']);
        const lat = parseFloat(req.body['location[coordinates][1]']);
        if (!isNaN(lng) && !isNaN(lat)) {
            parsedLocation.type = req.body['location[type]'] || 'Point';
            parsedLocation.coordinates = [lng, lat];
        }
    } else if (typeof location === 'string') {
        try {
            parsedLocation = JSON.parse(location);
        } catch (e) {
            parsedLocation = {};
        }
    }

    // Parse tags
    let parsedTags = [];
    if (tags) {
        if (typeof tags === 'string') {
            parsedTags = tags.split(',').map(t => t.trim());
        } else if (Array.isArray(tags)) {
            parsedTags = tags;
        }
    } else {
        // Handle tags[0], tags[1] style from FormData
        parsedTags = Object.keys(req.body)
            .filter(key => key.startsWith('tags['))
            .map(key => req.body[key]);
    }

    const listing = await Listing.create({
        seller: req.user._id,
        title,
        description,
        images,
        category,
        priceType,
        price: priceType === 'free' ? 0 : price,
        condition,
        location: parsedLocation,
        tags: parsedTags,
        educationLevel: educationLevel || undefined,
        classOrSemester: classOrSemester || undefined,
        subject: subject || undefined,
        bookType: bookType || undefined,
        division: division || undefined,
        district: district || undefined,
        upazila: upazila || undefined,
    });

    // Increment category listing count
    await Category.findByIdAndUpdate(categoryExists._id, {
        $inc: { listingCount: 1 }
    });

    res.status(201).json({
        success: true,
        message: 'Listing created and pending approval',
        data: listing,
    });
});

// @desc    Update listing
// @route   PUT /api/listings/:id
// @access  Private (owner only)
exports.updateListing = asyncHandler(async (req, res) => {
    let listing = await Listing.findById(req.params.id);

    if (!listing) {
        return res.status(404).json({
            success: false,
            message: 'Listing not found',
        });
    }

    // Check ownership
    if (listing.seller.toString() !== req.user._id.toString()) {
        return res.status(403).json({
            success: false,
            message: 'Not authorized to update this listing',
        });
    }

    // Don't allow editing sold/expired listings
    if (['sold', 'expired'].includes(listing.status)) {
        return res.status(400).json({
            success: false,
            message: `Cannot edit ${listing.status} listings`,
        });
    }

    const { title, description, category, priceType, price, condition, location, tags,
        educationLevel, classOrSemester, subject, bookType, division, district, upazila } = req.body;

    // Validate category if provided
    if (category) {
        const categoryExists = await Category.findOne({ slug: category, isActive: true });
        if (!categoryExists) {
            return res.status(400).json({
                success: false,
                message: 'Invalid or inactive category',
            });
        }
    }

    // Handle new images
    if (req.files?.length > 0) {
        const newImages = req.files.map(file => ({
            url: file.path,
            publicId: file.filename,
        }));
        listing.images = [...listing.images, ...newImages];
    }

    // Parse location
    let parsedLocation = location;
    if (!parsedLocation && req.body['location[name]']) {
        parsedLocation = {
            name: req.body['location[name]'],
            address: req.body['location[address]']
        };
    } else if (typeof location === 'string') {
        try {
            parsedLocation = JSON.parse(location);
        } catch (e) {
            // Ignore parse error
        }
    }

    // Parse tags
    let parsedTags = tags;
    if (tags && typeof tags === 'string') {
        parsedTags = tags.split(',').map(t => t.trim());
    } else if (!tags) {
        // Check for tags[0] style
        const extractedTags = Object.keys(req.body)
            .filter(key => key.startsWith('tags['))
            .map(key => req.body[key]);
        if (extractedTags.length > 0) {
            parsedTags = extractedTags;
        }
    }

    // Detect price drop before updating
    if (price !== undefined && priceType !== 'free') {
        const newPrice = parseFloat(price);
        if (listing.price && newPrice < listing.price) {
            listing.previousPrice = listing.price;
            listing.priceDroppedAt = new Date();
        }
    }

    // Update fields
    if (title) listing.title = title;
    if (description) listing.description = description;
    if (category) listing.category = category;
    if (priceType) listing.priceType = priceType;
    if (price !== undefined) listing.price = priceType === 'free' ? 0 : price;
    if (condition) listing.condition = condition;
    if (parsedLocation) listing.location = parsedLocation;
    if (parsedTags) listing.tags = parsedTags;
    if (educationLevel !== undefined) listing.educationLevel = educationLevel || null;
    if (classOrSemester !== undefined) listing.classOrSemester = classOrSemester || null;
    if (subject !== undefined) listing.subject = subject || null;
    if (bookType !== undefined) listing.bookType = bookType || null;
    if (division !== undefined) listing.division = division || null;
    if (district !== undefined) listing.district = district || null;
    if (upazila !== undefined) listing.upazila = upazila || null;

    // Reset to pending only if content actually changed (not just price/condition edits)
    const contentChanged =
        (title && title !== listing.title) ||
        (description && description !== listing.description) ||
        (category && category !== listing.category);
    if (contentChanged) {
        listing.status = 'pending';
    }

    await listing.save();

    res.json({
        success: true,
        data: listing,
    });
});

// @desc    Get highlights: recent price drops + new arrivals
// @route   GET /api/listings/highlights
// @access  Public
exports.getHighlights = asyncHandler(async (req, res) => {
    const since48h = new Date(Date.now() - 48 * 60 * 60 * 1000);
    const since24h = new Date(Date.now() - 24 * 60 * 60 * 1000);

    const [priceDrops, newArrivals] = await Promise.all([
        Listing.find({
            status: 'approved',
            priceDroppedAt: { $gte: since48h },
            previousPrice: { $exists: true, $ne: null },
        })
            .populate('seller', 'name avatar')
            .sort({ priceDroppedAt: -1 })
            .limit(10)
            .lean(),
        Listing.find({
            status: 'approved',
            createdAt: { $gte: since24h },
        })
            .populate('seller', 'name avatar')
            .sort({ createdAt: -1 })
            .limit(10)
            .lean(),
    ]);

    // Merge and deduplicate, price drops first
    const seen = new Set();
    const highlights = [];
    for (const listing of [...priceDrops, ...newArrivals]) {
        const id = listing._id.toString();
        if (!seen.has(id)) {
            seen.add(id);
            highlights.push({
                ...listing,
                highlightType: priceDrops.some(p => p._id.toString() === id)
                    ? 'price_drop'
                    : 'new_arrival',
            });
        }
    }

    res.json({ success: true, data: highlights });
});

// @desc    Delete listing
// @route   DELETE /api/listings/:id
// @access  Private (owner only)
exports.deleteListing = asyncHandler(async (req, res) => {
    const listing = await Listing.findById(req.params.id);

    if (!listing) {
        return res.status(404).json({
            success: false,
            message: 'Listing not found',
        });
    }

    // Check ownership (or admin)
    if (
        listing.seller.toString() !== req.user._id.toString() &&
        !['admin', 'superadmin'].includes(req.user.role)
    ) {
        return res.status(403).json({
            success: false,
            message: 'Not authorized to delete this listing',
        });
    }

    // Delete images from Cloudinary
    for (const image of listing.images) {
        await deleteImage(image.publicId);
    }

    await listing.deleteOne();

    // Update seller stats
    await User.findByIdAndUpdate(listing.seller, {
        $inc: { totalListings: -1 },
    });

    res.json({
        success: true,
        message: 'Listing deleted',
    });
});

// @desc    Delete listing image
// @route   DELETE /api/listings/:id/images/:imageId
// @access  Private (owner only)
exports.deleteImage = asyncHandler(async (req, res) => {
    const listing = await Listing.findById(req.params.id);

    if (!listing) {
        return res.status(404).json({
            success: false,
            message: 'Listing not found',
        });
    }

    if (listing.seller.toString() !== req.user._id.toString()) {
        return res.status(403).json({
            success: false,
            message: 'Not authorized',
        });
    }

    const imageIndex = listing.images.findIndex(
        img => img._id.toString() === req.params.imageId
    );

    if (imageIndex === -1) {
        return res.status(404).json({
            success: false,
            message: 'Image not found',
        });
    }

    // Delete from Cloudinary
    await deleteImage(listing.images[imageIndex].publicId);

    // Remove from array
    listing.images.splice(imageIndex, 1);
    await listing.save();

    res.json({
        success: true,
        data: listing,
    });
});

// @desc    Mark listing as sold
// @route   PUT /api/listings/:id/sold
// @access  Private (owner only)
exports.markAsSold = asyncHandler(async (req, res) => {
    const { buyerId, soldPrice } = req.body;
    const listing = await Listing.findById(req.params.id);

    if (!listing) {
        return res.status(404).json({
            success: false,
            message: 'Listing not found',
        });
    }

    if (listing.seller.toString() !== req.user._id.toString()) {
        return res.status(403).json({
            success: false,
            message: 'Not authorized',
        });
    }

    if (listing.status === 'sold') {
        return res.status(400).json({
            success: false,
            message: 'Listing is already marked as sold',
        });
    }

    listing.status = 'sold';
    if (buyerId) listing.soldTo = buyerId;
    if (soldPrice) listing.soldPrice = soldPrice;
    listing.soldAt = new Date();
    await listing.save();

    // Update seller stats
    await User.findByIdAndUpdate(listing.seller, {
        $inc: { totalSold: 1 },
    });

    // Cancel all pending/countered offers on this listing and notify buyers
    const activeOffers = await Offer.find({
        listing: listing._id,
        status: { $in: ['pending', 'countered'] },
    }).populate('buyer', 'name');

    if (activeOffers.length > 0) {
        // Bulk cancel all active offers
        await Offer.updateMany(
            { listing: listing._id, status: { $in: ['pending', 'countered'] } },
            { $set: { status: 'cancelled', respondedAt: new Date() } }
        );

        // Notify each buyer
        for (const offer of activeOffers) {
            // Skip the buyer who purchased (they already know)
            if (buyerId && offer.buyer._id.toString() === buyerId.toString()) continue;

            await Notification.createNotification({
                userId: offer.buyer._id,
                type: 'listing_sold',
                title: 'Listing Sold',
                body: `"${listing.title}" has been sold. Your offer of $${offer.amount.toFixed(2)} is no longer active.`,
                data: { listingId: listing._id, offerId: offer._id },
            });

            // Send FCM push
            try {
                await sendOfferNotification(offer.buyer._id, {
                    type: 'listing_sold',
                    buyerName: offer.buyer.name,
                    amount: offer.amount,
                    listingTitle: listing.title,
                    offerId: offer._id.toString(),
                    listingId: listing._id.toString(),
                });
            } catch (err) {
                console.error(`Failed to send FCM to buyer ${offer.buyer._id}:`, err.message);
            }
        }
    }

    // Notify users who wishlisted this item
    const usersWithWishlist = await User.find({
        wishlist: listing._id,
    }).select('_id');

    for (const user of usersWithWishlist) {
        await Notification.createNotification({
            userId: user._id,
            type: 'wishlist_sold',
            title: 'Wishlist Item Sold',
            body: `"${listing.title}" has been sold`,
            data: { listingId: listing._id },
        });
    }

    res.json({
        success: true,
        data: listing,
    });
});
// @desc    Promote listing (self-serve)
// @route   POST /api/listings/:id/promote
// @access  Private (owner only)
exports.promoteListing = asyncHandler(async (req, res) => {
    const { plan } = req.body;

    const durations = { '3days': 3, '7days': 7, '30days': 30 };
    if (!plan || !durations[plan]) {
        return res.status(400).json({
            success: false,
            message: 'Invalid plan. Choose 3days, 7days, or 30days.',
        });
    }

    const listing = await Listing.findById(req.params.id);
    if (!listing) {
        return res.status(404).json({ success: false, message: 'Listing not found' });
    }

    if (listing.seller.toString() !== req.user._id.toString()) {
        return res.status(403).json({ success: false, message: 'Not authorised' });
    }

    if (listing.status !== 'approved') {
        return res.status(400).json({ success: false, message: 'Only approved listings can be promoted' });
    }

    const days = durations[plan];
    listing.isFeatured = true;
    listing.featuredPlan = plan;
    listing.featuredUntil = new Date(Date.now() + days * 24 * 60 * 60 * 1000);
    await listing.save();

    res.json({ success: true, data: listing });
});

// @desc    Add to wishlist
// @route   POST /api/listings/:id/wishlist
// @access  Private
exports.addToWishlist = asyncHandler(async (req, res) => {
    const listing = await Listing.findById(req.params.id);

    if (!listing) {
        return res.status(404).json({
            success: false,
            message: 'Listing not found',
        });
    }

    // Check if already in wishlist
    if (req.user.wishlist.includes(listing._id)) {
        return res.status(400).json({
            success: false,
            message: 'Already in wishlist',
        });
    }

    req.user.wishlist.push(listing._id);
    await req.user.save();

    listing.wishlistCount += 1;
    await listing.save();

    res.json({
        success: true,
        message: 'Added to wishlist',
    });
});

// @desc    Remove from wishlist
// @route   DELETE /api/listings/:id/wishlist
// @access  Private
exports.removeFromWishlist = asyncHandler(async (req, res) => {
    const index = req.user.wishlist.indexOf(req.params.id);

    if (index === -1) {
        return res.status(400).json({
            success: false,
            message: 'Not in wishlist',
        });
    }

    req.user.wishlist.splice(index, 1);
    await req.user.save();

    await Listing.findByIdAndUpdate(req.params.id, {
        $inc: { wishlistCount: -1 },
    });

    res.json({
        success: true,
        message: 'Removed from wishlist',
    });
});

// @desc    Get user's wishlist
// @route   GET /api/listings/wishlist
// @access  Private
exports.getWishlist = asyncHandler(async (req, res) => {
    const user = await User.findById(req.user._id).populate({
        path: 'wishlist',
        populate: { path: 'seller', select: 'name avatar' },
    });

    res.json({
        success: true,
        data: user.wishlist,
    });
});

// @desc    Get user's own listings
// @route   GET /api/listings/my-listings
// @access  Private
exports.getMyListings = asyncHandler(async (req, res) => {
    const { status, page, limit } = req.query;
    const { skip, limit: limitNum, page: pageNum } = paginate(page, limit);

    const query = { seller: req.user._id };
    if (status) query.status = status;

    const [listings, total] = await Promise.all([
        Listing.find(query)
            .sort('-createdAt')
            .skip(skip)
            .limit(limitNum)
            .lean(),
        Listing.countDocuments(query),
    ]);

    res.json({
        success: true,
        data: listings,
        pagination: paginationMeta(total, pageNum, limitNum),
    });
});

// @desc    Get listings by user
// @route   GET /api/listings/user/:userId
// @access  Public
exports.getListingsByUser = asyncHandler(async (req, res) => {
    const { page, limit } = req.query;
    const { skip, limit: limitNum, page: pageNum } = paginate(page, limit);

    const [listings, total] = await Promise.all([
        Listing.find({
            seller: req.params.userId,
            status: 'approved',
        })
            .sort('-createdAt')
            .skip(skip)
            .limit(limitNum)
            .lean(),
        Listing.countDocuments({
            seller: req.params.userId,
            status: 'approved',
        }),
    ]);

    res.json({
        success: true,
        data: listings,
        pagination: paginationMeta(total, pageNum, limitNum),
    });
});

// @desc    Get nearby listings
// @route   GET /api/listings/nearby
// @access  Public
exports.getNearbyListings = asyncHandler(async (req, res) => {
    const {
        longitude,
        latitude,
        maxDistance = 10000, // Default 10km in meters
        category,
        limit,
    } = req.query;

    if (!longitude || !latitude) {
        return res.status(400).json({
            success: false,
            message: 'Longitude and latitude are required',
        });
    }

    const lng = parseFloat(longitude);
    const lat = parseFloat(latitude);
    const distanceMeters = parseInt(maxDistance);
    const limitNum = Math.min(parseInt(limit) || 10, 20);

    // Convert meters to radians for $centerSphere (Earth radius ≈ 6378100 meters)
    const radiusInRadians = distanceMeters / 6378100;

    // Use $geoWithin + $centerSphere (no sorting required, works without 2dsphere index issues)
    const query = {
        status: 'approved',
        'location.coordinates': {
            $geoWithin: {
                $centerSphere: [[lng, lat], radiusInRadians],
            },
        },
    };

    if (category) query.category = category;

    const listings = await Listing.find(query)
        .populate('seller', 'name avatar averageRating')
        .limit(limitNum)
        .lean();

    // Calculate distance for each listing using Haversine
    listings.forEach(listing => {
        if (listing.location?.coordinates?.length === 2) {
            const [listingLng, listingLat] = listing.location.coordinates;
            listing.distance = calculateDistance(lat, lng, listingLat, listingLng);
        }
    });

    // Sort by distance (closest first)
    listings.sort((a, b) => (a.distance || Infinity) - (b.distance || Infinity));

    res.json({
        success: true,
        data: listings,
    });
});

// @desc    Get similar listings (same category, excluding current listing and same seller)
// @route   GET /api/listings/:id/similar
// @access  Public
exports.getSimilarListings = asyncHandler(async (req, res) => {
    const listing = await Listing.findById(req.params.id);

    if (!listing) {
        return res.status(404).json({
            success: false,
            message: 'Listing not found',
        });
    }

    const limit = Math.min(parseInt(req.query.limit) || 6, 20);

    const similarListings = await Listing.find({
        _id: { $ne: listing._id },
        seller: { $ne: listing.seller },
        category: listing.category,
        status: 'approved',
    })
        .sort('-createdAt')
        .limit(limit)
        .populate('seller', 'name avatar phone averageRating totalReviews createdAt');

    // Add isWishlisted flag if user is authenticated
    if (req.user) {
        const wishlistIds = req.user.wishlist.map(id => id.toString());
        similarListings.forEach(item => {
            item.isWishlisted = wishlistIds.includes(item._id.toString());
        });
    }

    res.json({
        success: true,
        data: similarListings,
    });
});

// Helper function to calculate distance between two points (Haversine formula)
function calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 3959; // Earth's radius in miles (use 6371 for km)
    const dLat = toRad(lat2 - lat1);
    const dLon = toRad(lon2 - lon1);
    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return Math.round(R * c * 10) / 10; // Round to 1 decimal place
}

function toRad(deg) {
    return deg * (Math.PI / 180);
}
