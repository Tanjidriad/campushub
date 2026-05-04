import '../../../../core/api_client.dart';
import '../../../../core/constants.dart';
import '../models/admin_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AdminUserModel> login(String email, String password);
  Future<bool> hasToken();
  Future<void> logout();
  Future<AdminUserModel?> getSavedUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AdminUserModel> login(String email, String password) async {
    final response = await apiClient.dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );

    final data = response.data;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Login failed');
    }

    final inner = data['data'] ?? {};
    final user = inner['user'];
    final role = user?['role'] ?? '';

    if (role != 'admin' && role != 'superadmin') {
      throw Exception('Access denied. Admin accounts only.');
    }

    final accessToken = inner['accessToken'] as String;
    final refreshToken = inner['refreshToken'] as String;

    await apiClient.saveTokens(accessToken, refreshToken);

    final adminUser = AdminUserModel.fromJson(
      user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    // Persist user data for session restore
    await apiClient.saveUserData(
      id: adminUser.id ?? '',
      name: adminUser.name ?? '',
      email: adminUser.email ?? '',
      role: adminUser.role ?? '',
      avatar: adminUser.avatar,
    );

    return adminUser;
  }

  @override
  Future<bool> hasToken() async {
    return await apiClient.hasToken();
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.dio.post(ApiConstants.logout);
    } catch (_) {
      // Always clear local credentials even if server logout fails.
    }
    await apiClient.clearTokens();
  }

  @override
  Future<AdminUserModel?> getSavedUser() async {
    final data = await apiClient.getSavedUserData();
    if (data['name'] == null && data['email'] == null) return null;
    return AdminUserModel(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      role: data['role'],
      avatar: data['avatar'],
    );
  }
}
