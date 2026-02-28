import 'package:book_user_app/features/reviews/domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.reviewerId,
    required super.reviewerName,
    super.reviewerAvatar,
    required super.rating,
    required super.comment,
    super.listingTitle,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Handle reviewer population
    final reviewer = json['reviewer'];
    String rId = '';
    String rName = 'Unknown';
    String? rAvatar;

    if (reviewer is Map<String, dynamic>) {
      rId = reviewer['_id'] ?? reviewer['id'] ?? '';
      rName = reviewer['name'] ?? 'Unknown';
      rAvatar = reviewer['avatar'];
    } else if (reviewer is String) {
      rId = reviewer;
    }

    // Handle listing population
    final listing = json['listing'];
    String? listingTitle;
    if (listing is Map<String, dynamic>) {
      listingTitle = listing['title'];
    }

    return ReviewModel(
      id: json['_id'] ?? json['id'] ?? '',
      reviewerId: rId,
      reviewerName: rName,
      reviewerAvatar: rAvatar,
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      listingTitle: listingTitle,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
