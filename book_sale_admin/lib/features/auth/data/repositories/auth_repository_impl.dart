import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AdminUser>> login(
    String email,
    String password,
  ) async {
    try {
      final user = await remoteDataSource.login(email, password);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkAuth() async {
    try {
      final has = await remoteDataSource.hasToken();
      return Right(has);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminUser?>> getSavedUser() async {
    try {
      final user = await remoteDataSource.getSavedUser();
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
