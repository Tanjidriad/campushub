import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/education_config.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';
import '../models/education_config_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;
  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, EducationConfig>> getConfig() async {
    try {
      final config = await remoteDataSource.getConfig();
      return Right(config);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveConfig(EducationConfig config) async {
    try {
      // Convert domain entity to model for serialization
      final model = EducationConfigModel(
        levels: config.levels,
        bookTypes: config.bookTypes,
      );
      await remoteDataSource.saveConfig(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories({
    bool includeInactive = true,
  }) async {
    try {
      final categories = await remoteDataSource.getCategories(
        includeInactive: includeInactive,
      );
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> createCategory({
    required String name,
    String? description,
    String? icon,
    int? displayOrder,
    Uint8List? imageBytes,
    bool hasEducationConfig = false,
  }) async {
    try {
      final category = await remoteDataSource.createCategory(
        name: name,
        description: description,
        icon: icon,
        displayOrder: displayOrder,
        imageBytes: imageBytes,
        hasEducationConfig: hasEducationConfig,
      );
      return Right(category);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> updateCategory({
    required String id,
    String? name,
    String? description,
    String? icon,
    int? displayOrder,
    Uint8List? imageBytes,
    bool hasEducationConfig = false,
  }) async {
    try {
      final category = await remoteDataSource.updateCategory(
        id: id,
        name: name,
        description: description,
        icon: icon,
        displayOrder: displayOrder,
        imageBytes: imageBytes,
        hasEducationConfig: hasEducationConfig,
      );
      return Right(category);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await remoteDataSource.deleteCategory(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleCategoryStatus(String id) async {
    try {
      await remoteDataSource.toggleCategoryStatus(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
