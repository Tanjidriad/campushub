/**
 * Demo listing seed script.
 *
 * This file is used by `npm run seed:demo` to create ~30 approved listings
 * across departments/categories for the CodeCanyon demo environment.
 */
require('dotenv').config();

const mongoose = require('mongoose');
const Listing = require('./models/Listing');
const User = require('./models/User');

const connectDB = async () => {
    if (!process.env.MONGODB_URI) throw new Error('MONGODB_URI is missing');
    await mongoose.connect(process.env.MONGODB_URI);
};

const sampleImageUrl = (seed) =>
    // Public placeholder; replace with your own assets if desired.
    `https://picsum.photos/seed/${encodeURIComponent(seed)}/600/400`;

async function seedListings() {
    await connectDB();

    const sellers = await User.find({ role: 'student' })
        .sort({ createdAt: 1, _id: 1 })
        .limit(20);
    if (!sellers.length) {
        throw new Error('No student sellers found. Run seedDemo.js first.');
    }

    // Category slugs seeded by `seedCategories.js`:
    // Textbooks -> textbooks, Housing -> housing, Electronics -> electronics, ...
    const categorySlugs = ['textbooks', 'housing', 'electronics', 'services', 'events', 'other'];

    // Wipe existing listings so the demo is deterministic.
    await Listing.deleteMany({});

    const makeSeller = (i) => sellers[i % sellers.length]._id;
    const makeImage = (seed) => ({
        url: sampleImageUrl(seed),
        publicId: `demo_listing_${seed}`,
    });

    // Templates per category: keep them short but meaningful for search relevance.
    const templates = {
        textbooks: [
            {
                title: 'Calculus: Early Transcendentals (8th Edition)',
                description:
                    'Excellent condition. Barely used. Includes access code. Ideal for MATH 141 students.',
                priceType: 'fixed',
                price: 85,
                condition: 'like-new',
                tags: ['calculus', 'math', 'textbook'],
                educationLevel: 'university',
                classOrSemester: 'sem-1',
                subject: 'mathematics',
                bookType: 'university_textbook',
                division: 'science-engineering',
                district: 'Dhaka',
                upazila: 'Tejgaon',
            },
            {
                title: 'Physics Lab Manual - Modern Mechanics',
                description: 'Practical lab manual with clean pages. Great for exam prep and assignments.',
                priceType: 'negotiable',
                price: 40,
                condition: 'good',
                tags: ['physics', 'lab', 'mechanics'],
                educationLevel: 'university',
                classOrSemester: 'sem-2',
                subject: 'physics',
                bookType: 'guide',
                division: 'science-engineering',
                district: 'Chattogram',
                upazila: 'Pahartali',
            },
            {
                title: 'Discrete Mathematics Notes (Semester Pack)',
                description: 'Comprehensive notes + problem sets. Updated for the latest syllabus.',
                priceType: 'free',
                price: 0,
                condition: 'new',
                tags: ['discrete', 'math', 'notes'],
                educationLevel: 'college',
                classOrSemester: 'sem-1',
                subject: 'mathematics',
                bookType: 'notes',
                division: 'college',
                district: 'Rajshahi',
                upazila: 'Boalia',
            },
        ],
        housing: [
            {
                title: 'Studio Apartment - Summer Sublet (3 Months)',
                description: 'Fully furnished near campus. Utilities included. Parking available.',
                priceType: 'fixed',
                price: 750,
                condition: 'good',
                tags: ['apartment', 'sublet', 'housing'],
                division: 'housing',
                district: 'Dhaka',
                upazila: 'Uttara',
            },
            {
                title: 'Room for Rent - Quiet Study Space',
                description: 'A private room with fast Wi-Fi and a dedicated study desk.',
                priceType: 'negotiable',
                price: 520,
                condition: 'like-new',
                tags: ['room', 'rent', 'wifi'],
                division: 'housing',
                district: 'Chattogram',
                upazila: 'Agrabad',
            },
            {
                title: 'Hostel Spot - Short-Term Booking',
                description: 'Need a place for a few weeks? Book a hostel spot with flexible dates.',
                priceType: 'fixed',
                price: 180,
                condition: 'good',
                tags: ['hostel', 'short-term', 'room'],
                division: 'housing',
                district: 'Khulna',
                upazila: 'Sonadanga',
            },
        ],
        electronics: [
            {
                title: 'MacBook Pro 2020 M1 - 16GB RAM',
                description: 'Charger + original box. Battery health ~95%. Perfect for CS work.',
                priceType: 'fixed',
                price: 1200,
                condition: 'good',
                tags: ['macbook', 'm1', 'laptop'],
            },
            {
                title: 'iPad Air - Notes & Drawing Bundle',
                description: 'Includes pencil (compatible). Great for lecture notes and sketching.',
                priceType: 'negotiable',
                price: 480,
                condition: 'like-new',
                tags: ['ipad', 'notes', 'bundle'],
            },
            {
                title: 'Wireless Earbuds - Like New',
                description: 'Clean sound, strong battery. No major scratches, tested and working.',
                priceType: 'fixed',
                price: 65,
                condition: 'like-new',
                tags: ['earbuds', 'audio', 'wireless'],
            },
        ],
        services: [
            {
                title: 'Tutoring Services - Math & Physics',
                description: 'Graduate tutor offering flexible schedules. Meet on campus or online.',
                priceType: 'fixed',
                price: 25,
                condition: 'new',
                tags: ['tutoring', 'math', 'physics'],
            },
            {
                title: 'Move Help - Loading & Unloading',
                description: 'Affordable moving help for students. Quick and careful handling.',
                priceType: 'negotiable',
                price: 35,
                condition: 'good',
                tags: ['moving', 'help', 'logistics'],
            },
            {
                title: 'Assignment Review - Last-Minute Proofreading',
                description: 'Proofread and improve your submission structure, grammar, and formatting.',
                priceType: 'fixed',
                price: 15,
                condition: 'good',
                tags: ['editing', 'review', 'writing'],
            },
        ],
        events: [
            {
                title: 'Campus Music Night - Ticket (2 Seats)',
                description: 'Two tickets. Selling because I’m traveling. Instant delivery via chat.',
                priceType: 'fixed',
                price: 22,
                condition: 'good',
                tags: ['ticket', 'music', 'event'],
            },
            {
                title: 'Workshop: Resume & Interview Prep',
                description: 'Hands-on workshop. Includes printed templates and Q&A session.',
                priceType: 'fixed',
                price: 12,
                condition: 'new',
                tags: ['workshop', 'career', 'interview'],
            },
            {
                title: 'Volunteer Signup Slot (Limited)',
                description: 'One slot available for an upcoming campus volunteering activity.',
                priceType: 'free',
                price: 0,
                condition: 'new',
                tags: ['volunteer', 'campus', 'free-slot'],
            },
        ],
        other: [
            {
                title: 'Handwritten Study Notes - Week 1 Pack',
                description: 'A clean handwritten pack covering core concepts and key examples.',
                priceType: 'fixed',
                price: 8,
                condition: 'good',
                tags: ['notes', 'study', 'handwritten'],
            },
            {
                title: 'Used Math Workbook - Minimal Marks',
                description: 'Light usage. Great for getting back to practice and problem drilling.',
                priceType: 'negotiable',
                price: 10,
                condition: 'like-new',
                tags: ['workbook', 'math', 'practice'],
            },
            {
                title: 'Free - Summary Sheets (All Levels)',
                description: 'Printable summary sheets with key formulas and step-by-step solutions.',
                priceType: 'free',
                price: 0,
                condition: 'new',
                tags: ['summary', 'free', 'formulas'],
            },
        ],
    };

    // Create ~30 listings total (roughly 5 per category).
    const listings = [];
    const totalPerCategory = 5;
    let idx = 0;

    for (const category of categorySlugs) {
        const catTemplates = templates[category] || [];
        for (let j = 0; j < totalPerCategory; j++) {
            const t = catTemplates[j % catTemplates.length];
            if (!t) continue;

            listings.push({
                seller: makeSeller(idx),
                title: `${t.title} #${j + 1}`,
                description: t.description,
                images: [makeImage(`${category}_${idx}_${j}`)],
                category,
                priceType: t.priceType,
                price: t.priceType === 'free' ? 0 : t.price,
                condition: t.condition || 'good',
                status: 'approved',
                tags: t.tags || [],
                educationLevel: t.educationLevel || undefined,
                classOrSemester: t.classOrSemester || undefined,
                subject: t.subject || undefined,
                bookType: t.bookType || undefined,
                division: t.division || undefined,
                district: t.district || undefined,
                upazila: t.upazila || undefined,
                meetupPreferences: 'public',
                isFeatured: false,
                featuredUntil: null,
                featuredPlan: null,
            });

            idx += 1;
        }
    }

    await Listing.insertMany(listings);

    console.log(`✅ Seeded ${listings.length} approved listings`);

    await mongoose.disconnect();
}

seedListings()
    .then(() => process.exit(0))
    .catch((err) => {
        console.error('❌ Error seeding demo listings:', err);
        process.exit(1);
    });
