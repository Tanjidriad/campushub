const express = require('express');
const router = express.Router();
const { getEducationConfig } = require('../controllers/educationConfigController');

// Public route — no auth needed
router.get('/', getEducationConfig);

module.exports = router;
