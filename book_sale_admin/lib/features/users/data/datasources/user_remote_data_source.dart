import 'package:dio/dio.dart';
import '../../../../core/api_client.dart';
import '../../../../core/constants.dart';
import '../models/user_model.dart';
import '../models/users_response_model.dart';

abstract class UserRemoteDataSource {
  Future<UsersResponseModel> getUsers({
    int? limit,
    String? search,
    String? role,
    String? status,
  });

  Future<AdminUserModel> getUser(String userId);
  Future<void> toggleBan(String userId);
  Future<void> changeRole(String userId, String newRole);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UsersResponseModel> getUsers({
    int? limit,
    String? search,
    String? role,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (limit != null) {
        queryParams['limit'] = limit;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (role != null && role.isNotEmpty) {
        queryParams['role'] = role;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await apiClient.dio.get(
        ApiConstants.users,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        return UsersResponseModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch users');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Network error occurred',
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<AdminUserModel> getUser(String userId) async {
    try {
      final response = await apiClient.dio.get('${ApiConstants.users}/$userId');
      if (response.data['success'] == true) {
        return AdminUserModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch user');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Network error occurred',
      );
    }
  }

  @override
  Future<void> toggleBan(String userId) async {
    try {
      final response = await apiClient.dio.put(
        '${ApiConstants.users}/$userId/ban',
      );

      if (response.data['success'] != true) {
        throw Exception(
          response.data['message'] ?? 'Failed to toggle ban status',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Network error occurred',
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> changeRole(String userId, String newRole) async {
    try {
      final response = await apiClient.dio.put(
        '${ApiConstants.users}/$userId/role',
        data: {'role': newRole},
      );
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to change role');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Network error occurred',
      );
    }
  }
}
