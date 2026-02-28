import 'package:dio/dio.dart';
import 'package:book_user_app/core/constants/api_constants.dart';
import 'package:book_user_app/core/network/api_client.dart';
import 'package:book_user_app/core/network/api_exceptions.dart';
import 'package:book_user_app/features/listings/data/models/listing_model.dart';

abstract class WishlistRemoteDataSource {
  Future<List<ListingModel>> getWishlist();
  Future<void> addToWishlist(String id);
  Future<void> removeFromWishlist(String id);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final ApiClient apiClient;

  WishlistRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ListingModel>> getWishlist() async {
    try {
      final response = await apiClient.get('${ApiConstants.listing}/wishlist');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data
            .map(
              (listing) =>
                  ListingModel.fromJson(listing as Map<String, dynamic>),
            )
            .toList();
      }

      throw ApiException(
        message: response.data?['message'] ?? 'Failed to load wishlist',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<void> addToWishlist(String id) async {
    try {
      final response = await apiClient.post(
        '${ApiConstants.listing}/$id/wishlist',
      );

      if (response.statusCode != 200) {
        throw ApiException(
          message: response.data?['message'] ?? 'Failed to add to wishlist',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<void> removeFromWishlist(String id) async {
    try {
      final response = await apiClient.delete(
        '${ApiConstants.listing}/$id/wishlist',
      );

      if (response.statusCode != 200) {
        throw ApiException(
          message:
              response.data?['message'] ?? 'Failed to remove from wishlist',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }
}
