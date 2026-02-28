import 'package:book_user_app/core/network/api_client.dart';
import 'package:book_user_app/core/network/api_exceptions.dart';
import 'package:book_user_app/features/auth/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getUserProfile(String id);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> getUserProfile(String id) async {
    final response = await apiClient.get('/users/$id');

    if (response.statusCode == 200 && response.data['success'] == true) {
      return UserModel.fromJson(response.data['data']);
    } else {
      throw ApiException(
        message: response.data['message'] ?? 'Failed to load profile',
        statusCode: response.statusCode,
        data: response.data,
      );
    }
  }
}
