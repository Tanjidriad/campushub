import 'package:dartz/dartz.dart';
import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/core/usecases/usecase.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import '../repositories/wishlist_repository.dart';

class GetWishlistUseCase implements UseCase<List<Listing>, NoParams> {
  final WishlistRepository repository;

  GetWishlistUseCase(this.repository);

  @override
  Future<Either<Failure, List<Listing>>> call(NoParams params) async {
    return await repository.getWishlist();
  }
}
