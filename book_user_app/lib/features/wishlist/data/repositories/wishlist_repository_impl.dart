import 'package:dartz/dartz.dart';
import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/core/network/api_exceptions.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:book_user_app/features/wishlist/data/datasources/wishlist_remote_datasource.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource remoteDataSource;

  WishlistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Listing>>> getWishlist() async {
    try {
      final remoteWishlist = await remoteDataSource.getWishlist();
      // Every item returned by the wishlist endpoint is by definition saved by
      // the user, but the backend doesn't always send isInWishlist:true in the
      // response body. Force it here so the heart icon renders correctly.
      final wishlist = remoteWishlist
          .map((item) => item.copyWith(isInWishlist: true))
          .toList();
      return Right(wishlist);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToWishlist(String id) async {
    try {
      await remoteDataSource.addToWishlist(id);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromWishlist(String id) async {
    try {
      await remoteDataSource.removeFromWishlist(id);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
