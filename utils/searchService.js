const Listing = require('../models/Listing');
const User = require('../models/User');

class SearchService {
    /**
     * Search listings with advanced logic (Exact -> Text -> Fuzzy)
     * @param {string} query - Search term
     * @param {Object} filters - Valid filters (category, price, etc.)
     * @param {Object} pagination - { skip, limit }
     * @returns {Promise<{listings: Array, total: Number}>}
     */
    static async searchListings(query, filters = {}, pagination = { skip: 0, limit: 10 }) {
        const { skip, limit } = pagination;
        const searchPipeline = [];

        // 1. Initial Match Stage (Base Filters)
        const matchStage = { $match: { status: 'approved' } };

        if (filters.category) matchStage.$match.category = filters.category;
        if (filters.condition) matchStage.$match.condition = filters.condition;
        if (filters.priceType) matchStage.$match.priceType = filters.priceType;
        if (filters.seller) matchStage.$match.seller = filters.seller;

        if (filters.minPrice || filters.maxPrice) {
            matchStage.$match.price = {};
            if (filters.minPrice) matchStage.$match.price.$gte = parseFloat(filters.minPrice);
            if (filters.maxPrice) matchStage.$match.price.$lte = parseFloat(filters.maxPrice);
        }

        searchPipeline.push(matchStage);

        // 2. Search Logic (if query exists)
        if (query) {
            // Clean query
            const cleanQuery = query.trim().replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); // Escape regex chars
            if (!cleanQuery) return { listings: [], total: 0 };

            searchPipeline.push({
                $addFields: {
                    // Score calculation
                    searchScore: {
                        $sum: [
                            // Exact Title Match (100 points)
                            {
                                $cond: [
                                    { $regexMatch: { input: "$title", regex: `^${cleanQuery}$`, options: "i" } },
                                    100,
                                    0
                                ]
                            },
                            // Title Begins With (80 points)
                            {
                                $cond: [
                                    { $regexMatch: { input: "$title", regex: `^${cleanQuery}`, options: "i" } },
                                    80,
                                    0
                                ]
                            },
                            // Description Contains Query (50 points)
                            {
                                $cond: [
                                    { $regexMatch: { input: "$description", regex: cleanQuery, options: "i" } },
                                    50,
                                    0
                                ]
                            },
                            // Partial/Fuzzy Match in Title (30 points)
                            {
                                $cond: [
                                    { $regexMatch: { input: "$title", regex: cleanQuery, options: "i" } },
                                    30,
                                    0
                                ]
                            },
                            // Match in Tags (20 points)
                            {
                                $cond: [
                                    { $in: [cleanQuery.toLowerCase(), { $ifNull: ["$tags", []] }] },
                                    20,
                                    0
                                ]
                            },
                            // Boost for Condition 'New' (5 points)
                            {
                                $cond: [{ $eq: ["$condition", "new"] }, 5, 0]
                            }
                        ]
                    }
                }
            });

            // Filter out zero-score results (irrelevant)
            // Note: If using $text, MongoDB requires it to be the first stage usually, 
            // but since we are doing custom aggregation, we might need a workaround for $text inside $addFields or just rely on regex.
            // For true "Dynamic Search" without Atlas Search, Regex is robust for small-medium datasets.

            // To support "Fuzzy" (typo tolerance) properly without Atlas text search, 
            // we can split query into words and match any.
            const terms = cleanQuery.split(/\s+/).filter(t => t.length > 2).join('|');
            const fuzzyRegex = terms ? new RegExp(terms, 'i') : null;

            if (fuzzyRegex) {
                searchPipeline.push({
                    $match: {
                        $or: [
                            { title: { $regex: fuzzyRegex } },
                            { description: { $regex: fuzzyRegex } },
                            { tags: { $in: cleanQuery.split(/\s+/).map(t => new RegExp(`^${t}`, 'i')) } }
                        ]
                    }
                });
            }

            // Re-filter to ensure score > 0 effectively (implicit by match above)
            searchPipeline.push({ $sort: { searchScore: -1, createdAt: -1 } });

        } else {
            // No search query, just sort by date
            searchPipeline.push({ $sort: { createdAt: -1 } });
        }

        // 3. Facets for Pagination and Count
        searchPipeline.push({
            $facet: {
                data: [
                    { $skip: skip },
                    { $limit: limit },
                    {
                        $lookup: {
                            from: 'users',
                            localField: 'seller',
                            foreignField: '_id',
                            as: 'seller'
                        }
                    },
                    { $unwind: '$seller' }, // Convert array to object
                    // Project necessary fields (security: don't expose seller password/email)
                    {
                        $project: {
                            'seller.password': 0,
                            'seller.email': 0,
                            'seller.role': 0
                        }
                    }
                ],
                totalCount: [{ $count: 'count' }]
            }
        });

        const results = await Listing.aggregate(searchPipeline);

        if (!results || results.length === 0) {
            return { listings: [], total: 0 };
        }

        const data = results[0].data || [];
        const total = results[0].totalCount && results[0].totalCount[0] ? results[0].totalCount[0].count : 0;

        return { listings: data, total };
    }
}

module.exports = SearchService;
