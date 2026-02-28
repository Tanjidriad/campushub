import 'package:equatable/equatable.dart';
import '../../domain/entities/listing.dart';

abstract class ListingsState extends Equatable {
  const ListingsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ListingsInitial extends ListingsState {
  const ListingsInitial();
}

/// Loading listings
class ListingsLoading extends ListingsState {
  final String? category;

  const ListingsLoading({this.category});

  @override
  List<Object?> get props => [category];
}

/// Listings loaded successfully
class ListingsLoaded extends ListingsState {
  final List<Listing> listings;
  final List<Listing> featuredListings;
  final List<Listing> staffPicks;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;
  final bool isLoadingMore;
  final String? category;
  final String? searchQuery;
  final String? condition;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;
  final String? sortOrder;
  final String? educationLevel;
  final String? classOrSemester;
  final String? subject;
  final String? bookType;
  final String? division;
  final String? district;
  final String? upazila;

  const ListingsLoaded({
    required this.listings,
    this.featuredListings = const [],
    this.staffPicks = const [],
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasMore,
    this.isLoadingMore = false,
    this.category,
    this.searchQuery,
    this.condition,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
    this.sortOrder,
    this.educationLevel,
    this.classOrSemester,
    this.subject,
    this.bookType,
    this.division,
    this.district,
    this.upazila,
  });

  @override
  List<Object?> get props => [
    listings,
    featuredListings,
    staffPicks,
    currentPage,
    totalPages,
    totalItems,
    hasMore,
    isLoadingMore,
    category,
    searchQuery,
    condition,
    minPrice,
    maxPrice,
    sortBy,
    sortOrder,
    educationLevel,
    classOrSemester,
    subject,
    bookType,
    division,
    district,
    upazila,
  ];

  ListingsLoaded copyWith({
    List<Listing>? listings,
    List<Listing>? featuredListings,
    List<Listing>? staffPicks,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? hasMore,
    bool? isLoadingMore,
    String? category,
    String? searchQuery,
    String? condition,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    String? educationLevel,
    String? classOrSemester,
    String? subject,
    String? bookType,
    String? division,
    String? district,
    String? upazila,
  }) {
    return ListingsLoaded(
      listings: listings ?? this.listings,
      featuredListings: featuredListings ?? this.featuredListings,
      staffPicks: staffPicks ?? this.staffPicks,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
      condition: condition ?? this.condition,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      educationLevel: educationLevel ?? this.educationLevel,
      classOrSemester: classOrSemester ?? this.classOrSemester,
      subject: subject ?? this.subject,
      bookType: bookType ?? this.bookType,
      division: division ?? this.division,
      district: district ?? this.district,
      upazila: upazila ?? this.upazila,
    );
  }
}

/// Listing detail loading
class ListingDetailLoading extends ListingsState {
  const ListingDetailLoading();
}

/// Listing detail loaded
class ListingDetailLoaded extends ListingsState {
  final Listing listing;

  const ListingDetailLoaded({required this.listing});

  @override
  List<Object?> get props => [listing];
}

/// Creating listing
class ListingCreating extends ListingsState {
  const ListingCreating();
}

/// Listing created successfully
class ListingCreated extends ListingsState {
  final Listing listing;

  const ListingCreated({required this.listing});

  @override
  List<Object?> get props => [listing];
}

/// My listings loaded
class MyListingsLoaded extends ListingsState {
  final List<Listing> listings;
  final int currentPage;
  final bool hasMore;
  final String? statusFilter;

  const MyListingsLoaded({
    required this.listings,
    required this.currentPage,
    required this.hasMore,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [listings, currentPage, hasMore, statusFilter];
}

/// Wishlist loaded
class WishlistLoaded extends ListingsState {
  final List<Listing> listings;

  const WishlistLoaded({required this.listings});

  @override
  List<Object?> get props => [listings];
}

/// Wishlist toggled
class WishlistToggled extends ListingsState {
  final String listingId;
  final bool isInWishlist;

  const WishlistToggled({required this.listingId, required this.isInWishlist});

  @override
  List<Object?> get props => [listingId, isInWishlist];
}

/// Listing deleted
class ListingDeleted extends ListingsState {
  final String listingId;

  const ListingDeleted({required this.listingId});

  @override
  List<Object?> get props => [listingId];
}

/// Error state
class ListingsError extends ListingsState {
  final String message;

  const ListingsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Promoting listing
class ListingPromoting extends ListingsState {
  const ListingPromoting();
}

/// Listing promoted successfully
class ListingPromoted extends ListingsState {
  final Listing listing;

  const ListingPromoted({required this.listing});

  @override
  List<Object?> get props => [listing];
}

/// Updating listing
class ListingUpdating extends ListingsState {
  const ListingUpdating();
}

/// Listing updated successfully
class ListingUpdated extends ListingsState {
  final Listing listing;

  const ListingUpdated({required this.listing});

  @override
  List<Object?> get props => [listing];
}

/// Marking listing as sold
class ListingMarkingAsSold extends ListingsState {
  const ListingMarkingAsSold();
}

/// Listing marked as sold successfully
class ListingMarkedAsSold extends ListingsState {
  final String listingId;

  const ListingMarkedAsSold({required this.listingId});

  @override
  List<Object?> get props => [listingId];
}
