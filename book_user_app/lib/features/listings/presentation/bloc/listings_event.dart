import 'package:equatable/equatable.dart';
import '../../domain/repositories/listing_repository.dart';

abstract class ListingsEvent extends Equatable {
  const ListingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial listings
class ListingsLoadRequested extends ListingsEvent {
  final ListingsParams? params;

  const ListingsLoadRequested({this.params});

  @override
  List<Object?> get props => [params];
}

/// Load more listings (pagination)
class ListingsLoadMoreRequested extends ListingsEvent {
  const ListingsLoadMoreRequested();
}

/// Refresh listings
class ListingsRefreshRequested extends ListingsEvent {
  const ListingsRefreshRequested();
}

/// Filter listings
class ListingsFilterChanged extends ListingsEvent {
  final String? category;
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

  const ListingsFilterChanged({
    this.category,
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
    category,
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
}

/// Search listings
class ListingsSearchRequested extends ListingsEvent {
  final String query;

  const ListingsSearchRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Clear search
class ListingsSearchCleared extends ListingsEvent {
  const ListingsSearchCleared();
}

/// Get listing detail
class ListingDetailRequested extends ListingsEvent {
  final String listingId;

  const ListingDetailRequested({required this.listingId});

  @override
  List<Object?> get props => [listingId];
}

/// Load wishlist
class WishlistLoadRequested extends ListingsEvent {
  const WishlistLoadRequested();
}

/// Toggle wishlist
class ListingWishlistToggled extends ListingsEvent {
  final String listingId;

  const ListingWishlistToggled({required this.listingId});

  @override
  List<Object?> get props => [listingId];
}

/// Create listing
class ListingCreateRequested extends ListingsEvent {
  final String title;
  final String description;
  final String category;
  final String priceType;
  final double? price;
  final String? currency;
  final String? condition;
  final String? locationName;
  final String? locationAddress;
  final String? meetupPreferences;
  final List<String>? tags;
  final List<String> imagePaths;
  final String? educationLevel;
  final String? classOrSemester;
  final String? subject;
  final String? bookType;
  final String? division;
  final String? district;
  final String? upazila;

  const ListingCreateRequested({
    required this.title,
    required this.description,
    required this.category,
    required this.priceType,
    this.price,
    this.currency,
    this.condition,
    this.locationName,
    this.locationAddress,
    this.meetupPreferences,
    this.tags,
    required this.imagePaths,
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
    title,
    description,
    category,
    priceType,
    price,
    currency,
    condition,
    locationName,
    locationAddress,
    meetupPreferences,
    tags,
    imagePaths,
    educationLevel,
    classOrSemester,
    subject,
    bookType,
    division,
    district,
    upazila,
  ];
}

/// Load user's own listings
class MyListingsLoadRequested extends ListingsEvent {
  final String? status;

  const MyListingsLoadRequested({this.status});

  @override
  List<Object?> get props => [status];
}

/// Delete listing
class ListingDeleteRequested extends ListingsEvent {
  final String listingId;

  const ListingDeleteRequested({required this.listingId});

  @override
  List<Object?> get props => [listingId];
}

/// Promote listing (self-serve)
class PromoteListingRequested extends ListingsEvent {
  final String listingId;
  final String plan;

  const PromoteListingRequested({required this.listingId, required this.plan});

  @override
  List<Object?> get props => [listingId, plan];
}

/// Load featured listings
class FeaturedListingsLoadRequested extends ListingsEvent {
  const FeaturedListingsLoadRequested();
}

/// Update listing
class ListingUpdateRequested extends ListingsEvent {
  final String listingId;
  final String? title;
  final String? description;
  final String? category;
  final String? priceType;
  final double? price;
  final String? condition;
  final String? currency;
  final String? locationName;
  final String? locationAddress;
  final String? meetupPreferences;
  final List<String>? tags;
  final String? educationLevel;
  final String? classOrSemester;
  final String? subject;
  final String? bookType;
  final String? division;
  final String? district;
  final String? upazila;

  const ListingUpdateRequested({
    required this.listingId,
    this.title,
    this.description,
    this.category,
    this.priceType,
    this.price,
    this.condition,
    this.currency,
    this.locationName,
    this.locationAddress,
    this.meetupPreferences,
    this.tags,
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
    listingId,
    title,
    description,
    category,
    priceType,
    price,
    condition,
    currency,
    locationName,
    locationAddress,
    meetupPreferences,
    tags,
    educationLevel,
    classOrSemester,
    subject,
    bookType,
    division,
    district,
    upazila,
  ];
}

/// Mark listing as sold
class ListingMarkAsSoldRequested extends ListingsEvent {
  final String listingId;
  final String? buyerId;
  final double? soldPrice;

  const ListingMarkAsSoldRequested({
    required this.listingId,
    this.buyerId,
    this.soldPrice,
  });

  @override
  List<Object?> get props => [listingId, buyerId, soldPrice];
}

/// Delete listing image
class ListingImageDeleteRequested extends ListingsEvent {
  final String listingId;
  final String imageId;

  const ListingImageDeleteRequested({
    required this.listingId,
    required this.imageId,
  });

  @override
  List<Object?> get props => [listingId, imageId];
}
