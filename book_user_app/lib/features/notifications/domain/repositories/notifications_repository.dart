import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/core/network/paginated_response.dart';
import 'package:dartz/dartz.dart';
import '../entities/notification.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, PaginatedResponse<Notification>>> getNotifications({
    int page = 1,
    int limit = 20,
  });
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, void>> markAsRead(String id);
  Future<Either<Failure, void>> markAllAsRead();
  Future<Either<Failure, void>> deleteNotification(String id);
}
