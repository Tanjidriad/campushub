/**
 * Seed script for Bangladesh education config defaults.
 * Run: node seed-education.js
 */
const mongoose = require('mongoose');
require('dotenv').config();

const EducationConfig = require('./models/EducationConfig');

const bangladeshConfig = {
    levels: [
        {
            key: 'school',
            label: 'School',
            subLevels: [
                { key: 'class-6', label: 'Class 6' },
                { key: 'class-7', label: 'Class 7' },
                { key: 'class-8', label: 'Class 8' },
                { key: 'class-9', label: 'Class 9' },
                { key: 'class-10', label: 'Class 10' },
            ],
        },
        {
            key: 'college',
            label: 'College',
            subLevels: [
                { key: 'hsc-1', label: 'HSC 1st Year' },
                { key: 'hsc-2', label: 'HSC 2nd Year' },
            ],
        },
        {
            key: 'university',
            label: 'University',
            subLevels: [
                { key: 'sem-1', label: 'Semester 1' },
                { key: 'sem-2', label: 'Semester 2' },
                { key: 'sem-3', label: 'Semester 3' },
                { key: 'sem-4', label: 'Semester 4' },
                { key: 'sem-5', label: 'Semester 5' },
                { key: 'sem-6', label: 'Semester 6' },
                { key: 'sem-7', label: 'Semester 7' },
                { key: 'sem-8', label: 'Semester 8' },
                { key: 'sem-9', label: 'Semester 9' },
                { key: 'sem-10', label: 'Semester 10' },
                { key: 'sem-11', label: 'Semester 11' },
                { key: 'sem-12', label: 'Semester 12' },
            ],
        },
    ],
    bookTypes: [
        { key: 'nctb', label: 'NCTB' },
        { key: 'guide', label: 'Guide' },
        { key: 'reference', label: 'Reference' },
        { key: 'university_textbook', label: 'Uni Book' },
        { key: 'other', label: 'Other' },
    ],
};

async function seed() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB');

        // Upsert — create if not exists, update if exists
        await EducationConfig.deleteMany({});
        const config = await EducationConfig.create(bangladeshConfig);

        console.log('✅ Education config seeded:');
        console.log(`   ${config.levels.length} levels`);
        config.levels.forEach(l => {
            console.log(`   - ${l.label}: ${l.subLevels.length} sub-levels`);
        });
        console.log(`   ${config.bookTypes.length} book types`);

        await mongoose.disconnect();
        console.log('Done!');
    } catch (err) {
        console.error('❌ Seed failed:', err.message);
        process.exit(1);
    }
}

seed();
