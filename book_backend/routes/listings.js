const express = require('express');
const router = express.Router();
const listingController = require('../controllers/listingController');
const { protect, optionalAuth } = require('../middleware/auth');
const { requireVerified } = require('../middleware/roles');
const { validate, rules } = require('../middleware/validate');
const { uploadListingImages } = require('../config/cloudinary');

// Public routes (with optional auth for wishlist status)
router.get('/', optionalAuth, rules.pagination, validate, listingController.getListings);
router.get('/nearby', optionalAuth, rules.pagination, validate, listingController.getNearbyListings);
router.get('/user/:userId', rules.mongoId, rules.pagination, validate, listingController.getListingsByUser);
router.get('/:id/similar', optionalAuth, rules.mongoId, validate, listingController.getSimilarListings);

// Protected routes
router.use(protect);

// User's listings (MUST be before /:id route to avoid matching as ID)
router.get('/my-listings', listingController.getMyListings);
router.get('/wishlist', listingController.getWishlist);

// Single listing by ID (MUST be last among GET routes)
router.get('/:id', rules.mongoId, validate, listingController.getListing);

// Create listing (requires verified email)
router.post(
    '/',
    requireVerified,
    uploadListingImages,
    rules.createListing,
    validate,
    listingController.createListing
);

// Update listing
router.put(
    '/:id',
    uploadListingImages,
    rules.mongoId,
    rules.updateListing,
    validate,
    listingController.updateListing
);

// Delete listing
router.delete('/:id', rules.mongoId, validate, listingController.deleteListing);

// Delete image from listing
router.delete('/:id/images/:imageId', listingController.deleteImage);

// Mark as sold
router.put('/:id/sold', rules.mongoId, validate, listingController.markAsSold);

// Wishlist actions
router.post('/:id/wishlist', rules.mongoId, validate, listingController.addToWishlist);
router.delete('/:id/wishlist', rules.mongoId, validate, listingController.removeFromWishlist);

// Promote listing (self-serve)
router.post('/:id/promote', rules.mongoId, validate, listingController.promoteListing);

module.exports = router;
