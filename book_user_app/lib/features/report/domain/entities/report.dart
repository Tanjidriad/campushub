import 'package:equatable/equatable.dart';

enum ReportTargetType { user, listing, message }

enum ReportReason {
  spam,
  inappropriate,
  fraud,
  harassment,
  prohibitedItem,
  wrongCategory,
  duplicate,
  other,
}

extension ReportTargetTypeX on ReportTargetType {
  String get value {
    switch (this) {
      case ReportTargetType.user:
        return 'user';
      case ReportTargetType.listing:
        return 'listing';
      case ReportTargetType.message:
        return 'message';
    }
  }
}

extension ReportReasonX on ReportReason {
  String get value {
    switch (this) {
      case ReportReason.spam:
        return 'spam';
      case ReportReason.inappropriate:
        return 'inappropriate';
      case ReportReason.fraud:
        return 'fraud';
      case ReportReason.harassment:
        return 'harassment';
      case ReportReason.prohibitedItem:
        return 'prohibited_item';
      case ReportReason.wrongCategory:
        return 'wrong_category';
      case ReportReason.duplicate:
        return 'duplicate';
      case ReportReason.other:
        return 'other';
    }
  }

  String get label {
    switch (this) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.inappropriate:
        return 'Inappropriate Content';
      case ReportReason.fraud:
        return 'Fraud / Scam';
      case ReportReason.harassment:
        return 'Harassment';
      case ReportReason.prohibitedItem:
        return 'Prohibited Item';
      case ReportReason.wrongCategory:
        return 'Wrong Category';
      case ReportReason.duplicate:
        return 'Duplicate Listing';
      case ReportReason.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case ReportReason.spam:
        return '🚫';
      case ReportReason.inappropriate:
        return '⚠️';
      case ReportReason.fraud:
        return '🕵️';
      case ReportReason.harassment:
        return '😡';
      case ReportReason.prohibitedItem:
        return '🚷';
      case ReportReason.wrongCategory:
        return '📂';
      case ReportReason.duplicate:
        return '📋';
      case ReportReason.other:
        return '💬';
    }
  }
}

class Report extends Equatable {
  final String id;
  final ReportTargetType targetType;
  final String targetId;
  final ReportReason reason;
  final String? description;
  final String status;
  final DateTime createdAt;

  const Report({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
    this.status = 'pending',
    required this.createdAt,
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
  ];
}

class ReportParams {
  final ReportTargetType targetType;
  final String targetId;
  final ReportReason reason;
  final String? description;

  const ReportParams({
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'targetType': targetType.value,
    'targetId': targetId,
    'reason': reason.value,
    if (description != null && description!.isNotEmpty)
      'description': description,
  };
}
