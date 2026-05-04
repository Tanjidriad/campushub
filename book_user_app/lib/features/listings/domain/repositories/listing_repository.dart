import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/listing.dart';

/// Parameters for fetching listings with pagination and filters
class ListingsParams {
  final int page;
  final int limit;
  final String? category;
  final String? condition;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;
  final String? sortOrder;
  final String? sellerId;
  final bool? isFeatured;
  // Education filters
  final String? educationLevel;
  final String? classOrSemester;
  final String? subject;
  final String? bookType;
  // BD location filters
  final String? division;
  final String? district;
  final String? upazila;

  const ListingsParams({
    this.page = 1,
    this.limit = 10,
    this.category,
    this.condition,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
    this.sortOrder,
    this.sellerId,
    this.isFeatured,
    this.educationLevel,
    this.classOrSemester,
    this.subject,
    this.bookType,
    this.division,
    this.district,
    this.upazila,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (category != null) params['category'] = category;
    if (condition != null) params['condition'] = condition;
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (sortBy != null) params['sortBy'] = sortBy;
    if (sortOrder != null) params['sortOrder'] = sortOrder;
    if (sellerId != null) params['sellerId'] = sellerId;
    if (isFeatured != null) params['isFeatured'] = isFeatured;
    if (educationLevel != null) params['educationLevel'] = educationLevel;
    if (classOrSemester != null) params['classOrSemester'] = classOrSemester;
    if (subject != null) params['subject'] = subject;
    if (bookType != null) params['bookType'] = bookType;
    if (division != null) params['division'] = division;
    if (district != null) params['district'] = district;
    if (upazila != null) params['upazila'] = upazila;
    return params;
  }
}

/// Paginated response wrapper
class PaginatedListings {
  final List<Listing> listings;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;

  const PaginatedListings({
    required this.listings,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasMore,
  });
}

/// Abstract repository for listings
abstract class ListingRepository {
  /// Get all approved listings with pagination
  Future<Either<Failure, PaginatedListings>> getListings(ListingsParams params);

  /// Get a single listing by ID
  Future<Either<Failure, Listing>> getListingById(String id);

  /// Search listings
  Future<Either<Failure, PaginatedListings>> searchListings({
    required String query,
    int page = 1,
    int limit = 10,
  });

  /// Get listings by category
  Future<Either<Failure, PaginatedListings>> getListingsByCategory({
    required String category,
    int page = 1,
    int limit = 10,
  });

  /// Get user's own listings
  Future<Either<Failure, PaginatedListings>> getMyListings({
    int page = 1,
    int limit = 10,
    String? status,
  });

  /// Create a new listing
  Future<Either<Failure, Listing>> createListing({
    required String title,
    required String description,
    required String category,
    required String priceType,
    double? price,
    String? currency,
    String? condition,
    String? locationName,
    String? locationAddress,
    String? meetupPreferences,
    List<String>? tags,
    required List<String> imagePaths,
    String? educationLevel,
    String? classOrSemester,
    String? subject,
    String? bookType,
    String? division,
    String? district,
    String? upazila,
  });

  /// Update an existing listing
  Future<Either<Failure, Listing>> updateListing({
    required String id,
    String? title,
    String? description,
    String? category,
    String? priceType,
    double? price,
    String? currency,
    String? condition,
    String? locationName,
    String? locationAddress,
    String? meetupPreferences,
    List<String>? tags,
    String? educationLevel,
    String? classOrSemester,
    String? subject,
    String? bookType,
    String? division,
    String? district,
    String? upazila,
  });

  /// Delete a listing
  Future<Either<Failure, void>> deleteListing(String id);

  /// Delete an image from a listing
  Future<Either<Failure, Listing>> deleteListingImage(String listingId, String imageId);

  /// Toggle wishlist for a listing
  Future<Either<Failure, bool>> toggleWishlist(String listingId);

  /// Get user's wishlist
  Future<Either<Failure, List<Listing>>> getWishlist();

  /// Get available categories
  Future<Either<Failure, List<String>>> getCategories();

  /// Promote a listing (self-serve)
  Future<Either<Failure, Listing>> promoteListing(
    String listingId,
    String plan,
  );

  /// Mark a listing as sold
  Future<Either<Failure, void>> markAsSold(
    String listingId, {
    String? buyerId,
    double? soldPrice,
  });

  /// Get similar listings
  Future<Either<Failure, List<Listing>>> getSimilarListings(String listingId);

  /// Get recommended listings for user
  Future<Either<Failure, List<Listing>>> getRecommendedListings({int limit = 10});
}
