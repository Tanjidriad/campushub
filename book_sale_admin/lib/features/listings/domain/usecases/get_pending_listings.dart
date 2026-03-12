import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/listing.dart';
import '../repositories/listing_repository.dart';
import 'package:equatable/equatable.dart';

class GetPendingListings implements UseCase<List<Listing>, GetPendingParams> {
  final ListingRepository repository;

  GetPendingListings(this.repository);

  @override
  Future<Either<Failure, List<Listing>>> call(GetPendingParams params) async {
    return await repository.getPendingListings(limit: params.limit);
  }
}

class GetPendingParams extends Equatable {
  final int limit;
  const GetPendingParams({this.limit = 50});

  @override
  List<Object> get props => [limit];
}
