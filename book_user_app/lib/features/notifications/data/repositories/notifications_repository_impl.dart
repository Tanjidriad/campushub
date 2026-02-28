import 'package:book_user_app/core/network/paginated_response.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../data/datasources/notifications_remote_datasource.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedResponse<Notification>>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final remoteNotifications = await remoteDataSource.getNotifications(
        page: page,
        limit: limit,
      );
      return Right(remoteNotifications);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await remoteDataSource.getUnreadCount();
      return Right(count);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String id) async {
    try {
      await remoteDataSource.markAsRead(id);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String id) async {
    try {
      await remoteDataSource.deleteNotification(id);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_handleApiException(e));
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _handleApiException(ApiException exception) {
    return ServerFailure(exception.message);
  }

  Failure _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout');
      case DioExceptionType.badResponse:
        final message =
            exception.response?.data['message'] ?? 'Something went wrong';
        return ServerFailure(message);
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection');
      default:
        return const ServerFailure('Something went wrong. Please try again.');
    }
  }
}
