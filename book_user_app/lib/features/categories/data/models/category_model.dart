import '../../domain/entities/category.dart';

/// Category model for data layer with JSON serialization
class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    super.icon,
    super.image,
    super.isActive,
    super.displayOrder,
    super.listingCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      icon: json['icon'] as String? ?? 'category',
      image: json['image'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      displayOrder: json['displayOrder'] as int? ?? 0,
      listingCount: json['listingCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon': icon,
      'image': image,
      'isActive': isActive,
      'displayOrder': displayOrder,
      'listingCount': listingCount,
    };
  }

  Category toEntity() => Category(
    id: id,
    name: name,
    slug: slug,
    description: description,
    icon: icon,
    image: image,
    isActive: isActive,
    displayOrder: displayOrder,
    listingCount: listingCount,
  );

  static List<CategoryModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
  }
}
