import '../../domain/entities/dashboard_entities.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    super.users,
    super.listings,
    super.reports,
    super.charts,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      users: json['users'] as Map<String, dynamic>?,
      listings: json['listings'] as Map<String, dynamic>?,
      reports: json['reports'] as Map<String, dynamic>?,
      charts: json['charts'] as Map<String, dynamic>?,
    );
  }
}

class ActivityItemModel extends ActivityItem {
  const ActivityItemModel({
    super.title,
    super.subtitle,
    super.icon,
    super.color,
    super.timestamp,
    super.type,
  });

  factory ActivityItemModel.fromJson(Map<String, dynamic> json) {
    return ActivityItemModel(
      title: json['title'],
      subtitle: json['subtitle'],
      icon: json['icon'],
      color: json['color'],
      timestamp: json['timestamp'],
      type: json['type'],
    );
  }
}

class AuditLogModel {
  final String? id;
  final String? action;
  final String? targetType;
  final String? targetId;
  final Map<String, dynamic>? performedBy;
  final Map<String, dynamic>? details;
  final String? ip;
  final String? createdAt;

  const AuditLogModel({
    this.id,
    this.action,
    this.targetType,
    this.targetId,
    this.performedBy,
    this.details,
    this.ip,
    this.createdAt,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['_id'],
      action: json['action'],
      targetType: json['targetType'],
      targetId: json['targetId'],
      performedBy: json['performedBy'] is Map ? json['performedBy'] : null,
      details: json['details'] is Map
          ? Map<String, dynamic>.from(json['details'])
          : null,
      ip: json['ip'],
      createdAt: json['createdAt'],
    );
  }

  String get adminName => performedBy?['name'] ?? 'Unknown';
  String get adminEmail => performedBy?['email'] ?? '';
  String get actionLabel => (action ?? '').replaceAll('_', ' ').toUpperCase();
}
