import '../../domain/entities/listing.dart';

/// Model for ListingImage with JSON serialization
class ListingImageModel extends ListingImage {
  const ListingImageModel({required super.url, required super.publicId});

  factory ListingImageModel.fromJson(Map<String, dynamic> json) {
    return ListingImageModel(
      url: json['url'] ?? '',
      publicId: json['publicId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'publicId': publicId};
  }
}

/// Model for ListingLocation with JSON serialization
class ListingLocationModel extends ListingLocation {
  const ListingLocationModel({
    super.name,
    super.address,
    super.latitude,
    super.longitude,
  });

  factory ListingLocationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ListingLocationModel();
    }

    double? lat;
    double? lng;

    // Handle GeoJSON coordinates [longitude, latitude]
    if (json['coordinates'] != null && json['coordinates'] is List) {
      final coords = json['coordinates'] as List;
      if (coords.length >= 2) {
        lng = (coords[0] as num?)?.toDouble();
        lat = (coords[1] as num?)?.toDouble();
      }
    }

    return ListingLocationModel(
      name: json['name'] as String?,
      address: json['address'] as String?,
      latitude: lat,
      longitude: lng,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (address != null) json['address'] = address;
    if (latitude != null && longitude != null) {
      json['coordinates'] = [longitude, latitude];
    }
    return json;
  }
}

/// Model for SellerInfo with JSON serialization
class SellerInfoModel extends SellerInfo {
  const SellerInfoModel({
    required super.id,
    required super.name,
    super.avatar,
    super.username,
    super.isVerified,
    super.rating,
  });

  factory SellerInfoModel.fromJson(Map<String, dynamic> json) {
    final id = json['_id'] ?? json['id'];
    if (id == null || id.toString().isEmpty) {
      throw FormatException(
        'Seller ID is required but was null or empty in JSON: $json',
      );
    }

    return SellerInfoModel(
      id: id.toString(),
      name: json['name'] ?? 'Unknown',
      avatar: json['avatar'] as String?,
      username: json['username'] as String?,
      isVerified: json['isVerified'] ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }
}

/// Main ListingModel with JSON serialization
class ListingModel extends Listing {
  const ListingModel({
    required super.id,
    required super.title,
    required super.description,
    required super.images,
    required super.category,
    required super.priceType,
    super.price,
    super.currency,
    super.condition,
    super.location,
    super.meetupPreferences,
    super.status,
    super.views,
    super.wishlistCount,
    super.inquiries,
    super.isFeatured,
    super.featuredUntil,
    super.featuredPlan,
    super.tags,
    super.seller,
    super.sellerId,
    required super.createdAt,
    required super.updatedAt,
    super.expiresAt,
    super.isInWishlist,
    super.educationLevel,
    super.classOrSemester,
    super.subject,
    super.bookType,
    super.division,
    super.district,
    super.upazila,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    // Parse images
    final images = <ListingImageModel>[];
    if (json['images'] != null && json['images'] is List) {
      for (final img in json['images']) {
        if (img is Map<String, dynamic>) {
          images.add(ListingImageModel.fromJson(img));
        }
      }
    }

    // Parse seller
    SellerInfoModel? seller;
    if (json['seller'] != null && json['seller'] is Map<String, dynamic>) {
      seller = SellerInfoModel.fromJson(json['seller']);
    }

    // Parse tags
    final tags = <String>[];
    if (json['tags'] != null && json['tags'] is List) {
      for (final tag in json['tags']) {
        if (tag is String) {
          tags.add(tag);
        }
      }
    }

    // Parse dates
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return ListingModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      images: images,
      category: json['category'] ?? '',
      priceType: json['priceType'] ?? 'fixed',
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] ?? 'USD',
      condition: json['condition'] ?? 'good',
      location: ListingLocationModel.fromJson(json['location']),
      meetupPreferences: json['meetupPreferences'] ?? 'public',
      status: json['status'] ?? 'pending',
      views: json['views'] ?? 0,
      wishlistCount: json['wishlistCount'] ?? 0,
      inquiries: json['inquiries'] ?? 0,
      isFeatured: json['isFeatured'] ?? false,
      featuredUntil: json['featuredUntil'] != null
          ? parseDate(json['featuredUntil'])
          : null,
      featuredPlan: json['featuredPlan'] as String?,
      tags: tags,
      seller: seller,
      sellerId: json['seller'] is String
          ? json['seller']
          : (json['seller'] is Map<String, dynamic>
                ? (json['seller']['_id'] ?? json['seller']['id'])
                : null),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      expiresAt: json['expiresAt'] != null
          ? parseDate(json['expiresAt'])
          : null,
      isInWishlist: json['isInWishlist'] ?? false,
      educationLevel: json['educationLevel'] as String?,
      classOrSemester: json['classOrSemester'] as String?,
      subject: json['subject'] as String?,
      bookType: json['bookType'] as String?,
      division: json['division'] as String?,
      district: json['district'] as String?,
      upazila: json['upazila'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'priceType': priceType,
      if (price != null) 'price': price,
      'currency': currency,
      'condition': condition,
      if (location != null)
        'location': (location as ListingLocationModel?)?.toJson(),
      'meetupPreferences': meetupPreferences,
      'tags': tags,
      if (educationLevel != null) 'educationLevel': educationLevel,
      if (classOrSemester != null) 'classOrSemester': classOrSemester,
      if (subject != null) 'subject': subject,
      if (bookType != null) 'bookType': bookType,
      if (division != null) 'division': division,
      if (district != null) 'district': district,
      if (upazila != null) 'upazila': upazila,
    };
  }

  /// Convert entity to model
  factory ListingModel.fromEntity(Listing listing) {
    return ListingModel(
      id: listing.id,
      title: listing.title,
      description: listing.description,
      images: listing.images
          .map((img) => ListingImageModel(url: img.url, publicId: img.publicId))
          .toList(),
      category: listing.category,
      priceType: listing.priceType,
      price: listing.price,
      currency: listing.currency,
      condition: listing.condition,
      location: listing.location != null
          ? ListingLocationModel(
              name: listing.location!.name,
              address: listing.location!.address,
              latitude: listing.location!.latitude,
              longitude: listing.location!.longitude,
            )
          : null,
      meetupPreferences: listing.meetupPreferences,
      status: listing.status,
      views: listing.views,
      wishlistCount: listing.wishlistCount,
      inquiries: listing.inquiries,
      isFeatured: listing.isFeatured,
      featuredUntil: listing.featuredUntil,
      featuredPlan: listing.featuredPlan,
      tags: listing.tags,
      seller: listing.seller != null
          ? SellerInfoModel(
              id: listing.seller!.id,
              name: listing.seller!.name,
              avatar: listing.seller!.avatar,
              username: listing.seller!.username,
              isVerified: listing.seller!.isVerified,
              rating: listing.seller!.rating,
            )
          : null,
      sellerId: listing.sellerId,
      createdAt: listing.createdAt,
      updatedAt: listing.updatedAt,
      expiresAt: listing.expiresAt,
      isInWishlist: listing.isInWishlist,
      educationLevel: listing.educationLevel,
      classOrSemester: listing.classOrSemester,
      subject: listing.subject,
      bookType: listing.bookType,
      division: listing.division,
      district: listing.district,
      upazila: listing.upazila,
    );
  }
}
