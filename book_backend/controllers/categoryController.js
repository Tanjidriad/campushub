const Category = require('../models/Category');
const Listing = require('../models/Listing');
const { asyncHandler } = require('../middleware/errorHandler');
const { deleteImage, getPublicIdFromUrl } = require('../config/cloudinary');

// @desc    Get all categories
// @route   GET /api/categories
// @access  Public
exports.getAllCategories = asyncHandler(async (req, res) => {
    const { includeInactive } = req.query;

    const filter = includeInactive === 'true' ? {} : { isActive: true };

    const categories = await Category.find(filter).sort({ displayOrder: 1, name: 1 });

    res.json({
        success: true,
        data: categories,
    });
});

// @desc    Get single category
// @route   GET /api/categories/:id
// @access  Public
exports.getCategory = asyncHandler(async (req, res) => {
    const category = await Category.findById(req.params.id);

    if (!category) {
        res.status(404);
        throw new Error('Category not found');
    }

    res.json({
        success: true,
        data: category,
    });
});

// @desc    Create category (Admin only)
// @route   POST /api/admin/categories
// @access  Private/Admin
exports.createCategory = asyncHandler(async (req, res) => {
    const { name, description, icon, displayOrder } = req.body;

    // Check if category already exists
    const existingCategory = await Category.findOne({
        name: { $regex: new RegExp(`^${name}$`, 'i') }
    });

    if (existingCategory) {
        res.status(400);
        throw new Error('Category already exists');
    }

    const categoryData = {
        name,
        description,
        icon,
        displayOrder: displayOrder || 0,
    };

    // If an image file was uploaded via multer, save its Cloudinary URL
    if (req.file && req.file.path) {
        categoryData.image = req.file.path;
    }

    const category = await Category.create(categoryData);

    res.status(201).json({
        success: true,
        data: category,
        message: 'Category created successfully',
    });
});

// @desc    Update category (Admin only)
// @route   PUT /api/admin/categories/:id
// @access  Private/Admin
exports.updateCategory = asyncHandler(async (req, res) => {
    const { name, description, icon, displayOrder } = req.body;

    const category = await Category.findById(req.params.id);

    if (!category) {
        res.status(404);
        throw new Error('Category not found');
    }

    // Check if name is being changed and if new name already exists
    if (name && name !== category.name) {
        const existingCategory = await Category.findOne({
            name: { $regex: new RegExp(`^${name}$`, 'i') },
            _id: { $ne: req.params.id }
        });

        if (existingCategory) {
            res.status(400);
            throw new Error('Category name already exists');
        }
    }

    category.name = name || category.name;
    category.description = description !== undefined ? description : category.description;
    category.icon = icon || category.icon;
    category.displayOrder = displayOrder !== undefined ? displayOrder : category.displayOrder;

    // If a new image was uploaded, delete the old one and save the new URL
    if (req.file && req.file.path) {
        if (category.image) {
            const oldPublicId = getPublicIdFromUrl(category.image);
            if (oldPublicId) {
                await deleteImage(oldPublicId);
            }
        }
        category.image = req.file.path;
    }

    await category.save();

    res.json({
        success: true,
        data: category,
        message: 'Category updated successfully',
    });
});

// @desc    Delete category (Admin only)
// @route   DELETE /api/admin/categories/:id
// @access  Private/Admin
exports.deleteCategory = asyncHandler(async (req, res) => {
    const category = await Category.findById(req.params.id);

    if (!category) {
        res.status(404);
        throw new Error('Category not found');
    }

    // Check if category is being used by any listings
    const listingCount = await Listing.countDocuments({ category: category.slug });

    if (listingCount > 0) {
        res.status(400);
        throw new Error(`Cannot delete category with ${listingCount} active listing(s). Please reassign or delete those listings first.`);
    }

    // Delete the category image from Cloudinary if it exists
    if (category.image) {
        const publicId = getPublicIdFromUrl(category.image);
        if (publicId) {
            await deleteImage(publicId);
        }
    }

    await category.deleteOne();

    res.json({
        success: true,
        message: 'Category deleted successfully',
    });
});

// @desc    Toggle category active status (Admin only)
// @route   PATCH /api/admin/categories/:id/toggle
// @access  Private/Admin
exports.toggleCategoryStatus = asyncHandler(async (req, res) => {
    const category = await Category.findById(req.params.id);

    if (!category) {
        res.status(404);
        throw new Error('Category not found');
    }

    category.isActive = !category.isActive;
    await category.save();

    res.json({
        success: true,
        data: {
            id: category._id,
            isActive: category.isActive,
        },
        message: `Category ${category.isActive ? 'activated' : 'deactivated'} successfully`,
    });
});

// @desc    Update category listing count (Internal use)
// @route   N/A
// @access  Internal
exports.updateCategoryCount = async (categorySlug, increment = 1) => {
    try {
        await Category.findOneAndUpdate(
            { slug: categorySlug },
            { $inc: { listingCount: increment } }
        );
    } catch (error) {
        console.error('Error updating category count:', error);
    }
};
