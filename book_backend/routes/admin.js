const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { protect } = require('../middleware/auth');
const { requireAdmin, requireSuperAdmin } = require('../middleware/roles');
const { validate, rules } = require('../middleware/validate');

// All routes require admin access
router.use(protect);
router.use(requireAdmin);

// Dashboard
router.get('/dashboard', adminController.getDashboard);
router.get('/activity', adminController.getRecentActivity);

// User management
router.get('/users', rules.pagination, validate, adminController.getUsers);
router.get('/users/:id', rules.mongoId, validate, adminController.getUser);
router.put('/users/:id/ban', rules.mongoId, validate, adminController.toggleBan);
router.put('/users/:id/role', requireSuperAdmin, rules.mongoId, validate, adminController.changeRole);

// Listing moderation
router.get('/listings', rules.pagination, validate, adminController.getAllListings);
router.get('/listings/pending', rules.pagination, validate, adminController.getPendingListings);
router.put('/listings/:id/approve', rules.mongoId, validate, adminController.approveListing);
router.put('/listings/:id/reject', rules.mongoId, validate, adminController.rejectListing);
router.delete('/listings/:id', rules.mongoId, validate, adminController.deleteListing);
router.put('/listings/:id/feature', rules.mongoId, validate, adminController.toggleFeature);

// Bulk actions
router.post('/listings/bulk-approve', adminController.bulkApproveListings);
router.post('/listings/bulk-reject', adminController.bulkRejectListings);
router.post('/listings/bulk-delete', adminController.bulkDeleteListings);

// Education Config
router.put('/education-config', require('../controllers/educationConfigController').updateEducationConfig);

// Reports
router.get('/reports', rules.pagination, validate, adminController.getReports);
router.put('/reports/:id', rules.mongoId, validate, adminController.reviewReport);

module.exports = router;
