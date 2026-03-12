import 'package:dio/dio.dart';
import '../../../../core/api_client.dart';
import '../../../../core/constants.dart';
import '../models/dashboard_models.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats();
  Future<List<ActivityItemModel>> getActivity();
  Future<List<AuditLogModel>> getAuditLogs({
    int page = 1,
    int limit = 50,
    String? action,
  });
  Future<List<int>> exportUsers();
  Future<List<int>> exportListings();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;
  DashboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    final response = await apiClient.dio.get(ApiConstants.dashboard);
    return DashboardStatsModel.fromJson(response.data['data'] ?? {});
  }

  @override
  Future<List<ActivityItemModel>> getActivity() async {
    final response = await apiClient.dio.get(ApiConstants.activity);
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => ActivityItemModel.fromJson(e)).toList();
  }

  @override
  Future<List<AuditLogModel>> getAuditLogs({
    int page = 1,
    int limit = 50,
    String? action,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (action != null && action.isNotEmpty) params['action'] = action;

    final response = await apiClient.dio.get(
      ApiConstants.auditLogs,
      queryParameters: params,
    );
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => AuditLogModel.fromJson(e)).toList();
  }

  @override
  Future<List<int>> exportUsers() async {
    final response = await apiClient.dio.get<List<int>>(
      ApiConstants.exportUsers,
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? [];
  }

  @override
  Future<List<int>> exportListings() async {
    final response = await apiClient.dio.get<List<int>>(
      ApiConstants.exportListings,
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? [];
  }
}
