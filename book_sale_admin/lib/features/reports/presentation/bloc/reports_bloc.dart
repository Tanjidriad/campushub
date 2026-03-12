import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/report_usecases.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetReports getReports;
  final ReviewReport reviewReport;

  static const int _limit = 20;

  ReportsBloc({required this.getReports, required this.reviewReport})
    : super(ReportsInitial()) {
    on<LoadReportsEvent>(_onLoadReports);
    on<LoadMoreReportsEvent>(_onLoadMoreReports);
    on<ReviewReportEvent>(_onReviewReport);
  }

  Future<void> _onLoadReports(
    LoadReportsEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());

    final result = await getReports(
      GetReportsParams(
        status: event.status,
        targetType: event.targetType,
        page: 1,
        limit: _limit,
      ),
    );

    result.fold((failure) => emit(ReportsError(failure.message)), (reports) {
      emit(
        ReportsLoaded(
          reports: reports,
          hasReachedMax: reports.length < _limit,
          currentPage: 1,
          currentStatusFilter: event.status,
          currentTargetTypeFilter: event.targetType,
        ),
      );
    });
  }

  Future<void> _onLoadMoreReports(
    LoadMoreReportsEvent event,
    Emitter<ReportsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ReportsLoaded) return;
    if (currentState.hasReachedMax) return;
    if (currentState.isActionInProgress) return;

    final nextPage = currentState.currentPage + 1;

    final result = await getReports(
      GetReportsParams(
        status: currentState.currentStatusFilter,
        targetType: currentState.currentTargetTypeFilter,
        page: nextPage,
        limit: _limit,
      ),
    );

    result.fold(
      (failure) {
        emit(currentState.copyWith(actionError: failure.message));
      },
      (newReports) {
        if (newReports.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          emit(
            currentState.copyWith(
              reports: List.of(currentState.reports)..addAll(newReports),
              currentPage: nextPage,
              hasReachedMax: newReports.length < _limit,
            ),
          );
        }
      },
    );
  }

  Future<void> _onReviewReport(
    ReviewReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    final currentState = state;
    if (currentState is ReportsLoaded) {
      emit(currentState.copyWith(isActionInProgress: true));
    }

    final result = await reviewReport(
      ReviewReportParams(
        id: event.id,
        status: event.newStatus,
        actionTaken: event.actionTaken,
        resolution: event.resolution,
      ),
    );

    result.fold(
      (failure) {
        if (currentState is ReportsLoaded) {
          emit(
            currentState.copyWith(
              isActionInProgress: false,
              actionError: failure.message,
            ),
          );
        } else {
          emit(ReportsError(failure.message));
        }
      },
      (updatedReport) {
        emit(const ReportActionSuccess('Report reviewed successfully'));
        // Reload reports with the previous filters to reflect changes
        if (currentState is ReportsLoaded) {
          add(
            LoadReportsEvent(
              status: currentState.currentStatusFilter,
              targetType: currentState.currentTargetTypeFilter,
              isRefresh: true,
            ),
          );
        } else {
          add(const LoadReportsEvent());
        }
      },
    );
  }
}
