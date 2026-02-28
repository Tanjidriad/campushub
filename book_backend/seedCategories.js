// Script to seed initial categories into the database
// Run with: node seedCategories.js

require('dotenv').config();
const mongoose = require('mongoose');
const Category = require('./models/Category');

// Connect to MongoDB
const connectDB = async () => {
    try {
        const conn = await mongoose.connect(process.env.MONGODB_URI);
        console.log(`MongoDB Connected: ${conn.connection.host}`);
    } catch (error) {
        console.error(`Error: ${error.message}`);
        process.exit(1);
    }
};

// Initial categories to seed
const initialCategories = [
    {
        name: 'Textbooks',
        description: 'Academic textbooks and course materials',
        icon: 'book',
        displayOrder: 1,
    },
    {
        name: 'Housing',
        description: 'Rental properties, roommate postings, and housing listings',
        icon: 'home',
        displayOrder: 2,
    },
    {
        name: 'Electronics',
        description: 'Laptops, phones, tablets, and other electronic devices',
        icon: 'laptop',
        displayOrder: 3,
    },
    {
        name: 'Services',
        description: 'Tutoring, moving help, and other student services',
        icon: 'build',
        displayOrder: 4,
    },
    {
        name: 'Events',
        description: 'Campus events, tickets, and activities',
        icon: 'event',
        displayOrder: 5,
    },
    {
        name: 'Other',
        description: 'Miscellaneous items and listings',
        icon: 'category',
        displayOrder: 6,
    },
];

const seedCategories = async () => {
    try {
        await connectDB();

        // Check if categories already exist
        const existingCount = await Category.countDocuments();

        if (existingCount > 0) {
            console.log(`⚠️  Database already has ${existingCount} categories`);
            console.log('Do you want to delete existing categories and reseed? (Ctrl+C to cancel)');
            
            // Wait 3 seconds before proceeding
            await new Promise(resolve => setTimeout(resolve, 3000));

            // Clear existing categories
            await Category.deleteMany({});
            console.log('🗑️  Cleared existing categories');
        }

        // Insert initial categories one by one to trigger pre-save hooks
        const categories = [];
        for (const catData of initialCategories) {
            const category = await Category.create(catData);
            categories.push(category);
        }

        console.log('\n✅ Successfully seeded categories:');
        categories.forEach(cat => {
            console.log(`   - ${cat.name} (${cat.slug}) - Order: ${cat.displayOrder}`);
        });

        console.log(`\n📊 Total categories created: ${categories.length}\n`);

        process.exit(0);
    } catch (error) {
        console.error('❌ Error seeding categories:', error);
        process.exit(1);
    }
};

// Run the seed function
seedCategories();
