import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';

import '../repositories/listing_repository.dart';

class GetMyListingsParams {
  final int page;
  final int limit;
  final String? status;

  const GetMyListingsParams({this.page = 1, this.limit = 10, this.status});
}

class GetMyListingsUseCase
    implements UseCase<PaginatedListings, GetMyListingsParams> {
  final ListingRepository repository;

  GetMyListingsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedListings>> call(
    GetMyListingsParams params,
  ) async {
    return await repository.getMyListings(
      page: params.page,
      limit: params.limit,
      status: params.status,
    );
  }
}
