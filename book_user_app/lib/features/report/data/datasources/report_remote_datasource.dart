import 'package:book_user_app/core/network/api_client.dart';
import 'package:book_user_app/features/report/domain/entities/report.dart';

abstract class ReportRemoteDataSource {
  Future<Report> createReport(ReportParams params);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final ApiClient apiClient;

  ReportRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Report> createReport(ReportParams params) async {
    final response = await apiClient.post('/reports', data: params.toJson());

    final data = response.data;

    if (data['success'] == true) {
      final reportData = data['data'];
      return Report(
        id: reportData['_id'] ?? '',
        targetType: params.targetType,
        targetId: params.targetId,
        reason: params.reason,
        description: params.description,
        status: reportData['status'] ?? 'pending',
        createdAt:
            DateTime.tryParse(reportData['createdAt'] ?? '') ?? DateTime.now(),
      );
    }

    throw Exception(data['message'] ?? 'Failed to submit report');
  }
}
