const { asyncHandler } = require('../middleware/errorHandler');
const EducationConfig = require('../models/EducationConfig');

// @desc    Get education config (levels, sub-levels, book types)
// @route   GET /api/education-config
// @access  Public
exports.getEducationConfig = asyncHandler(async (req, res) => {
    const config = await EducationConfig.getConfig();
    res.json({ success: true, data: config });
});

// @desc    Update education config
// @route   PUT /api/admin/education-config
// @access  Admin
exports.updateEducationConfig = asyncHandler(async (req, res) => {
    const { levels, bookTypes } = req.body;

    const config = await EducationConfig.getConfig();

    if (levels !== undefined) {
        // Validate structure
        if (!Array.isArray(levels)) {
            return res.status(400).json({
                success: false,
                message: 'levels must be an array',
            });
        }
        for (const level of levels) {
            if (!level.key || !level.label) {
                return res.status(400).json({
                    success: false,
                    message: 'Each level must have a key and label',
                });
            }
            if (level.subLevels && !Array.isArray(level.subLevels)) {
                return res.status(400).json({
                    success: false,
                    message: 'subLevels must be an array',
                });
            }
        }
        config.levels = levels;
    }

    if (bookTypes !== undefined) {
        if (!Array.isArray(bookTypes)) {
            return res.status(400).json({
                success: false,
                message: 'bookTypes must be an array',
            });
        }
        for (const bt of bookTypes) {
            if (!bt.key || !bt.label) {
                return res.status(400).json({
                    success: false,
                    message: 'Each bookType must have a key and label',
                });
            }
        }
        config.bookTypes = bookTypes;
    }

    await config.save();
    res.json({ success: true, data: config });
});
