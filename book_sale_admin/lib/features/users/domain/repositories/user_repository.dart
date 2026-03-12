import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../entities/users_response.dart';

abstract class UserRepository {
  Future<Either<Failure, UsersResponse>> getUsers({
    int? limit,
    String? search,
    String? role,
    String? status,
  });

  Future<Either<Failure, AdminUserEntity>> getUser(String userId);
  Future<Either<Failure, Unit>> toggleBan(String userId);
  Future<Either<Failure, Unit>> changeRole(String userId, String newRole);
}
