const mongoose = require('mongoose');

const subLevelSchema = new mongoose.Schema({
    key: { type: String, required: true, trim: true },
    label: { type: String, required: true, trim: true },
}, { _id: false });

const levelSchema = new mongoose.Schema({
    key: { type: String, required: true, trim: true },
    label: { type: String, required: true, trim: true },
    subLevels: [subLevelSchema],
}, { _id: false });

const bookTypeSchema = new mongoose.Schema({
    key: { type: String, required: true, trim: true },
    label: { type: String, required: true, trim: true },
}, { _id: false });

const educationConfigSchema = new mongoose.Schema(
    {
        levels: { type: [levelSchema], default: [] },
        bookTypes: { type: [bookTypeSchema], default: [] },
    },
    { timestamps: true }
);

// Ensure only one config document exists
educationConfigSchema.statics.getConfig = async function () {
    let config = await this.findOne();
    if (!config) {
        config = await this.create({ levels: [], bookTypes: [] });
    }
    return config;
};

module.exports = mongoose.model('EducationConfig', educationConfigSchema);
