import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';

import '../repositories/listing_repository.dart';

class SearchParams {
  final String query;
  final int page;
  final int limit;

  const SearchParams({required this.query, this.page = 1, this.limit = 10});
}

class SearchListingsUseCase
    implements UseCase<PaginatedListings, SearchParams> {
  final ListingRepository repository;

  SearchListingsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedListings>> call(SearchParams params) async {
    return await repository.searchListings(
      query: params.query,
      page: params.page,
      limit: params.limit,
    );
  }
}
