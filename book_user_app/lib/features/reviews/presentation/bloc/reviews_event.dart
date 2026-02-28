import 'package:equatable/equatable.dart';

abstract class ReviewsEvent extends Equatable {
  const ReviewsEvent();

  @override
  List<Object?> get props => [];
}

class ReviewsLoadRequested extends ReviewsEvent {
  final String sellerId;
  final int page;

  const ReviewsLoadRequested({required this.sellerId, this.page = 1});

  @override
  List<Object?> get props => [sellerId, page];
}

class SubmitReviewRequested extends ReviewsEvent {
  final String sellerId;
  final String? listingId;
  final int rating;
  final String comment;

  const SubmitReviewRequested({
    required this.sellerId,
    this.listingId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [sellerId, listingId, rating, comment];
}
