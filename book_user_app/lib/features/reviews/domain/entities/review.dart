import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerAvatar;
  final double rating;
  final String comment;
  final String? listingTitle;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerAvatar,
    required this.rating,
    required this.comment,
    this.listingTitle,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    reviewerId,
    reviewerName,
    reviewerAvatar,
    rating,
    comment,
    listingTitle,
    createdAt,
  ];
}
