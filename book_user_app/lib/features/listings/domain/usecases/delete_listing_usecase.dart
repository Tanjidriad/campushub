import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/listing_repository.dart';

class DeleteListingUseCase {
  final ListingRepository repository;

  DeleteListingUseCase(this.repository);

  Future<Either<Failure, void>> call(String listingId) async {
    return await repository.deleteListing(listingId);
  }
}
