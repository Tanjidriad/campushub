// Script to seed test reports into the database
// Run with: node seedReports.js

require('dotenv').config();
const mongoose = require('mongoose');
const Report = require('./models/Report');
const User = require('./models/User');
const Listing = require('./models/Listing');

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

// Seed reports
const seedReports = async () => {
    try {
        await connectDB();

        // Get some existing users and listings to create reports (deterministic selection)
        const users = await User.find()
            .sort({ createdAt: 1, _id: 1 })
            .limit(5)
            .lean();
        const listings = await Listing.find()
            .sort({ createdAt: 1, _id: 1 })
            .limit(5)
            .lean();

        if (users.length < 2) {
            console.log('❌ Need at least 2 users in database to create reports');
            console.log('Please create some users first');
            process.exit(1);
        }

        // Use the first user as the reporter (the one filing reports)
        const reporter = users[0];
        console.log(`📝 Using reporter: ${reporter.name} (${reporter.email})`);

        // Clear existing reports (optional - comment out if you want to keep existing)
        await Report.deleteMany({});
        console.log('🗑️  Cleared existing reports');

        const reports = [];

        // Create user reports
        if (users.length > 1) {
            reports.push({
                reporter: reporter._id,
                targetType: 'user',
                targetId: users[1]._id,
                targetModel: 'User',
                reason: 'harassment',
                description: 'This user has been sending inappropriate messages to multiple users.',
                status: 'pending',
            });
        }

        if (users.length > 2) {
            reports.push({
                reporter: reporter._id,
                targetType: 'user',
                targetId: users[2]._id,
                targetModel: 'User',
                reason: 'fraud',
                description: 'This user is scamming people by selling fake items.',
                status: 'pending',
            });
        }

        if (users.length > 3) {
            reports.push({
                reporter: reporter._id,
                targetType: 'user',
                targetId: users[3]._id,
                targetModel: 'User',
                reason: 'spam',
                description: 'Keeps posting the same listing over and over.',
                status: 'reviewed',
                actionTaken: 'warning',
                resolution: 'User has been warned about spam behavior.',
            });
        }

        // Create listing reports
        if (listings.length > 0) {
            reports.push({
                reporter: reporter._id,
                targetType: 'listing',
                targetId: listings[0]._id,
                targetModel: 'Listing',
                reason: 'prohibited_item',
                description: 'This listing contains items that are not allowed on the platform.',
                status: 'pending',
            });
        }

        if (listings.length > 1) {
            reports.push({
                reporter: reporter._id,
                targetType: 'listing',
                targetId: listings[1]._id,
                targetModel: 'Listing',
                reason: 'inappropriate',
                description: 'The images in this listing are inappropriate.',
                status: 'pending',
            });
        }

        if (listings.length > 2) {
            reports.push({
                reporter: reporter._id,
                targetType: 'listing',
                targetId: listings[2]._id,
                targetModel: 'Listing',
                reason: 'wrong_category',
                description: 'This listing is in the wrong category.',
                status: 'resolved',
                actionTaken: 'content_removed',
                resolution: 'Listing has been moved to the correct category.',
            });
        }

        if (listings.length > 3) {
            reports.push({
                reporter: reporter._id,
                targetType: 'listing',
                targetId: listings[3]._id,
                targetModel: 'Listing',
                reason: 'duplicate',
                description: 'This is a duplicate listing of another item.',
                status: 'pending',
            });
        }

        if (listings.length > 4) {
            reports.push({
                reporter: reporter._id,
                targetType: 'listing',
                targetId: listings[4]._id,
                targetModel: 'Listing',
                reason: 'fraud',
                description: 'Price seems too good to be true. Possible scam.',
                status: 'reviewed',
                resolution: 'Under investigation.',
            });
        }

        // Add more pending reports for testing
        if (users.length > 1 && listings.length > 0) {
            // Create reports from different reporters if available
            for (let i = 1; i < Math.min(users.length, 4); i++) {
                if (listings[i % listings.length]) {
                    reports.push({
                        reporter: users[i]._id,
                        targetType: 'listing',
                        targetId: listings[i % listings.length]._id,
                        targetModel: 'Listing',
                        reason: ['spam', 'inappropriate', 'fraud', 'other'][i % 4],
                        description: `Test report #${i + reports.length} from user ${users[i].name}.`,
                        status: 'pending',
                    });
                }
            }
        }

        // Insert reports
        const createdReports = await Report.insertMany(reports);
        console.log(`✅ Created ${createdReports.length} test reports`);

        // Display summary
        const pendingCount = createdReports.filter(r => r.status === 'pending').length;
        const reviewedCount = createdReports.filter(r => r.status === 'reviewed').length;
        const resolvedCount = createdReports.filter(r => r.status === 'resolved').length;

        console.log('\n📊 Report Summary:');
        console.log(`   Pending:  ${pendingCount}`);
        console.log(`   Reviewed: ${reviewedCount}`);
        console.log(`   Resolved: ${resolvedCount}`);
        console.log(`   Total:    ${createdReports.length}`);

        console.log('\n🎉 Seed complete!');
        process.exit(0);
    } catch (error) {
        console.error('❌ Error seeding reports:', error.message);
        
        // Handle duplicate key error
        if (error.code === 11000) {
            console.log('\n💡 Tip: Some reports already exist. Run with fresh database or modify the script.');
        }
        
        process.exit(1);
    }
};

seedReports();
