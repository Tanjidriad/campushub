const mongoose = require('mongoose');
const SearchService = require('./utils/searchService');
const Listing = require('./models/Listing');
const User = require('./models/User'); // Required for population
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '.env') });

// Mute console logs during test setup if needed
// console.log = () => {};

async function testSearch() {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected to DB');

        // Test Cases
        const testCases = [
            { query: 'Calculus', desc: 'Exact Match' },
            { query: 'Calclus', desc: 'Typo / Fuzzy Match' },
            { query: 'Chem', desc: 'Partial Match' },
            { query: 'Java Provgramming', desc: 'Multi-word Typo' }
        ];

        for (const test of testCases) {
            console.log(`\n--- Testing: ${test.desc} ("${test.query}") ---`);
            const start = Date.now();
            const { listings, total } = await SearchService.searchListings(test.query, {}, { skip: 0, limit: 5 });
            const duration = Date.now() - start;

            console.log(`Found ${total} results in ${duration}ms`);
            if (listings.length > 0) {
                listings.forEach((l, i) => {
                    console.log(`#${i + 1}: [Score: ${l.searchScore}] ${l.title}`);
                });
            } else {
                console.log('No results found.');
            }
        }

    } catch (err) {
        console.error('Test Error:', err);
    } finally {
        await mongoose.disconnect();
        console.log('\nTest Finished');
    }
}

testSearch();
