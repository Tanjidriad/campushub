import 'package:dio/dio.dart';
import 'package:book_user_app/core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/notification_model.dart';
import 'package:book_user_app/core/network/paginated_response.dart';

abstract class NotificationsRemoteDataSource {
  Future<PaginatedResponse<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  });
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final ApiClient apiClient;

  NotificationsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PaginatedResponse<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await apiClient.get(
        '/notifications',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>;
        final items = data
            .map(
              (json) =>
                  NotificationModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        final pagination = response.data['pagination'];
        return PaginatedResponse(
          items: items,
          totalItems: pagination['total'] ?? 0,
          currentPage: pagination['page'] ?? page,
          totalPages: pagination['totalPages'] ?? 1,
        );
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to load notifications',
          statusCode: response.statusCode,
          data: response.data,
        );
      }
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await apiClient.get('/notifications/unread-count');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['count'] ?? 0;
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to get unread count',
          statusCode: response.statusCode,
          data: response.data,
        );
      }
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      final response = await apiClient.put(
        '/notifications/read',
        data: {
          'ids': [id],
        },
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to mark as read',
          statusCode: response.statusCode,
          data: response.data,
        );
      }
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final response = await apiClient.put('/notifications/read');

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to mark all as read',
          statusCode: response.statusCode,
          data: response.data,
        );
      }
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      final response = await apiClient.delete('/notifications/$id');

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to delete notification',
          statusCode: response.statusCode,
          data: response.data,
        );
      }
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }
}
