import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/report.dart';
import '../repositories/report_repository.dart';

class GetReports implements UseCase<List<Report>, GetReportsParams> {
  final ReportRepository repository;

  GetReports(this.repository);

  @override
  Future<Either<Failure, List<Report>>> call(GetReportsParams params) async {
    return await repository.getReports(
      status: params.status,
      targetType: params.targetType,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetReportsParams extends Equatable {
  final String? status;
  final String? targetType;
  final int page;
  final int limit;

  const GetReportsParams({
    this.status,
    this.targetType,
    this.page = 1,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [status, targetType, page, limit];
}

class ReviewReport implements UseCase<Report, ReviewReportParams> {
  final ReportRepository repository;

  ReviewReport(this.repository);

  @override
  Future<Either<Failure, Report>> call(ReviewReportParams params) async {
    return await repository.reviewReport(
      id: params.id,
      status: params.status,
      actionTaken: params.actionTaken,
      resolution: params.resolution,
    );
  }
}

class ReviewReportParams extends Equatable {
  final String id;
  final String status;
  final String actionTaken;
  final String? resolution;

  const ReviewReportParams({
    required this.id,
    required this.status,
    required this.actionTaken,
    this.resolution,
  });

  @override
  List<Object?> get props => [id, status, actionTaken, resolution];
}
