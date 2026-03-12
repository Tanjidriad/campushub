import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadReportsEvent extends ReportsEvent {
  final String? status;
  final String? targetType;
  final bool isRefresh;

  const LoadReportsEvent({
    this.status,
    this.targetType,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [status, targetType, isRefresh];
}

class LoadMoreReportsEvent extends ReportsEvent {
  const LoadMoreReportsEvent();
}

class ReviewReportEvent extends ReportsEvent {
  final String id;
  final String newStatus;
  final String actionTaken;
  final String? resolution;

  const ReviewReportEvent({
    required this.id,
    required this.newStatus,
    required this.actionTaken,
    this.resolution,
  });

  @override
  List<Object?> get props => [id, newStatus, actionTaken, resolution];
}
