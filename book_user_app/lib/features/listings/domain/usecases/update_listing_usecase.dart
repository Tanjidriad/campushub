import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/listing.dart';
import '../repositories/listing_repository.dart';

class UpdateListingParams {
  final String id;
  final String? title;
  final String? description;
  final String? category;
  final String? priceType;
  final double? price;
  final String? condition;

  const UpdateListingParams({
    required this.id,
    this.title,
    this.description,
    this.category,
    this.priceType,
    this.price,
    this.condition,
  });
}

class UpdateListingUseCase {
  final ListingRepository repository;

  UpdateListingUseCase(this.repository);

  Future<Either<Failure, Listing>> call(UpdateListingParams params) async {
    return await repository.updateListing(
      id: params.id,
      title: params.title,
      description: params.description,
      category: params.category,
      priceType: params.priceType,
      price: params.price,
      condition: params.condition,
    );
  }
}
