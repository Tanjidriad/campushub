import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_entities.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardStats implements UseCase<DashboardStats, NoParams> {
  final DashboardRepository repository;
  GetDashboardStats(this.repository);

  @override
  Future<Either<Failure, DashboardStats>> call(NoParams params) async {
    return await repository.getDashboardStats();
  }
}

class GetActivity implements UseCase<List<ActivityItem>, NoParams> {
  final DashboardRepository repository;
  GetActivity(this.repository);

  @override
  Future<Either<Failure, List<ActivityItem>>> call(NoParams params) async {
    return await repository.getActivity();
  }
}
