import 'package:book_user_app/features/reviews/domain/entities/review.dart';
import 'package:equatable/equatable.dart';

abstract class ReviewsState extends Equatable {
  const ReviewsState();

  @override
  List<Object?> get props => [];
}

class ReviewsInitial extends ReviewsState {}

class ReviewsLoading extends ReviewsState {}

class ReviewsLoaded extends ReviewsState {
  final List<Review> reviews;

  const ReviewsLoaded({required this.reviews});

  @override
  List<Object?> get props => [reviews];
}

class ReviewsError extends ReviewsState {
  final String message;

  const ReviewsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ReviewSubmitting extends ReviewsState {}

class ReviewSubmitted extends ReviewsState {
  final Review review;

  const ReviewSubmitted({required this.review});

  @override
  List<Object?> get props => [review];
}

class ReviewSubmitError extends ReviewsState {
  final String message;

  const ReviewSubmitError({required this.message});

  @override
  List<Object?> get props => [message];
}
