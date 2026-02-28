import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';

import '../repositories/listing_repository.dart';

class GetListingsUseCase implements UseCase<PaginatedListings, ListingsParams> {
  final ListingRepository repository;

  GetListingsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedListings>> call(ListingsParams params) async {
    return await repository.getListings(params);
  }
}
