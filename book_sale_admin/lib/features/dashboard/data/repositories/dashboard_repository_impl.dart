import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    try {
      final stats = await remoteDataSource.getDashboardStats();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ActivityItem>>> getActivity() async {
    try {
      final activity = await remoteDataSource.getActivity();
      return Right(activity);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
