import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/listing_repository.dart';
import 'package:equatable/equatable.dart';

class ApproveListing implements UseCase<void, String> {
  final ListingRepository repository;

  ApproveListing(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    return await repository.approveListing(id);
  }
}

class RejectListing implements UseCase<void, RejectParams> {
  final ListingRepository repository;

  RejectListing(this.repository);

  @override
  Future<Either<Failure, void>> call(RejectParams params) async {
    return await repository.rejectListing(params.id, params.reason);
  }
}

class RejectParams extends Equatable {
  final String id;
  final String reason;

  const RejectParams({required this.id, required this.reason});

  @override
  List<Object?> get props => [id, reason];
}

class DeleteListing implements UseCase<void, String> {
  final ListingRepository repository;

  DeleteListing(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteListing(id);
  }
}

class ToggleFeatureListing implements UseCase<void, String> {
  final ListingRepository repository;

  ToggleFeatureListing(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    return await repository.toggleFeatureListing(id);
  }
}
