import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import '../../domain/entities/education_config.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadConfigEvent extends CategoryEvent {}

class SaveConfigEvent extends CategoryEvent {
  final EducationConfig config;
  const SaveConfigEvent(this.config);
  @override
  List<Object?> get props => [config];
}

// Listing Categories
class LoadCategoriesEvent extends CategoryEvent {
  final bool includeInactive;
  const LoadCategoriesEvent({this.includeInactive = true});
  @override
  List<Object?> get props => [includeInactive];
}

class CreateCategoryEvent extends CategoryEvent {
  final String name;
  final String? description;
  final String? icon;
  final int? displayOrder;
  final Uint8List? imageBytes;
  final bool hasEducationConfig;

  const CreateCategoryEvent({
    required this.name,
    this.description,
    this.icon,
    this.displayOrder,
    this.imageBytes,
    this.hasEducationConfig = false,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    icon,
    displayOrder,
    imageBytes,
    hasEducationConfig,
  ];
}

class UpdateCategoryEvent extends CategoryEvent {
  final String id;
  final String? name;
  final String? description;
  final String? icon;
  final int? displayOrder;
  final Uint8List? imageBytes;
  final bool hasEducationConfig;

  const UpdateCategoryEvent({
    required this.id,
    this.name,
    this.description,
    this.icon,
    this.displayOrder,
    this.imageBytes,
    this.hasEducationConfig = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    icon,
    displayOrder,
    imageBytes,
    hasEducationConfig,
  ];
}

class DeleteCategoryEvent extends CategoryEvent {
  final String id;
  const DeleteCategoryEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class ToggleCategoryStatusEvent extends CategoryEvent {
  final String id;
  const ToggleCategoryStatusEvent(this.id);
  @override
  List<Object?> get props => [id];
}
