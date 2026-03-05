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
router.get('/audit-logs', rules.pagination, validate, adminController.getAuditLogs);

// User management
router.get('/users', rules.pagination, validate, adminController.getUsers);
router.get('/users/:id', rules.mongoId, validate, adminController.getUser);
router.put('/users/:id/ban', rules.mongoId, validate, adminController.toggleBan);
router.put('/users/:id/role', requireSuperAdmin, rules.mongoId, validate, adminController.changeRole);

// Listing moderation
router.get('/listings', rules.pagination, validate, adminController.getAllListings);
router.get('/listings/pending', rules.pagination, validate, adminController.getPendingListings);
router.get('/listings/:id', rules.mongoId, validate, adminController.getListingDetail);
router.put('/listings/:id/approve', rules.mongoId, validate, adminController.approveListing);
router.put('/listings/:id/reject', rules.mongoId, validate, adminController.rejectListing);
router.delete('/listings/:id', rules.mongoId, validate, adminController.deleteListing);
router.put('/listings/:id/feature', rules.mongoId, validate, adminController.toggleFeature);

// Bulk actions
router.post('/listings/bulk-approve', rules.bulkListingIds, validate, adminController.bulkApproveListings);
router.post('/listings/bulk-reject', rules.bulkReject, validate, adminController.bulkRejectListings);
router.post('/listings/bulk-delete', rules.bulkListingIds, validate, adminController.bulkDeleteListings);

// Education Config
router.put('/education-config', require('../controllers/educationConfigController').updateEducationConfig);

// Reports
router.get('/reports', rules.pagination, validate, adminController.getReports);
router.get('/reports/:id', rules.mongoId, validate, adminController.getReportDetail);
router.put('/reports/:id', rules.mongoId, validate, adminController.reviewReport);

// Data export
router.get('/export/users', adminController.exportUsers);
router.get('/export/listings', adminController.exportListings);

module.exports = router;
