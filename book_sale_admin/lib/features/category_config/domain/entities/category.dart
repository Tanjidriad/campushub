import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String? icon;
  final int displayOrder;
  final bool isActive;
  final String? slug;
  final int listingCount;
  final bool hasEducationConfig;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.icon,
    this.displayOrder = 0,
    this.isActive = true,
    this.slug,
    this.listingCount = 0,
    this.hasEducationConfig = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    image,
    icon,
    displayOrder,
    isActive,
    slug,
    listingCount,
    hasEducationConfig,
  ];
}
