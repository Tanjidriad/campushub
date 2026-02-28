const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const offerController = require('../controllers/offerController');

// All routes require authentication
router.use(protect);

router.route('/')
    .get(offerController.getOffers)
    .post(offerController.createOffer);

router.route('/:id')
    .get(offerController.getOffer);

router.route('/:id/respond')
    .put(offerController.respondToOffer);

router.route('/listing/:listingId')
    .get(offerController.getListingOffers);

module.exports = router;
