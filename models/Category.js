const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema(
    {
        name: {
            type: String,
            required: [true, 'Category name is required'],
            unique: true,
            trim: true,
            maxlength: [50, 'Category name cannot exceed 50 characters'],
        },
        slug: {
            type: String,
            lowercase: true,
            trim: true,
        },
        description: {
            type: String,
            maxlength: [200, 'Description cannot exceed 200 characters'],
        },
        icon: {
            type: String,
            default: 'category',
        },
        isActive: {
            type: Boolean,
            default: true,
            index: true,
        },
        displayOrder: {
            type: Number,
            default: 0,
        },
        listingCount: {
            type: Number,
            default: 0,
        },
    },
    {
        timestamps: true,
    }
);

// Index for active categories
categorySchema.index({ isActive: 1, displayOrder: 1 });

// Generate slug only on creation (not on name updates)
categorySchema.pre('save', function (next) {
    if (this.isNew && this.isModified('name')) {
        this.slug = this.name
            .toLowerCase()
            .replace(/[^a-z0-9\s-]/g, '')
            .replace(/\s+/g, '-')
            .replace(/-+/g, '-')
            .trim();
    }
    next();
});

module.exports = mongoose.model('Category', categorySchema);
