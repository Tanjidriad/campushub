import 'package:dartz/dartz.dart';
import 'package:book_user_app/core/errors/failures.dart';
import '../../domain/entities/category.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, Category>> getCategoryById(String id);
}
