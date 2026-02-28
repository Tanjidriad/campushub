import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/core/network/api_exceptions.dart';
import 'package:book_user_app/features/auth/domain/entities/user.dart';
import 'package:book_user_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:book_user_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> getUserProfile(String id) async {
    try {
      final userModel = await remoteDataSource.getUserProfile(id);
      return Right(userModel);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
