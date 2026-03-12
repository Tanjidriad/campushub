import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    super.description,
    super.image,
    super.icon,
    super.displayOrder,
    super.slug,
    super.listingCount,
    super.hasEducationConfig,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      icon: json['icon'],
      displayOrder: json['displayOrder'] ?? 0,
      slug: json['slug'],
      listingCount: json['listingCount'] ?? 0,
      hasEducationConfig: json['hasEducationConfig'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'displayOrder': displayOrder,
      'isActive': isActive,
      'hasEducationConfig': hasEducationConfig,
    };
  }
}
