import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/listing_repository.dart';

class MarkListingSoldParams {
  final String listingId;
  final String? buyerId;
  final double? soldPrice;

  const MarkListingSoldParams({
    required this.listingId,
    this.buyerId,
    this.soldPrice,
  });
}

class MarkListingSoldUseCase {
  final ListingRepository repository;

  MarkListingSoldUseCase(this.repository);

  Future<Either<Failure, void>> call(MarkListingSoldParams params) async {
    return await repository.markAsSold(
      params.listingId,
      buyerId: params.buyerId,
      soldPrice: params.soldPrice,
    );
  }
}
