import 'package:equatable/equatable.dart';

/// Category entity representing a listing category
class Category extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String icon;
  final String? image;
  final bool isActive;
  final int displayOrder;
  final int listingCount;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon = 'category',
    this.image,
    this.isActive = true,
    this.displayOrder = 0,
    this.listingCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    description,
    icon,
    image,
    isActive,
    displayOrder,
    listingCount,
  ];
}
