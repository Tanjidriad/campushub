const express = require('express');
const router = express.Router();
const reportController = require('../controllers/reportController');
const { protect } = require('../middleware/auth');
const { validate, rules } = require('../middleware/validate');

router.use(protect);

router.post('/', rules.createReport, validate, reportController.createReport);

module.exports = router;
