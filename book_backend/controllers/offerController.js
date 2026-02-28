const Offer = require('../models/Offer');
const Listing = require('../models/Listing');
const Notification = require('../models/Notification');
const Conversation = require('../models/Conversation');
const { emitSystemMessage } = require('../socket/socketManager');
const { asyncHandler } = require('../middleware/errorHandler');
const { paginate, paginationMeta } = require('../utils/pagination');
const { sendOfferNotification } = require('../utils/notificationService');

// @desc    Create an offer on a listing
// @route   POST /api/offers
// @access  Private
exports.createOffer = asyncHandler(async (req, res) => {
    const { listingId, amount, message } = req.body;
    const buyerId = req.user._id;

    if (!listingId || amount == null) {
        return res.status(400).json({
            success: false,
            message: 'Listing ID and offer amount are required',
        });
    }

    // Get listing
    const listing = await Listing.findById(listingId).populate('seller', 'name avatar');
    if (!listing) {
        return res.status(404).json({
            success: false,
            message: 'Listing not found',
        });
    }

    // Can't offer on own listing
    if (listing.seller._id.toString() === buyerId.toString()) {
        return res.status(400).json({
            success: false,
            message: 'Cannot make an offer on your own listing',
        });
    }

    // Check for existing pending offer
    const existingOffer = await Offer.hasPendingOffer(listingId, buyerId);
    if (existingOffer) {
        return res.status(400).json({
            success: false,
            message: 'You already have a pending offer on this listing',
            data: { existingOfferId: existingOffer._id },
        });
    }

    // Create offer
    const offer = await Offer.create({
        listing: listingId,
        buyer: buyerId,
        seller: listing.seller._id,
        amount,
        message,
        expiresAt: new Date(Date.now() + 48 * 60 * 60 * 1000),
    });

    // Create in-app notification for seller
    await Notification.createNotification({
        userId: listing.seller._id,
        type: 'new_offer',
        title: '💰 New Offer Received',
        body: `${req.user.name} offered $${amount.toFixed(2)} for "${listing.title}"`,
        data: {
            listingId: listing._id,
            offerId: offer._id,
            userId: buyerId,
        },
    });

    // Send FCM push
    await sendOfferNotification(listing.seller._id, {
        type: 'new_offer',
        buyerName: req.user.name,
        amount,
        listingTitle: listing.title,
        offerId: offer._id.toString(),
        listingId: listing._id.toString(),
    });

    // Populate and return
    const populatedOffer = await Offer.findById(offer._id)
        .populate('buyer', 'name avatar')
        .populate('seller', 'name avatar')
        .populate('listing', 'title price images condition location')
        .lean();

    res.status(201).json({
        success: true,
        data: populatedOffer,
    });
});

// @desc    Get user's offers (sent & received)
// @route   GET /api/offers
// @access  Private
exports.getOffers = asyncHandler(async (req, res) => {
    const { page, limit, type, status } = req.query;
    const { skip, limit: limitNum, page: pageNum } = paginate(page, limit);
    const userId = req.user._id;

    const query = {};

    // Filter by type: 'sent' (buyer) or 'received' (seller)
    if (type === 'sent') {
        query.buyer = userId;
    } else if (type === 'received') {
        query.seller = userId;
    } else {
        query.$or = [{ buyer: userId }, { seller: userId }];
    }

    if (status) {
        query.status = status;
    }

    // Mark expired offers
    await Offer.updateMany(
        {
            ...query,
            status: 'pending',
            expiresAt: { $lt: new Date() },
        },
        { $set: { status: 'expired' } }
    );

    const [offers, total] = await Promise.all([
        Offer.find(query)
            .populate('buyer', 'name avatar')
            .populate('seller', 'name avatar')
            .populate('listing', 'title price images condition location category')
            .sort('-createdAt')
            .skip(skip)
            .limit(limitNum)
            .lean(),
        Offer.countDocuments(query),
    ]);

    res.json({
        success: true,
        data: offers,
        pagination: paginationMeta(total, pageNum, limitNum),
    });
});

// @desc    Get single offer with full details
// @route   GET /api/offers/:id
// @access  Private
exports.getOffer = asyncHandler(async (req, res) => {
    const offer = await Offer.findById(req.params.id)
        .populate('buyer', 'name avatar phone')
        .populate('seller', 'name avatar phone')
        .populate({
            path: 'listing',
            select: 'title description price images condition location category priceType seller',
            populate: { path: 'seller', select: 'name avatar' },
        })
        .populate('parentOffer')
        .lean();

    if (!offer) {
        return res.status(404).json({
            success: false,
            message: 'Offer not found',
        });
    }

    // Only buyer or seller can view
    const userId = req.user._id.toString();
    if (offer.buyer._id.toString() !== userId && offer.seller._id.toString() !== userId) {
        return res.status(403).json({
            success: false,
            message: 'Not authorized to view this offer',
        });
    }

    // Check expiry
    if (offer.status === 'pending' && new Date() > new Date(offer.expiresAt)) {
        await Offer.findByIdAndUpdate(offer._id, { status: 'expired' });
        offer.status = 'expired';
    }

    res.json({
        success: true,
        data: offer,
    });
});

// @desc    Respond to an offer (accept/decline/counter)
// @route   PUT /api/offers/:id/respond
// @access  Private
exports.respondToOffer = asyncHandler(async (req, res) => {
    const { action, counterAmount, message } = req.body;
    const userId = req.user._id;

    if (!['accept', 'decline', 'counter'].includes(action)) {
        return res.status(400).json({
            success: false,
            message: 'Action must be accept, decline, or counter',
        });
    }

    const offer = await Offer.findById(req.params.id)
        .populate('buyer', 'name avatar')
        .populate('listing', 'title price images');

    if (!offer) {
        return res.status(404).json({
            success: false,
            message: 'Offer not found',
        });
    }

    // Only the recipient can respond (seller for buyer's offer, buyer for counter)
    const isSellerResponding = offer.seller.toString() === userId.toString();
    const isBuyerRespondingToCounter = offer.buyer._id.toString() === userId.toString() && offer.status === 'countered';

    if (!isSellerResponding && !isBuyerRespondingToCounter) {
        return res.status(403).json({
            success: false,
            message: 'Not authorized to respond to this offer',
        });
    }

    // Check if offer is still actionable
    if (!['pending', 'countered'].includes(offer.status)) {
        return res.status(400).json({
            success: false,
            message: `Cannot respond to an offer with status: ${offer.status}`,
        });
    }

    // Check expiry
    if (new Date() > offer.expiresAt) {
        offer.status = 'expired';
        await offer.save();
        return res.status(400).json({
            success: false,
            message: 'This offer has expired',
        });
    }

    let notificationType, notificationTitle, notificationBody;
    const recipientId = isSellerResponding ? offer.buyer._id : offer.seller;

    switch (action) {
        case 'accept':
            offer.status = 'accepted';
            offer.respondedAt = new Date();
            notificationType = 'offer_accepted';
            notificationTitle = '🎉 Offer Accepted!';
            notificationBody = `Your offer of $${offer.amount.toFixed(2)} for "${offer.listing.title}" was accepted!`;
            break;

        case 'decline':
            offer.status = 'declined';
            offer.respondedAt = new Date();
            notificationType = 'offer_declined';
            notificationTitle = 'Offer Declined';
            notificationBody = `Your offer of $${offer.amount.toFixed(2)} for "${offer.listing.title}" was declined.`;
            break;

        case 'counter':
            if (!counterAmount) {
                return res.status(400).json({
                    success: false,
                    message: 'Counter amount is required',
                });
            }
            if (offer.roundNumber >= 3) {
                return res.status(400).json({
                    success: false,
                    message: 'Maximum negotiation rounds (3) reached. You can only accept or decline.',
                });
            }
            offer.status = 'countered';
            offer.counterAmount = counterAmount;
            offer.roundNumber += 1;
            offer.respondedAt = new Date();
            offer.expiresAt = new Date(Date.now() + 48 * 60 * 60 * 1000); // Reset expiry
            notificationType = 'offer_countered';
            notificationTitle = '🔄 Counter Offer';
            notificationBody = `Counter offer of $${counterAmount.toFixed(2)} for "${offer.listing.title}"`;
            break;
    }

    await offer.save();

    // Create in-app notification
    await Notification.createNotification({
        userId: recipientId,
        type: notificationType,
        title: notificationTitle,
        body: notificationBody,
        data: {
            listingId: offer.listing._id,
            offerId: offer._id,
        },
    });

    // Send FCM push
    await sendOfferNotification(recipientId, {
        type: notificationType,
        buyerName: isSellerResponding ? offer.buyer.name : req.user.name,
        amount: action === 'counter' ? counterAmount : offer.amount,
        listingTitle: offer.listing.title,
        offerId: offer._id.toString(),
        listingId: offer.listing._id.toString(),
    });

    // Send system message in chat if conversation exists (real-time via Socket.io)
    try {
        const conversation = await Conversation.findOne({
            participants: { $all: [offer.buyer._id, offer.seller] },
            listing: offer.listing._id,
        });

        if (conversation) {
            let systemText;
            if (action === 'accept') {
                systemText = `✅ Offer of $${offer.amount.toFixed(2)} accepted! 🎉`;
            } else if (action === 'decline') {
                systemText = `❌ Offer of $${offer.amount.toFixed(2)} was declined.`;
            } else if (action === 'counter') {
                systemText = `🔄 Counter offer: $${counterAmount.toFixed(2)}`;
            }

            await emitSystemMessage(conversation._id.toString(), userId, systemText);
        }
    } catch (err) {
        console.error('Failed to send system message:', err);
    }

    // Re-populate for response
    const updatedOffer = await Offer.findById(offer._id)
        .populate('buyer', 'name avatar')
        .populate('seller', 'name avatar')
        .populate('listing', 'title price images condition location')
        .lean();

    res.json({
        success: true,
        data: updatedOffer,
    });
});

// @desc    Get offers for a specific listing
// @route   GET /api/offers/listing/:listingId
// @access  Private
exports.getListingOffers = asyncHandler(async (req, res) => {
    const { listingId } = req.params;
    const { page, limit } = req.query;
    const { skip, limit: limitNum, page: pageNum } = paginate(page, limit);

    // Verify user owns the listing or has an offer on it
    const listing = await Listing.findById(listingId);
    if (!listing) {
        return res.status(404).json({
            success: false,
            message: 'Listing not found',
        });
    }

    const userId = req.user._id.toString();
    const isOwner = listing.seller.toString() === userId;

    const query = { listing: listingId };
    if (!isOwner) {
        query.buyer = req.user._id; // Non-owners can only see their own offers
    }

    const [offers, total] = await Promise.all([
        Offer.find(query)
            .populate('buyer', 'name avatar')
            .populate('seller', 'name avatar')
            .sort('-createdAt')
            .skip(skip)
            .limit(limitNum)
            .lean(),
        Offer.countDocuments(query),
    ]);

    res.json({
        success: true,
        data: offers,
        pagination: paginationMeta(total, pageNum, limitNum),
    });
});
