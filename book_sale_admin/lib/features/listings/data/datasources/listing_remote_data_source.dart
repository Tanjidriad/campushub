import '../../../../core/api_client.dart';
import '../../../../core/constants.dart';
import '../models/listing_model.dart';

abstract class ListingRemoteDataSource {
  Future<List<ListingModel>> getPendingListings({int limit = 50});
  Future<List<ListingModel>> getAllListings({
    int limit = 50,
    String? search,
    String? category,
    bool? isFeatured,
  });
  Future<ListingModel> getListingDetail(String id);
  Future<void> approveListing(String id);
  Future<void> rejectListing(String id, String reason);
  Future<void> deleteListing(String id);
  Future<void> toggleFeatureListing(String id);
  Future<void> bulkApprove(List<String> ids);
  Future<void> bulkReject(List<String> ids, String reason);
  Future<void> bulkDelete(List<String> ids);
}

class ListingRemoteDataSourceImpl implements ListingRemoteDataSource {
  final ApiClient apiClient;

  ListingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ListingModel>> getPendingListings({int limit = 50}) async {
    final response = await apiClient.dio.get(
      ApiConstants.pendingListings,
      queryParameters: {'limit': limit},
    );
    final data = response.data['data'] as List?;
    if (data == null) throw Exception('No data returned');
    return data.map((e) => ListingModel.fromJson(e)).toList();
  }

  @override
  Future<List<ListingModel>> getAllListings({
    int limit = 50,
    String? search,
    String? category,
    bool? isFeatured,
  }) async {
    final params = <String, dynamic>{'limit': limit};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (category != null && category != 'All' && category != 'Featured') {
      params['category'] = category;
    }
    if (isFeatured != null && isFeatured) {
      params['isFeatured'] = isFeatured;
    }

    final response = await apiClient.dio.get(
      ApiConstants.listings,
      queryParameters: params,
    );
    final data = response.data['data'] as List?;
    if (data == null) throw Exception('No data returned');
    return data.map((e) => ListingModel.fromJson(e)).toList();
  }

  @override
  Future<ListingModel> getListingDetail(String id) async {
    final response = await apiClient.dio.get('${ApiConstants.listings}/$id');
    if (response.data['success'] == true) {
      return ListingModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch listing');
  }

  @override
  Future<void> approveListing(String id) async {
    await apiClient.dio.put('${ApiConstants.listings}/$id/approve');
  }

  @override
  Future<void> rejectListing(String id, String reason) async {
    await apiClient.dio.put(
      '${ApiConstants.listings}/$id/reject',
      data: {'reason': reason},
    );
  }

  @override
  Future<void> deleteListing(String id) async {
    await apiClient.dio.delete('${ApiConstants.listings}/$id');
  }

  @override
  Future<void> toggleFeatureListing(String id) async {
    await apiClient.dio.put('${ApiConstants.listings}/$id/feature');
  }

  @override
  Future<void> bulkApprove(List<String> ids) async {
    await apiClient.dio.post(
      ApiConstants.bulkApprove,
      data: {'listingIds': ids},
    );
  }

  @override
  Future<void> bulkReject(List<String> ids, String reason) async {
    await apiClient.dio.post(
      ApiConstants.bulkReject,
      data: {'listingIds': ids, 'reason': reason},
    );
  }

  @override
  Future<void> bulkDelete(List<String> ids) async {
    await apiClient.dio.post(
      ApiConstants.bulkDelete,
      data: {'listingIds': ids},
    );
  }
}
