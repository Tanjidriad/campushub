import 'package:equatable/equatable.dart';
import '../../domain/entities/report.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<Report> reports;
  final bool hasReachedMax;
  final int currentPage;
  final String? currentStatusFilter;
  final String? currentTargetTypeFilter;
  final bool isActionInProgress;
  final String? actionError;

  const ReportsLoaded({
    required this.reports,
    required this.hasReachedMax,
    required this.currentPage,
    this.currentStatusFilter,
    this.currentTargetTypeFilter,
    this.isActionInProgress = false,
    this.actionError,
  });

  ReportsLoaded copyWith({
    List<Report>? reports,
    bool? hasReachedMax,
    int? currentPage,
    String? currentStatusFilter,
    String? currentTargetTypeFilter,
    bool? isActionInProgress,
    String? actionError,
  }) {
    return ReportsLoaded(
      reports: reports ?? this.reports,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      currentStatusFilter: currentStatusFilter ?? this.currentStatusFilter,
      currentTargetTypeFilter:
          currentTargetTypeFilter ?? this.currentTargetTypeFilter,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      actionError:
          actionError, // null by default when copying unless explicitly set
    );
  }

  @override
  List<Object?> get props => [
    reports,
    hasReachedMax,
    currentPage,
    currentStatusFilter,
    currentTargetTypeFilter,
    isActionInProgress,
    actionError,
  ];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReportActionSuccess extends ReportsState {
  final String message;

  const ReportActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
