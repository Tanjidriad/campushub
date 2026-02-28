import 'package:book_user_app/core/network/api_client.dart';
import '../../domain/entities/offer.dart';

class OfferRemoteDataSource {
  final ApiClient _apiClient;

  OfferRemoteDataSource(this._apiClient);

  Future<Offer> createOffer({
    required String listingId,
    required double amount,
    String? message,
  }) async {
    final response = await _apiClient.post(
      '/offers',
      data: {
        'listingId': listingId,
        'amount': amount,
        if (message != null) 'message': message,
      },
    );
    return Offer.fromJson(response.data['data']);
  }

  Future<List<Offer>> getOffers({
    String? type,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      '/offers',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
        if (status != null) 'status': status,
      },
    );
    final data = response.data['data'] as List;
    return data.map((json) => Offer.fromJson(json)).toList();
  }

  Future<Offer> getOffer(String offerId) async {
    final response = await _apiClient.get('/offers/$offerId');
    return Offer.fromJson(response.data['data']);
  }

  Future<Offer> respondToOffer({
    required String offerId,
    required String action,
    double? counterAmount,
    String? message,
  }) async {
    final response = await _apiClient.put(
      '/offers/$offerId/respond',
      data: {
        'action': action,
        if (counterAmount != null) 'counterAmount': counterAmount,
        if (message != null) 'message': message,
      },
    );
    return Offer.fromJson(response.data['data']);
  }

  Future<List<Offer>> getListingOffers(String listingId) async {
    final response = await _apiClient.get('/offers/listing/$listingId');
    final data = response.data['data'] as List;
    return data.map((json) => Offer.fromJson(json)).toList();
  }
}
