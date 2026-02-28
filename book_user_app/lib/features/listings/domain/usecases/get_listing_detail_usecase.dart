import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/listing.dart';
import '../repositories/listing_repository.dart';

class GetListingDetailUseCase implements UseCase<Listing, String> {
  final ListingRepository repository;

  GetListingDetailUseCase(this.repository);

  @override
  Future<Either<Failure, Listing>> call(String listingId) async {
    return await repository.getListingById(listingId);
  }
}
