import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ApiClient apiClient;

  AuthRepositoryImpl({required this.remoteDataSource, required this.apiClient});

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await remoteDataSource.register(
        email: email,
        password: password,
        name: name,
      );
      return Right(user);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(user);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? username,
    String? phone,
    String? bio,
    String? location,
    String? educationLevel,
    String? stream,
    String? department,
    String? classOrSemester,
  }) async {
    try {
      final user = await remoteDataSource.updateProfile(
        name: name,
        username: username,
        phone: phone,
        bio: bio,
        location: location,
        educationLevel: educationLevel,
        stream: stream,
        department: department,
        classOrSemester: classOrSemester,
      );
      return Right(user);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> resendVerification() async {
    try {
      await remoteDataSource.resendVerification();
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final isLoggedIn = await apiClient.secureStorage.read(
        key: StorageKeys.isLoggedIn,
      );
      return isLoggedIn == 'true';
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await apiClient.secureStorage.read(key: StorageKeys.accessToken);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await apiClient.secureStorage.read(key: StorageKeys.refreshToken);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }

  // Helper method to handle API exceptions (from api_client)
  Failure _handleApiException(ApiException exception) {
    final statusCode = exception.statusCode;
    final message = exception.message;

    if (statusCode == 401) {
      return AuthFailure(
        message.isNotEmpty ? message : 'Invalid email or password',
      );
    } else if (statusCode == 403) {
      return UnauthorizedFailure(
        message.isNotEmpty ? message : 'Access denied',
      );
    } else if (statusCode == 400) {
      return ValidationFailure(message.isNotEmpty ? message : 'Invalid input');
    } else if (statusCode == 404) {
      return const ServerFailure('User not found');
    }

    return ServerFailure(message.isNotEmpty ? message : 'Something went wrong');
  }

  // Helper method to handle Dio exceptions
  Failure _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout');
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        final rawMessage = exception.response?.data['message'];
        final message = parseErrorMessage(rawMessage);
        if (statusCode == 401) {
          return AuthFailure(
            message.isNotEmpty ? message : 'Invalid email or password',
          );
        } else if (statusCode == 403) {
          return UnauthorizedFailure(
            message.isNotEmpty ? message : 'Access denied',
          );
        } else if (statusCode == 400) {
          return ValidationFailure(
            message.isNotEmpty ? message : 'Invalid input',
          );
        }
        return ServerFailure(
          message.isNotEmpty ? message : 'Something went wrong',
        );
      case DioExceptionType.cancel:
        return const ServerFailure('Request cancelled');
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection');
      case DioExceptionType.unknown:
        return const NetworkFailure('Network error occurred');
      default:
        return const ServerFailure('Something went wrong. Please try again.');
    }
  }

  @override
  Future<Either<Failure, User>> updateAvatar(File imageFile) async {
    try {
      final user = await remoteDataSource.updateAvatar(imageFile);
      return Right(user);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(
        const ServerFailure('Failed to update avatar. Please try again.'),
      );
    }
  }
}
