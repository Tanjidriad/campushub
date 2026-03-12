import 'package:dio/dio.dart';
import '../../../../core/api_client.dart';
import '../../../../core/constants.dart';
import '../models/report_model.dart';

abstract class ReportRemoteDataSource {
  Future<List<ReportModel>> getReports({
    String? status,
    String? targetType,
    int page = 1,
    int limit = 50,
  });

  Future<ReportModel> getReportDetail(String id);

  Future<ReportModel> reviewReport({
    required String id,
    required String status,
    required String actionTaken,
    String? resolution,
  });
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final ApiClient apiClient;

  ReportRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ReportModel>> getReports({
    String? status,
    String? targetType,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (targetType != null && targetType.isNotEmpty) {
        queryParams['targetType'] = targetType;
      }

      final response = await apiClient.dio.get(
        ApiConstants.reports,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ReportModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch reports');
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
  Future<ReportModel> getReportDetail(String id) async {
    try {
      final response = await apiClient.dio.get('${ApiConstants.reports}/$id');
      if (response.data['success'] == true) {
        return ReportModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch report');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Network error occurred',
      );
    }
  }

  @override
  Future<ReportModel> reviewReport({
    required String id,
    required String status,
    required String actionTaken,
    String? resolution,
  }) async {
    try {
      final data = <String, dynamic>{
        'status': status,
        'actionTaken': actionTaken,
      };

      if (resolution != null && resolution.isNotEmpty) {
        data['resolution'] = resolution;
      }

      final response = await apiClient.dio.put(
        '${ApiConstants.reports}/$id',
        data: data,
      );

      if (response.data['success'] == true) {
        final reportData = response.data['data'];
        return ReportModel.fromJson(reportData);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to review report');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Network error occurred',
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
