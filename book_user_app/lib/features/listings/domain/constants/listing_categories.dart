/// Available listing categories
/// These should match the backend's expected category values
class ListingCategories {
  static const String all = '';
  static const String textbooks = 'Textbooks';
  static const String electronics = 'Electronics';
  static const String furniture = 'Furniture';
  static const String clothing = 'Clothing';
  static const String sports = 'Sports';
  static const String music = 'Music';
  static const String art = 'Art';
  static const String other = 'Other';

  /// All categories with their display info
  static const List<CategoryItem> items = [
    CategoryItem(value: all, label: 'All Items', icon: null),
    CategoryItem(value: textbooks, label: 'Textbooks', icon: 'menu_book'),
    CategoryItem(value: electronics, label: 'Electronics', icon: 'laptop'),
    CategoryItem(value: furniture, label: 'Furniture', icon: 'chair'),
    CategoryItem(value: clothing, label: 'Clothing', icon: 'checkroom'),
    CategoryItem(value: sports, label: 'Sports', icon: 'sports'),
    CategoryItem(value: music, label: 'Music', icon: 'music_note'),
    CategoryItem(value: art, label: 'Art', icon: 'palette'),
    CategoryItem(value: other, label: 'Other', icon: 'category'),
  ];

  /// Get category label from value
  static String getLabel(String value) {
    return items
        .firstWhere(
          (item) => item.value == value,
          orElse: () => CategoryItem(value: value, label: value),
        )
        .label;
  }
}

class CategoryItem {
  final String value;
  final String label;
  final String? icon;

  const CategoryItem({required this.value, required this.label, this.icon});
}
