import 'package:dartz/dartz.dart';
import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/core/usecases/usecase.dart';
import '../repositories/wishlist_repository.dart';

class RemoveFromWishlistUseCase implements UseCase<void, String> {
  final WishlistRepository repository;

  RemoveFromWishlistUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    return await repository.removeFromWishlist(id);
  }
}
