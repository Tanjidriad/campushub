import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../domain/usecases/dashboard_usecases.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStats getDashboardStats;
  final GetActivity getActivity;

  DashboardBloc({required this.getDashboardStats, required this.getActivity})
    : super(DashboardInitial()) {
    on<LoadDashboardEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final statsResult = await getDashboardStats(NoParams());
    final activityResult = await getActivity(NoParams());

    DashboardStats? stats;
    List<ActivityItem>? activity;

    statsResult.fold((failure) {}, (data) {
      stats = data;
    });

    activityResult.fold((failure) {}, (data) {
      activity = data;
    });

    if (stats == null) {
      emit(const DashboardError('Failed to load dashboard'));
      return;
    }

    emit(DashboardLoaded(stats: stats!, activity: activity ?? []));
  }
}
