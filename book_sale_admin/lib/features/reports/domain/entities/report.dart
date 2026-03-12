import 'package:equatable/equatable.dart';

class Report extends Equatable {
  final String id;
  final String targetType; // 'user', 'listing', 'message'
  final String targetId;
  final String reason;
  final String? description;
  final String status; // 'pending', 'reviewed', 'resolved', 'dismissed'
  final DateTime createdAt;

  // Reporter info
  final String reporterId;
  final String reporterName;
  final String? reporterAvatar;

  // Target info (Polymorphic)
  final ReportTarget? target;

  // Review info
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? resolution;
  final String?
  actionTaken; // 'none', 'warning', 'content_removed', 'user_banned'

  const Report({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
    required this.status,
    required this.createdAt,
    required this.reporterId,
    required this.reporterName,
    this.reporterAvatar,
    this.target,
    this.reviewedBy,
    this.reviewedAt,
    this.resolution,
    this.actionTaken,
  });

  @override
  List<Object?> get props => [
    id,
    targetType,
    targetId,
    reason,
    description,
    status,
    createdAt,
    reporterId,
    reporterName,
    reporterAvatar,
    target,
    reviewedBy,
    reviewedAt,
    resolution,
    actionTaken,
  ];
}

abstract class ReportTarget extends Equatable {
  const ReportTarget();
}

class UserReportTarget extends ReportTarget {
  final String id;
  final String name;
  final String email;
  final String? avatar;

  const UserReportTarget({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
  });

  @override
  List<Object?> get props => [id, name, email, avatar];
}

class ListingReportTarget extends ReportTarget {
  final String id;
  final String title;
  final String? imageUrl;

  const ListingReportTarget({
    required this.id,
    required this.title,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, title, imageUrl];
}
