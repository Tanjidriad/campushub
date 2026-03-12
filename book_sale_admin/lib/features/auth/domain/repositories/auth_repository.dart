import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/admin_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AdminUser>> login(String email, String password);
  Future<Either<Failure, bool>> checkAuth();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AdminUser?>> getSavedUser();
}
