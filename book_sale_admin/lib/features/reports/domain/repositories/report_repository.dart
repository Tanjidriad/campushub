import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/report.dart';

abstract class ReportRepository {
  Future<Either<Failure, List<Report>>> getReports({
    String? status,
    String? targetType,
    int page = 1,
    int limit = 50,
  });

  Future<Either<Failure, Report>> reviewReport({
    required String id,
    required String status,
    required String actionTaken,
    String? resolution,
  });
}
