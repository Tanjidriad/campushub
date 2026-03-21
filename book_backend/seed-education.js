/**
 * Seed script for Bangladesh education config with streams & departments.
 * Run: node seed-education.js
 */
const mongoose = require('mongoose');
require('dotenv').config();

const EducationConfig = require('./models/EducationConfig');

const semesters = (count) =>
    Array.from({ length: count }, (_, i) => ({
        key: `sem-${i + 1}`,
        label: `Semester ${i + 1}`,
    }));

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
            streams: [],
        },
        {
            key: 'college',
            label: 'College',
            subLevels: [],
            streams: [
                {
                    key: 'science',
                    label: 'Science',
                    departments: [
                        { key: 'science-general', label: 'General Science', subLevels: [{ key: 'hsc-1', label: 'HSC 1st Year' }, { key: 'hsc-2', label: 'HSC 2nd Year' }] },
                    ],
                },
                {
                    key: 'arts',
                    label: 'Arts',
                    departments: [
                        { key: 'arts-general', label: 'General Arts', subLevels: [{ key: 'hsc-1', label: 'HSC 1st Year' }, { key: 'hsc-2', label: 'HSC 2nd Year' }] },
                    ],
                },
                {
                    key: 'commerce',
                    label: 'Commerce',
                    departments: [
                        { key: 'commerce-general', label: 'General Commerce', subLevels: [{ key: 'hsc-1', label: 'HSC 1st Year' }, { key: 'hsc-2', label: 'HSC 2nd Year' }] },
                    ],
                },
            ],
        },
        {
            key: 'university',
            label: 'University',
            subLevels: [],
            streams: [
                {
                    key: 'science-engineering',
                    label: 'Science & Engineering',
                    departments: [
                        { key: 'cse', label: 'CSE', subLevels: semesters(8) },
                        { key: 'eee', label: 'EEE', subLevels: semesters(8) },
                        { key: 'civil', label: 'Civil Engineering', subLevels: semesters(8) },
                        { key: 'mechanical', label: 'Mechanical Eng.', subLevels: semesters(8) },
                        { key: 'physics', label: 'Physics', subLevels: semesters(8) },
                        { key: 'chemistry', label: 'Chemistry', subLevels: semesters(8) },
                        { key: 'mathematics', label: 'Mathematics', subLevels: semesters(8) },
                        { key: 'biology', label: 'Biology', subLevels: semesters(8) },
                        { key: 'pharmacy', label: 'Pharmacy', subLevels: semesters(8) },
                    ],
                },
                {
                    key: 'arts-humanities',
                    label: 'Arts & Humanities',
                    departments: [
                        { key: 'english', label: 'English', subLevels: semesters(8) },
                        { key: 'bangla', label: 'Bangla', subLevels: semesters(8) },
                        { key: 'history', label: 'History', subLevels: semesters(8) },
                        { key: 'philosophy', label: 'Philosophy', subLevels: semesters(8) },
                        { key: 'islamic-studies', label: 'Islamic Studies', subLevels: semesters(8) },
                        { key: 'political-science', label: 'Political Science', subLevels: semesters(8) },
                        { key: 'sociology', label: 'Sociology', subLevels: semesters(8) },
                    ],
                },
                {
                    key: 'business',
                    label: 'Business & Commerce',
                    departments: [
                        { key: 'bba', label: 'BBA', subLevels: semesters(8) },
                        { key: 'accounting', label: 'Accounting', subLevels: semesters(8) },
                        { key: 'finance', label: 'Finance', subLevels: semesters(8) },
                        { key: 'marketing', label: 'Marketing', subLevels: semesters(8) },
                        { key: 'management', label: 'Management', subLevels: semesters(8) },
                    ],
                },
                {
                    key: 'law',
                    label: 'Law',
                    departments: [
                        { key: 'llb', label: 'LLB', subLevels: semesters(10) },
                        { key: 'llm', label: 'LLM', subLevels: semesters(4) },
                    ],
                },
                {
                    key: 'medical',
                    label: 'Medical',
                    departments: [
                        { key: 'mbbs', label: 'MBBS', subLevels: semesters(10) },
                        { key: 'bds', label: 'BDS', subLevels: semesters(8) },
                        { key: 'nursing', label: 'Nursing', subLevels: semesters(8) },
                    ],
                },
            ],
        },
    ],
    bookTypes: [
        { key: 'nctb', label: 'NCTB' },
        { key: 'guide', label: 'Guide' },
        { key: 'reference', label: 'Reference' },
        { key: 'university_textbook', label: 'Uni Book' },
        { key: 'notes', label: 'Notes' },
        { key: 'question_bank', label: 'Question Bank' },
        { key: 'other', label: 'Other' },
    ],
};

async function seed() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB');

        await EducationConfig.deleteMany({});
        const config = await EducationConfig.create(bangladeshConfig);

        console.log('✅ Education config seeded:');
        console.log(`   ${config.levels.length} levels`);
        config.levels.forEach(l => {
            const streamCount = l.streams?.length ?? 0;
            const subLevelCount = l.subLevels?.length ?? 0;
            if (streamCount > 0) {
                console.log(`   - ${l.label}: ${streamCount} streams`);
                l.streams.forEach(s => {
                    console.log(`     - ${s.label}: ${s.departments.length} departments`);
                });
            } else {
                console.log(`   - ${l.label}: ${subLevelCount} sub-levels (flat)`);
            }
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
