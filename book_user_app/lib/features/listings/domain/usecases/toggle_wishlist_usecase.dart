import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/listing_repository.dart';

class ToggleWishlistUseCase implements UseCase<bool, String> {
  final ListingRepository repository;

  ToggleWishlistUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String listingId) async {
    return await repository.toggleWishlist(listingId);
  }
}
