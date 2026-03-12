import 'dart:typed_data';

import 'package:book_sale_admin/features/category_config/domain/entities/category.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/education_config.dart';

abstract class CategoryRepository {
  Future<Either<Failure, EducationConfig>> getConfig();
  Future<Either<Failure, void>> saveConfig(EducationConfig config);

  // Listing Categories
  Future<Either<Failure, List<Category>>> getCategories({
    bool includeInactive = true,
  });
  Future<Either<Failure, Category>> createCategory({
    required String name,
    String? description,
    String? icon,
    int? displayOrder,
    Uint8List? imageBytes,
    bool hasEducationConfig = false,
  });
  Future<Either<Failure, Category>> updateCategory({
    required String id,
    String? name,
    String? description,
    String? icon,
    int? displayOrder,
    Uint8List? imageBytes,
    bool hasEducationConfig = false,
  });
  Future<Either<Failure, void>> deleteCategory(String id);
  Future<Either<Failure, void>> toggleCategoryStatus(String id);
}
