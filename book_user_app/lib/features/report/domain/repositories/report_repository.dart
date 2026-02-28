import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/features/report/domain/entities/report.dart';
import 'package:dartz/dartz.dart';

abstract class ReportRepository {
  Future<Either<Failure, Report>> createReport(ReportParams params);
}
