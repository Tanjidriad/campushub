import 'package:book_user_app/features/report/domain/entities/report.dart';
import 'package:book_user_app/features/report/domain/repositories/report_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ReportEvent extends Equatable {
  const ReportEvent();
  @override
  List<Object?> get props => [];
}

class ReportSubmitted extends ReportEvent {
  final ReportParams params;
  const ReportSubmitted(this.params);
  @override
  List<Object?> get props => [params];
}

class ReportReset extends ReportEvent {
  const ReportReset();
}

// States
abstract class ReportState extends Equatable {
  const ReportState();
  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportLoading extends ReportState {
  const ReportLoading();
}

class ReportSuccess extends ReportState {
  final String message;
  const ReportSuccess({this.message = 'Report submitted successfully'});
  @override
  List<Object?> get props => [message];
}

class ReportFailure extends ReportState {
  final String error;
  const ReportFailure(this.error);
  @override
  List<Object?> get props => [error];
}

// Bloc
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository repository;

  ReportBloc({required this.repository}) : super(const ReportInitial()) {
    on<ReportSubmitted>(_onReportSubmitted);
    on<ReportReset>(_onReportReset);
  }

  Future<void> _onReportSubmitted(
    ReportSubmitted event,
    Emitter<ReportState> emit,
  ) async {
    emit(const ReportLoading());

    final result = await repository.createReport(event.params);

    result.fold(
      (failure) => emit(ReportFailure(failure.message)),
      (_) => emit(const ReportSuccess()),
    );
  }

  void _onReportReset(ReportReset event, Emitter<ReportState> emit) {
    emit(const ReportInitial());
  }
}
