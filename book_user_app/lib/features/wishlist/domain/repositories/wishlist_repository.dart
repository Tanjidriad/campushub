import 'package:dartz/dartz.dart';
import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';

abstract class WishlistRepository {
  Future<Either<Failure, List<Listing>>> getWishlist();
  Future<Either<Failure, void>> addToWishlist(String id);
  Future<Either<Failure, void>> removeFromWishlist(String id);
}
