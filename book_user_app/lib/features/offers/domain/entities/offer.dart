import 'package:equatable/equatable.dart';

class Offer extends Equatable {
  final String id;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final double amount;
  final String status;
  final double? counterAmount;
  final int roundNumber;
  final String? parentOfferId;
  final String? message;
  final DateTime? respondedAt;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated fields
  final OfferUser? buyer;
  final OfferUser? seller;
  final OfferListing? listing;

  const Offer({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.amount,
    required this.status,
    this.counterAmount,
    this.roundNumber = 1,
    this.parentOfferId,
    this.message,
    this.respondedAt,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.buyer,
    this.seller,
    this.listing,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';
  bool get isCountered => status == 'countered';
  bool get isExpired =>
      status == 'expired' || DateTime.now().isAfter(expiresAt);
  bool get canCounter => roundNumber < 3;

  double get priceDifference {
    if (listing == null) return 0;
    return amount - listing!.price;
  }

  double get pricePercentage {
    if (listing == null || listing!.price == 0) return 0;
    return (amount / listing!.price * 100);
  }

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['_id'] ?? '',
      listingId: json['listing'] is Map
          ? json['listing']['_id'] ?? ''
          : json['listing'] ?? '',
      buyerId: json['buyer'] is Map
          ? json['buyer']['_id'] ?? ''
          : json['buyer'] ?? '',
      sellerId: json['seller'] is Map
          ? json['seller']['_id'] ?? ''
          : json['seller'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      counterAmount: json['counterAmount']?.toDouble(),
      roundNumber: json['roundNumber'] ?? 1,
      parentOfferId: json['parentOffer']?.toString(),
      message: json['message'],
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'])
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : DateTime.now().add(const Duration(hours: 48)),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      buyer: json['buyer'] is Map ? OfferUser.fromJson(json['buyer']) : null,
      seller: json['seller'] is Map ? OfferUser.fromJson(json['seller']) : null,
      listing: json['listing'] is Map
          ? OfferListing.fromJson(json['listing'])
          : null,
    );
  }

  @override
  List<Object?> get props => [id, status, amount, counterAmount, roundNumber];
}

class OfferUser extends Equatable {
  final String id;
  final String name;
  final String? avatar;
  final String? phone;

  const OfferUser({
    required this.id,
    required this.name,
    this.avatar,
    this.phone,
  });

  factory OfferUser.fromJson(Map<String, dynamic> json) {
    return OfferUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'],
      phone: json['phone'],
    );
  }

  @override
  List<Object?> get props => [id, name];
}

class OfferListing extends Equatable {
  final String id;
  final String title;
  final double price;
  final String? description;
  final String? condition;
  final String? category;
  final String? priceType;
  final List<OfferImage> images;
  final OfferLocation? location;

  const OfferListing({
    required this.id,
    required this.title,
    required this.price,
    this.description,
    this.condition,
    this.category,
    this.priceType,
    this.images = const [],
    this.location,
  });

  String get firstImageUrl => images.isNotEmpty ? images.first.url : '';

  factory OfferListing.fromJson(Map<String, dynamic> json) {
    return OfferListing(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'],
      condition: json['condition'],
      category: json['category'],
      priceType: json['priceType'],
      images:
          (json['images'] as List<dynamic>?)
              ?.map((img) => OfferImage.fromJson(img))
              .toList() ??
          [],
      location: json['location'] != null
          ? OfferLocation.fromJson(json['location'])
          : null,
    );
  }

  @override
  List<Object?> get props => [id, title, price];
}

class OfferImage {
  final String url;
  final String? publicId;

  const OfferImage({required this.url, this.publicId});

  factory OfferImage.fromJson(Map<String, dynamic> json) {
    return OfferImage(url: json['url'] ?? '', publicId: json['publicId']);
  }
}

class OfferLocation {
  final String? name;
  final String? address;

  const OfferLocation({this.name, this.address});

  factory OfferLocation.fromJson(Map<String, dynamic> json) {
    return OfferLocation(name: json['name'], address: json['address']);
  }
}
