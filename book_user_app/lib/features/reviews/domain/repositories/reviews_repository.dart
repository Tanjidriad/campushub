import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/features/reviews/domain/entities/review.dart';
import 'package:dartz/dartz.dart';

abstract class ReviewsRepository {
  Future<Either<Failure, List<Review>>> getSellerReviews(
    String sellerId, {
    int page = 1,
  });
  Future<Either<Failure, Review>> createReview({
    required String sellerId,
    String? listingId,
    required int rating,
    required String comment,
  });
}
