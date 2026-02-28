const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/reviewController');
const { protect } = require('../middleware/auth');
const { validate, rules } = require('../middleware/validate');

// Public routes
router.get('/seller/:sellerId', rules.pagination, validate, reviewController.getSellerReviews);

// Protected routes
router.use(protect);

router.get('/my-reviews', rules.pagination, validate, reviewController.getMyReviews);
router.post('/', rules.createReview, validate, reviewController.createReview);
router.put('/:id', rules.mongoId, rules.createReview, validate, reviewController.updateReview);
router.delete('/:id', rules.mongoId, validate, reviewController.deleteReview);

module.exports = router;
