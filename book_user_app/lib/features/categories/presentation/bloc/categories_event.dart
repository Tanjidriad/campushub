import 'package:equatable/equatable.dart';

abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object?> get props => [];
}

/// Request to load categories
class CategoriesLoadRequested extends CategoriesEvent {
  const CategoriesLoadRequested();
}

/// Request to refresh categories
class CategoriesRefreshRequested extends CategoriesEvent {
  const CategoriesRefreshRequested();
}
