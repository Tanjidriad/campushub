import 'package:book_user_app/core/network/api_client.dart';
import 'package:book_user_app/core/network/api_exceptions.dart';
import 'package:book_user_app/features/reviews/data/models/review_model.dart';

abstract class ReviewsRemoteDataSource {
  Future<List<ReviewModel>> getSellerReviews(String sellerId, {int page = 1});
  Future<ReviewModel> createReview({
    required String sellerId,
    String? listingId,
    required int rating,
    required String comment,
  });
}

class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  final ApiClient apiClient;

  ReviewsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ReviewModel>> getSellerReviews(
    String sellerId, {
    int page = 1,
  }) async {
    final response = await apiClient.get(
      '/reviews/seller/$sellerId',
      queryParameters: {'page': page, 'limit': 10},
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data']['reviews'] as List<dynamic>;
      return data.map((json) => ReviewModel.fromJson(json)).toList();
    } else {
      throw ApiException(
        message: response.data['message'] ?? 'Failed to load reviews',
        statusCode: response.statusCode,
        data: response.data,
      );
    }
  }

  @override
  Future<ReviewModel> createReview({
    required String sellerId,
    String? listingId,
    required int rating,
    required String comment,
  }) async {
    final body = <String, dynamic>{
      'sellerId': sellerId,
      'rating': rating,
      'comment': comment,
    };
    if (listingId != null) body['listingId'] = listingId;

    final response = await apiClient.post('/reviews', data: body);

    if (response.statusCode == 201 && response.data['success'] == true) {
      return ReviewModel.fromJson(response.data['data']);
    } else {
      throw ApiException(
        message: response.data['message'] ?? 'Failed to submit review',
        statusCode: response.statusCode,
        data: response.data,
      );
    }
  }
}
