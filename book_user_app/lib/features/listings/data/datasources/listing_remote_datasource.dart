import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/listing_model.dart';

import '../../domain/repositories/listing_repository.dart';

/// Abstract datasource for listing API calls
abstract class ListingRemoteDataSource {
  Future<PaginatedListings> getListings(ListingsParams params);
  Future<ListingModel> getListingById(String id);
  Future<PaginatedListings> searchListings({
    required String query,
    int page = 1,
    int limit = 10,
  });
  Future<PaginatedListings> getMyListings({
    int page = 1,
    int limit = 10,
    String? status,
  });
  Future<ListingModel> createListing({
    required String title,
    required String description,
    required String category,
    required String priceType,
    double? price,
    String? currency,
    String? condition,
    String? locationName,
    String? locationAddress,
    String? meetupPreferences,
    List<String>? tags,
    required List<String> imagePaths,
    String? educationLevel,
    String? classOrSemester,
    String? subject,
    String? bookType,
    String? division,
    String? district,
    String? upazila,
  });
  Future<ListingModel> updateListing({
    required String id,
    String? title,
    String? description,
    String? category,
    String? priceType,
    double? price,
    String? condition,
  });
  Future<void> deleteListing(String id);
  Future<bool> addToWishlist(String listingId);
  Future<bool> removeFromWishlist(String listingId);
  Future<List<ListingModel>> getWishlist();
  Future<ListingModel> promoteListing(String listingId, String plan);
  Future<void> markAsSold(
    String listingId, {
    String? buyerId,
    double? soldPrice,
  });
}

/// Implementation of ListingRemoteDataSource
class ListingRemoteDataSourceImpl implements ListingRemoteDataSource {
  final ApiClient apiClient;

  ListingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PaginatedListings> getListings(ListingsParams params) async {
    try {
      String endpoint = ApiConstants.listing;
      final queryParams = params.toQueryParams();

      if (params.sellerId != null) {
        endpoint = '${ApiConstants.listing}/user/${params.sellerId}';
        queryParams.remove('sellerId');
      }

      final response = await apiClient.get(
        endpoint,
        queryParameters: queryParams, // params.toQueryParams()
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final listingsJson = data['data'] as List<dynamic>;
        final listings = listingsJson
            .map((json) => ListingModel.fromJson(json as Map<String, dynamic>))
            .toList();

        final pagination = data['pagination'] as Map<String, dynamic>?;

        return PaginatedListings(
          listings: listings,
          currentPage: pagination?['currentPage'] ?? params.page,
          totalPages: pagination?['totalPages'] ?? 1,
          totalItems: pagination?['total'] ?? listings.length,
          hasMore: pagination?['hasNextPage'] ?? false,
        );
      }

      throw ApiException(
        message: response.data?['message'] ?? 'Failed to fetch listings',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<ListingModel> getListingById(String id) async {
    try {
      final response = await apiClient.get('${ApiConstants.listing}/$id');

      if (response.statusCode == 200) {
        return ListingModel.fromJson(response.data['data']);
      }

      throw ApiException(
        message: response.data?['message'] ?? 'Failed to fetch listing',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<PaginatedListings> searchListings({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConstants.listing,
        queryParameters: {'search': query, 'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final listingsJson = data['data'] as List<dynamic>;
        final listings = listingsJson
            .map((json) => ListingModel.fromJson(json as Map<String, dynamic>))
            .toList();

        final pagination = data['pagination'] as Map<String, dynamic>?;

        return PaginatedListings(
          listings: listings,
          currentPage: pagination?['currentPage'] ?? page,
          totalPages: pagination?['totalPages'] ?? 1,
          totalItems: pagination?['total'] ?? listings.length,
          hasMore: pagination?['hasNextPage'] ?? false,
        );
      }

      throw ApiException(
        message: response.data?['message'] ?? 'Failed to search listings',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<PaginatedListings> getMyListings({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null) queryParams['status'] = status;

      final response = await apiClient.get(
        '${ApiConstants.listing}/my-listings',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final listingsJson = data['data'] as List<dynamic>;
        final listings = listingsJson
            .map((json) => ListingModel.fromJson(json as Map<String, dynamic>))
            .toList();

        final pagination = data['pagination'] as Map<String, dynamic>?;

        return PaginatedListings(
          listings: listings,
          currentPage: pagination?['currentPage'] ?? page,
          totalPages: pagination?['totalPages'] ?? 1,
          totalItems: pagination?['total'] ?? listings.length,
          hasMore: pagination?['hasNextPage'] ?? false,
        );
      }

      throw ApiException(
        message: response.data?['message'] ?? 'Failed to fetch your listings',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<ListingModel> createListing({
    required String title,
    required String description,
    required String category,
    required String priceType,
    double? price,
    String? currency,
    String? condition,
    String? locationName,
    String? locationAddress,
    String? meetupPreferences,
    List<String>? tags,
    required List<String> imagePaths,
    String? educationLevel,
    String? classOrSemester,
    String? subject,
    String? bookType,
    String? division,
    String? district,
    String? upazila,
  }) async {
    try {
      // Create multipart form data
      final formData = FormData();

      // Add text fields
      formData.fields.addAll([
        MapEntry('title', title),
        MapEntry('description', description),
        MapEntry('category', category),
        MapEntry('priceType', priceType),
      ]);

      if (price != null) {
        formData.fields.add(MapEntry('price', price.toString()));
      }
      if (currency != null) {
        formData.fields.add(MapEntry('currency', currency));
      }
      if (condition != null) {
        formData.fields.add(MapEntry('condition', condition));
      }
      if (locationName != null) {
        formData.fields.add(MapEntry('location[name]', locationName));
      }
      if (locationAddress != null) {
        formData.fields.add(MapEntry('location[address]', locationAddress));
      }
      if (meetupPreferences != null) {
        formData.fields.add(MapEntry('meetupPreferences', meetupPreferences));
      }
      if (tags != null && tags.isNotEmpty) {
        for (int i = 0; i < tags.length; i++) {
          formData.fields.add(MapEntry('tags[$i]', tags[i]));
        }
      }
      if (educationLevel != null) {
        formData.fields.add(MapEntry('educationLevel', educationLevel));
      }
      if (classOrSemester != null) {
        formData.fields.add(MapEntry('classOrSemester', classOrSemester));
      }
      if (subject != null) {
        formData.fields.add(MapEntry('subject', subject));
      }
      if (bookType != null) {
        formData.fields.add(MapEntry('bookType', bookType));
      }
      if (division != null) {
        formData.fields.add(MapEntry('division', division));
      }
      if (district != null) {
        formData.fields.add(MapEntry('district', district));
      }
      if (upazila != null) {
        formData.fields.add(MapEntry('upazila', upazila));
      }

      // Add images
      for (final imagePath in imagePaths) {
        final file = File(imagePath);
        if (await file.exists()) {
          formData.files.add(
            MapEntry(
              'images',
              await MultipartFile.fromFile(
                imagePath,
                filename: imagePath.split('/').last,
              ),
            ),
          );
        }
      }

      final response = await apiClient.post(
        ApiConstants.listing,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ListingModel.fromJson(response.data['data']);
      }

      throw ApiException(
        message: response.data?['message'] ?? 'Failed to create listing',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<ListingModel> updateListing({
    required String id,
    String? title,
    String? description,
    String? category,
    String? priceType,
    double? price,
    String? condition,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (category != null) data['category'] = category;
      if (priceType != null) data['priceType'] = priceType;
      if (price != null) data['price'] = price;
      if (condition != null) data['condition'] = condition;

      final response = await apiClient.put(
        '${ApiConstants.listing}/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        return ListingModel.fromJson(response.data['data']);
      }

      throw ApiException(
        message: response.data?['message'] ?? 'Failed to update listing',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<void> deleteListing(String id) async {
    try {
      final response = await apiClient.delete('${ApiConstants.listing}/$id');

      if (response.statusCode != 200) {
        throw ApiException(
          message: response.data?['message'] ?? 'Failed to delete listing',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<bool> addToWishlist(String listingId) async {
    try {
      final response = await apiClient.post(
        '${ApiConstants.listing}/$listingId/wishlist',
      );

      if (response.statusCode == 200) {
        return true;
      }

      throw ApiException(
        message: response.data?['message'] ?? 'Failed to add to wishlist',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<bool> removeFromWishlist(String listingId) async {
    try {
      final response = await apiClient.delete(
        '${ApiConstants.listing}/$listingId/wishlist',
      );

      if (response.statusCode == 200) {
        return false;
      }

      throw ApiException(
        message: response.data?['message'] ?? 'Failed to remove from wishlist',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<List<ListingModel>> getWishlist() async {
    try {
      final response = await apiClient.get('${ApiConstants.listing}/wishlist');

      if (response.statusCode == 200) {
        final listingsJson = response.data['data'] as List<dynamic>;
        return listingsJson
            .map((json) => ListingModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        message: response.data?['message'] ?? 'Failed to fetch wishlist',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<ListingModel> promoteListing(String listingId, String plan) async {
    try {
      final response = await apiClient.post(
        '${ApiConstants.listing}/$listingId/promote',
        data: {'plan': plan},
      );

      if (response.statusCode == 200 && response.data?['success'] == true) {
        return ListingModel.fromJson(response.data['data']);
      }

      throw ApiException(
        message: response.data?['message'] ?? 'Failed to promote listing',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<void> markAsSold(
    String listingId, {
    String? buyerId,
    double? soldPrice,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (buyerId != null) data['buyerId'] = buyerId;
      if (soldPrice != null) data['soldPrice'] = soldPrice;

      final response = await apiClient.put(
        '${ApiConstants.listing}/$listingId/sold',
        data: data,
      );

      if (response.statusCode != 200 || response.data?['success'] != true) {
        throw ApiException(
          message: response.data?['message'] ?? 'Failed to mark as sold',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }
}
