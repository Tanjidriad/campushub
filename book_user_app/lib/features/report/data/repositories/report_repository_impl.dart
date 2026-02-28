import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/core/network/api_exceptions.dart';
import 'package:book_user_app/features/report/data/datasources/report_remote_datasource.dart';
import 'package:book_user_app/features/report/domain/entities/report.dart';
import 'package:book_user_app/features/report/domain/repositories/report_repository.dart';
import 'package:dartz/dartz.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Report>> createReport(ReportParams params) async {
    try {
      final report = await remoteDataSource.createReport(params);
      return Right(report);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
