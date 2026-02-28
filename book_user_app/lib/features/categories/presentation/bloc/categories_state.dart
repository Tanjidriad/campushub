import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

/// Loading categories
class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

/// Categories loaded successfully
class CategoriesLoaded extends CategoriesState {
  final List<Category> categories;

  const CategoriesLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

/// Error loading categories
class CategoriesError extends CategoriesState {
  final String message;

  const CategoriesError({required this.message});

  @override
  List<Object?> get props => [message];
}
