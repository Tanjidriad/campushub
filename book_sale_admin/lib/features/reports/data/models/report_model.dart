import '../../domain/entities/report.dart';

class ReportModel extends Report {
  const ReportModel({
    required super.id,
    required super.targetType,
    required super.targetId,
    required super.reason,
    super.description,
    required super.status,
    required super.createdAt,
    required super.reporterId,
    required super.reporterName,
    super.reporterAvatar,
    super.target,
    super.reviewedBy,
    super.reviewedAt,
    super.resolution,
    super.actionTaken,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    // Parse the reporter safely (handle both populated Map and unpopulated String ID)
    Map<String, dynamic>? reporter;
    if (json['reporter'] is Map) {
      reporter = Map<String, dynamic>.from(json['reporter']);
    } else if (json['reporter'] is String) {
      reporter = {'_id': json['reporter']};
    }
    final reporterId = reporter?['_id'] ?? '';
    final reporterName = reporter?['name'] ?? 'Unknown Reporter';
    final reporterAvatar = reporter?['avatar'];

    // Parse review info safely
    Map<String, dynamic>? reviewedByMap;
    if (json['reviewedBy'] is Map) {
      reviewedByMap = Map<String, dynamic>.from(json['reviewedBy']);
    } else if (json['reviewedBy'] is String) {
      reviewedByMap = {'_id': json['reviewedBy']};
    }
    final reviewedByName = reviewedByMap != null ? reviewedByMap['name'] : null;

    // Parse target polymorphically and safely
    ReportTarget? parsedTarget;
    final tType = json['targetType'];
    Map<String, dynamic>? tData;
    if (json['target'] is Map) {
      tData = Map<String, dynamic>.from(json['target']);
    } else if (json['target'] is String) {
      tData = {'_id': json['target']};
    }

    if (tData != null) {
      if (tType == 'user') {
        parsedTarget = UserReportTarget(
          id: tData['_id'] ?? '',
          name: tData['name'] ?? '',
          email: tData['email'] ?? '',
          avatar: tData['avatar'],
        );
      } else if (tType == 'listing') {
        // Find the first image if any
        String? imageUrl;
        if (tData['images'] != null && (tData['images'] as List).isNotEmpty) {
          imageUrl = tData['images'][0]['url'];
        }
        parsedTarget = ListingReportTarget(
          id: tData['_id'] ?? '',
          title: tData['title'] ?? '',
          imageUrl: imageUrl,
        );
      }
    }

    return ReportModel(
      id: json['_id'] ?? '',
      targetType: tType ?? '',
      targetId: json['targetId'] ?? '',
      reason: json['reason'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      reporterId: reporterId,
      reporterName: reporterName,
      reporterAvatar: reporterAvatar,
      target: parsedTarget,
      reviewedBy: reviewedByName,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      resolution: json['resolution'],
      actionTaken: json['actionTaken'],
    );
  }
}
