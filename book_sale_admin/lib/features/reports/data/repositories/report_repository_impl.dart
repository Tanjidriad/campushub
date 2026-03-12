import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Report>>> getReports({
    String? status,
    String? targetType,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final reports = await remoteDataSource.getReports(
        status: status,
        targetType: targetType,
        page: page,
        limit: limit,
      );
      return Right(reports);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Report>> reviewReport({
    required String id,
    required String status,
    required String actionTaken,
    String? resolution,
  }) async {
    try {
      final report = await remoteDataSource.reviewReport(
        id: id,
        status: status,
        actionTaken: actionTaken,
        resolution: resolution,
      );
      return Right(report);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
