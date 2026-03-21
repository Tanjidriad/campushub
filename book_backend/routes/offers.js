const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const { requireVerified } = require('../middleware/roles');
const { validate, rules } = require('../middleware/validate');
const offerController = require('../controllers/offerController');

// All routes require authentication
router.use(protect);
router.use(requireVerified);

router.route('/')
    .get(rules.pagination, validate, offerController.getOffers)
    .post(rules.createOffer, validate, offerController.createOffer);

router.route('/:id')
    .get(rules.mongoId, validate, offerController.getOffer);

router.route('/:id/respond')
    .put(rules.respondToOffer, validate, offerController.respondToOffer);

router.route('/listing/:listingId')
    .get(rules.pagination, validate, offerController.getListingOffers);

module.exports = router;
