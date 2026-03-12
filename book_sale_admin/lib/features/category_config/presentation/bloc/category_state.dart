import 'package:equatable/equatable.dart';
import 'package:book_sale_admin/features/category_config/domain/entities/category.dart';
import '../../domain/entities/education_config.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final EducationConfig config;
  final List<Category> categories;
  final bool isCategoriesLoading;
  final String? categoryError;

  const CategoryLoaded({
    required this.config,
    this.categories = const [],
    this.isCategoriesLoading = false,
    this.categoryError,
  });

  CategoryLoaded copyWith({
    EducationConfig? config,
    List<Category>? categories,
    bool? isCategoriesLoading,
    String? categoryError,
  }) {
    return CategoryLoaded(
      config: config ?? this.config,
      categories: categories ?? this.categories,
      isCategoriesLoading: isCategoriesLoading ?? this.isCategoriesLoading,
      categoryError: categoryError,
    );
  }

  @override
  List<Object?> get props => [
    config,
    categories,
    isCategoriesLoading,
    categoryError,
  ];
}

class CategorySaving extends CategoryState {}

class CategorySaved extends CategoryState {}

class CategoryActionSuccess extends CategoryState {
  final String message;
  const CategoryActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);
  @override
  List<Object?> get props => [message];
}
