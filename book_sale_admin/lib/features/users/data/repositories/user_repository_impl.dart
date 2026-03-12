import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/users_response.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UsersResponse>> getUsers({
    int? limit,
    String? search,
    String? role,
    String? status,
  }) async {
    try {
      final result = await remoteDataSource.getUsers(
        limit: limit,
        search: search,
        role: role,
        status: status,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> getUser(String userId) async {
    try {
      final result = await remoteDataSource.getUser(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleBan(String userId) async {
    try {
      await remoteDataSource.toggleBan(userId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> changeRole(
    String userId,
    String newRole,
  ) async {
    try {
      await remoteDataSource.changeRole(userId, newRole);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
