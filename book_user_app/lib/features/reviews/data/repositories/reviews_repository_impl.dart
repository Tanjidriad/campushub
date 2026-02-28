import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/core/network/api_exceptions.dart';
import 'package:book_user_app/features/reviews/data/datasources/reviews_remote_datasource.dart';
import 'package:book_user_app/features/reviews/domain/entities/review.dart';
import 'package:book_user_app/features/reviews/domain/repositories/reviews_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final ReviewsRemoteDataSource remoteDataSource;

  ReviewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Review>>> getSellerReviews(
    String sellerId, {
    int page = 1,
  }) async {
    try {
      final reviews = await remoteDataSource.getSellerReviews(
        sellerId,
        page: page,
      );
      return Right(reviews);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Review>> createReview({
    required String sellerId,
    String? listingId,
    required int rating,
    required String comment,
  }) async {
    try {
      final review = await remoteDataSource.createReview(
        sellerId: sellerId,
        listingId: listingId,
        rating: rating,
        comment: comment,
      );
      return Right(review);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
