import 'package:equatable/equatable.dart';

/// Image object for listing photos
class ListingImage extends Equatable {
  final String url;
  final String publicId;

  const ListingImage({required this.url, required this.publicId});

  @override
  List<Object?> get props => [url, publicId];
}

/// Location object with optional coordinates
class ListingLocation extends Equatable {
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;

  const ListingLocation({
    this.name,
    this.address,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [name, address, latitude, longitude];
}

/// Seller info (minimal user data)
class SellerInfo extends Equatable {
  final String id;
  final String name;
  final String? avatar;
  final String? username;
  final bool isVerified;
  final double? rating;
  final DateTime? createdAt;

  const SellerInfo({
    required this.id,
    required this.name,
    this.avatar,
    this.username,
    this.isVerified = false,
    this.rating,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    avatar,
    username,
    isVerified,
    rating,
    createdAt,
  ];
}

/// Main Listing entity
class Listing extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<ListingImage> images;
  final String category;
  final String priceType; // fixed, negotiable, free, auction
  final double? price;
  final double? previousPrice;
  final DateTime? priceDroppedAt;
  final String? highlightType; // 'price_drop' | 'new_arrival' | null
  final String currency;
  final String condition; // new, like-new, good, fair, poor
  final ListingLocation? location;
  final String meetupPreferences; // public, campus, flexible
  final String status; // pending, approved, rejected, sold, expired
  final int views;
  final int wishlistCount;
  final int inquiries;
  final bool isFeatured;
  final DateTime? featuredUntil;
  final String? featuredPlan;
  final List<String> tags;
  final SellerInfo? seller;
  final String? sellerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;
  final bool isInWishlist; // User-specific

  // Education metadata
  final String? educationLevel; // school, college, university, other
  final String? classOrSemester; // "Class 6", "HSC 1st Year", "Semester 3"
  final String? subject;
  final String? bookType; // nctb, guide, reference, university_textbook, other

  // Bangladesh-specific location
  final String? division;
  final String? district;
  final String? upazila;

  const Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.category,
    required this.priceType,
    this.price,
    this.previousPrice,
    this.priceDroppedAt,
    this.highlightType,
    this.currency = 'USD',
    this.condition = 'good',
    this.location,
    this.meetupPreferences = 'public',
    this.status = 'pending',
    this.views = 0,
    this.wishlistCount = 0,
    this.inquiries = 0,
    this.isFeatured = false,
    this.featuredUntil,
    this.featuredPlan,
    this.tags = const [],
    this.seller,
    this.sellerId,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
    this.isInWishlist = false,
    this.educationLevel,
    this.classOrSemester,
    this.subject,
    this.bookType,
    this.division,
    this.district,
    this.upazila,
  });

  /// Format price for display
  String get formattedPrice {
    if (priceType == 'free') return 'Free';
    if (price == null) return 'Contact for price';
    return '$currency ${price!.toStringAsFixed(2)}';
  }

  /// Get primary image URL
  String? get primaryImageUrl => images.isNotEmpty ? images.first.url : null;

  /// Check if listing is active
  bool get isActive => status == 'approved';

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    images,
    category,
    priceType,
    price,
    previousPrice,
    priceDroppedAt,
    highlightType,
    currency,
    condition,
    location,
    meetupPreferences,
    status,
    views,
    wishlistCount,
    inquiries,
    isFeatured,
    featuredUntil,
    featuredPlan,
    tags,
    seller,
    sellerId,
    createdAt,
    updatedAt,
    expiresAt,
    isInWishlist,
    educationLevel,
    classOrSemester,
    subject,
    bookType,
    division,
    district,
    upazila,
  ];

  /// Copy with method for immutability
  Listing copyWith({
    String? id,
    String? title,
    String? description,
    List<ListingImage>? images,
    String? category,
    String? priceType,
    double? price,
    double? previousPrice,
    DateTime? priceDroppedAt,
    String? highlightType,
    String? currency,
    String? condition,
    ListingLocation? location,
    String? meetupPreferences,
    String? status,
    int? views,
    int? wishlistCount,
    int? inquiries,
    bool? isFeatured,
    DateTime? featuredUntil,
    String? featuredPlan,
    List<String>? tags,
    SellerInfo? seller,
    String? sellerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    bool? isInWishlist,
    String? educationLevel,
    String? classOrSemester,
    String? subject,
    String? bookType,
    String? division,
    String? district,
    String? upazila,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      images: images ?? this.images,
      category: category ?? this.category,
      priceType: priceType ?? this.priceType,
      price: price ?? this.price,
      previousPrice: previousPrice ?? this.previousPrice,
      priceDroppedAt: priceDroppedAt ?? this.priceDroppedAt,
      highlightType: highlightType ?? this.highlightType,
      currency: currency ?? this.currency,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      meetupPreferences: meetupPreferences ?? this.meetupPreferences,
      status: status ?? this.status,
      views: views ?? this.views,
      wishlistCount: wishlistCount ?? this.wishlistCount,
      inquiries: inquiries ?? this.inquiries,
      isFeatured: isFeatured ?? this.isFeatured,
      featuredUntil: featuredUntil ?? this.featuredUntil,
      featuredPlan: featuredPlan ?? this.featuredPlan,
      tags: tags ?? this.tags,
      seller: seller ?? this.seller,
      sellerId: sellerId ?? this.sellerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isInWishlist: isInWishlist ?? this.isInWishlist,
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
