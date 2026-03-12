import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategories implements UseCase<List<Category>, bool> {
  final CategoryRepository repository;
  GetCategories(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(bool includeInactive) async {
    return await repository.getCategories(includeInactive: includeInactive);
  }
}

class CreateListingCategory implements UseCase<Category, CreateCategoryParams> {
  final CategoryRepository repository;
  CreateListingCategory(this.repository);

  @override
  Future<Either<Failure, Category>> call(CreateCategoryParams params) async {
    return await repository.createCategory(
      name: params.name,
      description: params.description,
      icon: params.icon,
      displayOrder: params.displayOrder,
      imageBytes: params.imageBytes,
      hasEducationConfig: params.hasEducationConfig,
    );
  }
}

class UpdateListingCategory implements UseCase<Category, UpdateCategoryParams> {
  final CategoryRepository repository;
  UpdateListingCategory(this.repository);

  @override
  Future<Either<Failure, Category>> call(UpdateCategoryParams params) async {
    return await repository.updateCategory(
      id: params.id,
      name: params.name,
      description: params.description,
      icon: params.icon,
      displayOrder: params.displayOrder,
      imageBytes: params.imageBytes,
      hasEducationConfig: params.hasEducationConfig,
    );
  }
}

class DeleteListingCategory implements UseCase<void, String> {
  final CategoryRepository repository;
  DeleteListingCategory(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteCategory(id);
  }
}

class ToggleListingCategoryStatus implements UseCase<void, String> {
  final CategoryRepository repository;
  ToggleListingCategoryStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    return await repository.toggleCategoryStatus(id);
  }
}

class CreateCategoryParams {
  final String name;
  final String? description;
  final String? icon;
  final int? displayOrder;
  final Uint8List? imageBytes;
  final bool hasEducationConfig;

  CreateCategoryParams({
    required this.name,
    this.description,
    this.icon,
    this.displayOrder,
    this.imageBytes,
    this.hasEducationConfig = false,
  });
}

class UpdateCategoryParams {
  final String id;
  final String? name;
  final String? description;
  final String? icon;
  final int? displayOrder;
  final Uint8List? imageBytes;
  final bool hasEducationConfig;

  UpdateCategoryParams({
    required this.id,
    this.name,
    this.description,
    this.icon,
    this.displayOrder,
    this.imageBytes,
    this.hasEducationConfig = false,
  });
}
