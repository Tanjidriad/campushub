const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');
const { protect } = require('../middleware/auth');
const { requireAdmin } = require('../middleware/roles');
const { validate, rules } = require('../middleware/validate');

// Public routes
router.get('/', categoryController.getAllCategories);
router.get('/:id', rules.mongoId, validate, categoryController.getCategory);

// Admin routes
router.post(
    '/admin',
    protect,
    requireAdmin,
    categoryController.createCategory
);

router.put(
    '/admin/:id',
    protect,
    requireAdmin,
    rules.mongoId,
    validate,
    categoryController.updateCategory
);

router.delete(
    '/admin/:id',
    protect,
    requireAdmin,
    rules.mongoId,
    validate,
    categoryController.deleteCategory
);

router.patch(
    '/admin/:id/toggle',
    protect,
    requireAdmin,
    rules.mongoId,
    validate,
    categoryController.toggleCategoryStatus
);

module.exports = router;
