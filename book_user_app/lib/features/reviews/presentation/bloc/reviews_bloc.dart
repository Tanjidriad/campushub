import 'package:book_user_app/features/reviews/domain/usecases/create_review_usecase.dart';
import 'package:book_user_app/features/reviews/domain/usecases/get_seller_reviews_usecase.dart';
import 'package:book_user_app/features/reviews/presentation/bloc/reviews_event.dart';
import 'package:book_user_app/features/reviews/presentation/bloc/reviews_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReviewsBloc extends Bloc<ReviewsEvent, ReviewsState> {
  final GetSellerReviewsUseCase getSellerReviewsUseCase;
  final CreateReviewUseCase createReviewUseCase;

  ReviewsBloc({
    required this.getSellerReviewsUseCase,
    required this.createReviewUseCase,
  }) : super(ReviewsInitial()) {
    on<ReviewsLoadRequested>(_onReviewsLoadRequested);
    on<SubmitReviewRequested>(_onSubmitReviewRequested);
  }

  Future<void> _onReviewsLoadRequested(
    ReviewsLoadRequested event,
    Emitter<ReviewsState> emit,
  ) async {
    emit(ReviewsLoading());

    final result = await getSellerReviewsUseCase(
      event.sellerId,
      page: event.page,
    );

    result.fold(
      (failure) => emit(ReviewsError(message: failure.message)),
      (reviews) => emit(ReviewsLoaded(reviews: reviews)),
    );
  }

  Future<void> _onSubmitReviewRequested(
    SubmitReviewRequested event,
    Emitter<ReviewsState> emit,
  ) async {
    emit(ReviewSubmitting());

    final result = await createReviewUseCase(
      sellerId: event.sellerId,
      listingId: event.listingId,
      rating: event.rating,
      comment: event.comment,
    );

    result.fold(
      (failure) => emit(ReviewSubmitError(message: failure.message)),
      (review) => emit(ReviewSubmitted(review: review)),
    );
  }
}
