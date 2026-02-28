import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/features/reviews/domain/entities/review.dart';
import 'package:book_user_app/features/reviews/domain/repositories/reviews_repository.dart';
import 'package:dartz/dartz.dart';

class GetSellerReviewsUseCase {
  final ReviewsRepository repository;

  GetSellerReviewsUseCase(this.repository);

  Future<Either<Failure, List<Review>>> call(
    String sellerId, {
    int page = 1,
  }) async {
    return await repository.getSellerReviews(sellerId, page: page);
  }
}
