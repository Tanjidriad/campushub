import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/features/reviews/domain/entities/review.dart';
import 'package:book_user_app/features/reviews/domain/repositories/reviews_repository.dart';
import 'package:dartz/dartz.dart';

class CreateReviewUseCase {
  final ReviewsRepository repository;

  CreateReviewUseCase(this.repository);

  Future<Either<Failure, Review>> call({
    required String sellerId,
    String? listingId,
    required int rating,
    required String comment,
  }) async {
    return await repository.createReview(
      sellerId: sellerId,
      listingId: listingId,
      rating: rating,
      comment: comment,
    );
  }
}
