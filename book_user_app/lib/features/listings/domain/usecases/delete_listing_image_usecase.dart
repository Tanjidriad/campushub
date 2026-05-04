import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/listing.dart';
import '../repositories/listing_repository.dart';

class DeleteListingImageUseCase implements UseCase<Listing, DeleteListingImageParams> {
  final ListingRepository repository;

  DeleteListingImageUseCase(this.repository);

  @override
  Future<Either<Failure, Listing>> call(DeleteListingImageParams params) async {
    return await repository.deleteListingImage(params.listingId, params.imageId);
  }
}

class DeleteListingImageParams {
  final String listingId;
  final String imageId;

  const DeleteListingImageParams({
    required this.listingId,
    required this.imageId,
  });
}
