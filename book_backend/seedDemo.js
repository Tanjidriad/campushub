/**
 * Unified demo seeding entrypoint.
 *
 * Run with:
 *   npm run seed:demo
 *
 * This script:
 * - Wipes relevant collections
 * - Creates Super Admin + Demo Admin (isDemo=true) + dummy students
 * - Runs existing seed scripts for categories, education config, listings, reports
 */
require('dotenv').config();

const mongoose = require('mongoose');
const childProcess = require('child_process');
const path = require('path');

const User = require('./models/User');
const Category = require('./models/Category');
const Listing = require('./models/Listing');
const Report = require('./models/Report');
const EducationConfig = require('./models/EducationConfig');

const connectDB = async () => {
    const conn = await mongoose.connect(process.env.MONGODB_URI);
    return conn;
};

const runNodeScript = (scriptName) => {
    // Use execSync so failures stop the seed pipeline.
    const scriptPath = path.join(__dirname, scriptName);
    childProcess.execSync(`node "${scriptPath}"`, { stdio: 'inherit' });
};

async function seedDemo() {
    if (!process.env.MONGODB_URI) {
        throw new Error('MONGODB_URI is missing in environment');
    }

    await connectDB();

    // Wipe relevant collections (keep this list tight to avoid surprises).
    await Promise.all([
        User.deleteMany({}),
        Category.deleteMany({}),
        Listing.deleteMany({}),
        Report.deleteMany({}),
        EducationConfig.deleteMany({}),
    ]);

    // Demo credentials used for CodeCanyon retail demo.
    // Prefer setting DEMO_ADMIN_PASSWORD in your environment; we keep a fallback for convenience.
    let password = process.env.DEMO_ADMIN_PASSWORD;
    if (!password) {
        password = 'Demo1234!';
        console.warn('[seed:demo] DEMO_ADMIN_PASSWORD is not set; using fallback password "Demo1234!"');
    }
    const superAdmin = {
        email: process.env.SUPERADMIN_EMAIL || 'superadmin@demo.com',
        name: 'Super Admin',
        role: 'superadmin',
        isDemo: false,
        isVerified: true,
    };
    const demoAdmin = {
        email: process.env.DEMO_ADMIN_EMAIL || 'demoadmin@demo.com',
        name: 'Demo Admin',
        role: 'admin',
        isDemo: true,
        isVerified: true,
    };

    // Create admins first so downstream seeds have admin-owned references if needed.
    await User.create({
        email: superAdmin.email,
        password,
        name: superAdmin.name,
        role: superAdmin.role,
        isDemo: superAdmin.isDemo,
        isVerified: superAdmin.isVerified,
    });

    await User.create({
        email: demoAdmin.email,
        password,
        name: demoAdmin.name,
        role: demoAdmin.role,
        isDemo: demoAdmin.isDemo,
        isVerified: demoAdmin.isVerified,
    });

    // Dummy students (10)
    const studentPassword = password;
    const dummyStudents = Array.from({ length: 10 }, (_, i) => ({
        email: `student${i + 1}@demo.com`,
        name: `Student ${i + 1}`,
        role: 'student',
        isVerified: true,
        isDemo: false,
        password: studentPassword,
    }));

    for (const s of dummyStudents) {
        // eslint-disable-next-line no-await-in-loop
        await User.create({
            email: s.email,
            password: s.password,
            name: s.name,
            role: s.role,
            isDemo: s.isDemo,
            isVerified: s.isVerified,
        });
    }

    await mongoose.disconnect();

    // Run the existing seed pipeline.
    // Order matters: categories + education -> listings -> reports.
    runNodeScript('seedCategories.js');
    runNodeScript('seed-education.js');
    runNodeScript('test-create-listings.js');
    runNodeScript('seedReports.js');

    console.log('Seed demo complete ✅');
}

seedDemo()
    .then(() => process.exit(0))
    .catch((err) => {
        console.error('Seed demo failed ❌', err);
        process.exit(1);
    });

