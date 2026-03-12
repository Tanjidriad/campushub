import '../../domain/entities/listing.dart';

class ListingModel extends Listing {
  const ListingModel({
    required super.id,
    super.title,
    super.description,
    super.price,
    super.category,
    super.status,
    super.isFeatured,
    super.reportCount,
    super.createdAt,
    super.seller,
    super.images,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['_id'] ?? '',
      title: json['title'],
      description: json['description'],
      price: json['price'],
      category: json['category'],
      status: json['status'],
      isFeatured: json['isFeatured'],
      reportCount: json['reportCount'],
      createdAt: json['createdAt'],
      seller: json['seller'] != null
          ? ListingSellerModel.fromJson(json['seller'])
          : null,
      images: json['images'] != null
          ? (json['images'] as List)
                .map((i) => ListingImageModel.fromJson(i))
                .toList()
          : null,
    );
  }
}

class ListingSellerModel extends ListingSeller {
  const ListingSellerModel({
    super.id,
    super.name,
    super.email,
    super.role,
    super.avatar,
  });

  factory ListingSellerModel.fromJson(Map<String, dynamic> json) {
    return ListingSellerModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      avatar: json['avatar'],
    );
  }
}

class ListingImageModel extends ListingImage {
  const ListingImageModel({super.url, super.publicId});

  factory ListingImageModel.fromJson(Map<String, dynamic> json) {
    return ListingImageModel(url: json['url'], publicId: json['public_id']);
  }
}
