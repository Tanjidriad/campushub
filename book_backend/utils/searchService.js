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
    static async searchListings(query, filters = {}, pagination = { skip: 0, limit: 10 }, sort = '-createdAt') {
        const { skip, limit } = pagination;
        const searchPipeline = [];

        // 1. Initial Match Stage (Base Filters)
        const matchStage = { $match: { status: 'approved' } };

        if (filters.category) matchStage.$match.category = filters.category;
        if (filters.condition) matchStage.$match.condition = filters.condition;
        if (filters.priceType) matchStage.$match.priceType = filters.priceType;
        if (filters.seller) matchStage.$match.seller = filters.seller;
        if (filters.isFeatured !== undefined) matchStage.$match.isFeatured = filters.isFeatured;
        if (filters.$or) matchStage.$match.$or = filters.$or;
        if (filters.educationLevel) matchStage.$match.educationLevel = filters.educationLevel;
        if (filters.stream) matchStage.$match.stream = filters.stream;
        if (filters.department) matchStage.$match.department = filters.department;
        if (filters.classOrSemester) matchStage.$match.classOrSemester = filters.classOrSemester;
        if (filters.subject) matchStage.$match.subject = filters.subject;
        if (filters.bookType) matchStage.$match.bookType = filters.bookType;
        if (filters.division) matchStage.$match.division = filters.division;
        if (filters.district) matchStage.$match.district = filters.district;
        if (filters.upazila) matchStage.$match.upazila = filters.upazila;

        if (filters.minPrice || filters.maxPrice) {
            matchStage.$match.price = {};
            if (filters.minPrice) matchStage.$match.price.$gte = parseFloat(filters.minPrice);
            if (filters.maxPrice) matchStage.$match.price.$lte = parseFloat(filters.maxPrice);
        }

        searchPipeline.push(matchStage);

        // 2. Search Logic (if query exists)
        if (query) {
            // ... (keep existing search logic) ...
            // Clean query (escape regex chars once, then reuse across pipeline stages)
            const escapeRegex = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            const trimmed = query.trim();
            if (!trimmed) return { listings: [], total: 0 };

            const cleanQuery = escapeRegex(trimmed); // escaped phrase used in anchored scoring

            // Build a cheaper pre-filter before computing scores.
            // This significantly reduces the number of documents that must run $regexMatch.
            // Also bound the number of fuzzy tokens to avoid very large regexes.
            const rawTerms = trimmed
                .split(/\s+/)
                .map(t => t.trim())
                .filter(t => t.length > 2);
            const maxFuzzyTerms = 4;
            const boundedTerms = rawTerms.slice(0, maxFuzzyTerms);

            const escapedTerms = boundedTerms.map(escapeRegex);
            const fuzzyRegex = escapedTerms.length ? new RegExp(escapedTerms.join('|'), 'i') : null;
            const fuzzyPattern = escapedTerms.length ? escapedTerms.join('|') : null;
            const tagExact = boundedTerms[0] ? boundedTerms[0].toLowerCase() : '';

            // Early fuzzy match: restrict candidate docs before scoring.
            if (fuzzyRegex) {
                searchPipeline.push({
                    $match: {
                        $or: [
                            { title: { $regex: fuzzyRegex } },
                            { description: { $regex: fuzzyRegex } },
                            { tags: { $in: escapedTerms.map(t => new RegExp(`^${t}`, 'i')) } },
                        ],
                    },
                });
            }

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
                                    0,
                                ],
                            },
                            // Title Begins With (80 points)
                            {
                                $cond: [
                                    { $regexMatch: { input: "$title", regex: `^${cleanQuery}`, options: "i" } },
                                    80,
                                    0,
                                ],
                            },
                            // Description Contains Query (50 points)
                            {
                                $cond: [
                                    { $regexMatch: { input: "$description", regex: fuzzyPattern || cleanQuery, options: "i" } },
                                    50,
                                    0,
                                ],
                            },
                            // Partial Match in Title (30 points)
                            {
                                $cond: [
                                    { $regexMatch: { input: "$title", regex: fuzzyPattern || cleanQuery, options: "i" } },
                                    30,
                                    0,
                                ],
                            },
                            // Match in Tags (20 points) - use first fuzzy token
                            ...(tagExact
                                ? [{
                                    $cond: [
                                        { $in: [tagExact, { $ifNull: ["$tags", []] }] },
                                        20,
                                        0,
                                    ],
                                }]
                                : [{ $literal: 0 }]),
                            // Boost for Condition 'New' (5 points)
                            {
                                $cond: [{ $eq: ["$condition", "new"] }, 5, 0],
                            },
                        ],
                    },
                },
            });

            // Filter out low-relevance candidates (e.g. only "new" boost without query match).
            // Without this, documents can be returned solely due to the Condition='new' boost.
            searchPipeline.push({ $match: { searchScore: { $gt: 5 } } });

            searchPipeline.push({ $sort: { searchScore: -1, createdAt: -1 } });

        } else {
            // No search query, sort by provided sort param
            const sortObj = {};
            if (sort) {
                const sortField = sort.startsWith('-') ? sort.substring(1) : sort;
                const sortOrder = sort.startsWith('-') ? -1 : 1;
                sortObj[sortField] = sortOrder;
            } else {
                sortObj.createdAt = -1;
            }
            searchPipeline.push({ $sort: sortObj });
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
                    // Project necessary fields (security: don't expose sensitive seller data)
                    {
                        $project: {
                            'seller.password': 0,
                            'seller.email': 0,
                            'seller.role': 0,
                            'seller.refreshToken': 0,
                            'seller.fcmTokens': 0,
                            'seller.pushToken': 0,
                            'seller.verificationToken': 0,
                            'seller.verificationTokenExpires': 0,
                            'seller.passwordResetToken': 0,
                            'seller.passwordResetExpires': 0,
                            'seller.blockedUsers': 0,
                            'seller.googleId': 0,
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
