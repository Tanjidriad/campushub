import 'package:equatable/equatable.dart';

class ListingSeller extends Equatable {
  final String? id;
  final String? name;
  final String? email;
  final String? role;
  final String? avatar;

  const ListingSeller({this.id, this.name, this.email, this.role, this.avatar});

  @override
  List<Object?> get props => [id, name, email, role, avatar];
}

class ListingImage extends Equatable {
  final String? url;
  final String? publicId;

  const ListingImage({this.url, this.publicId});

  @override
  List<Object?> get props => [url, publicId];
}

class Listing extends Equatable {
  final String id;
  final String? title;
  final String? description;
  final dynamic price; // Use dynamic or num to handle int/double
  final String? category;
  final String? status;
  final bool? isFeatured;
  final int? reportCount;
  final String? createdAt;
  final ListingSeller? seller;
  final List<ListingImage>? images;

  const Listing({
    required this.id,
    this.title,
    this.description,
    this.price,
    this.category,
    this.status,
    this.isFeatured,
    this.reportCount,
    this.createdAt,
    this.seller,
    this.images,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    price,
    category,
    status,
    isFeatured,
    reportCount,
    createdAt,
    seller,
    images,
  ];
}
