import 'package:book_user_app/config/routes/app_router.dart';
import 'package:book_user_app/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final FlutterSecureStorage secureStorage;
  bool _isRefreshing = false;

  AuthInterceptor({required this.dio, required this.secureStorage});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token for public endpoints
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    // Add access token to headers
    final accessToken = await secureStorage.read(key: StorageKeys.accessToken);
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        // Try to refresh token
        final refreshed = await _refreshToken();

        if (refreshed) {
          // Retry the original request with new token
          final accessToken = await secureStorage.read(
            key: StorageKeys.accessToken,
          );

          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $accessToken';

          final response = await dio.fetch(options);
          _isRefreshing = false;
          return handler.resolve(response);
        }
      } catch (e) {
        // Refresh failed
        await _performLogout();
      } finally {
        _isRefreshing = false;
      }
    }

    return handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    if (path.contains(ApiConstants.login)) return true;
    if (path.contains(ApiConstants.register)) return true;

    // Check if path ends with any public endpoint
    final publicEndpoints = [ApiConstants.login, ApiConstants.register];

    return publicEndpoints.any((endpoint) => path.endsWith(endpoint));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await secureStorage.read(
        key: StorageKeys.refreshToken,
      );
      if (refreshToken == null) return false;

      // Create a separate Dio instance to avoid infinite loops and interceptors
      final tokenDio = Dio(BaseOptions(baseUrl: ApiConstants.apiBaseUrl));

      final response = await tokenDio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];

        await secureStorage.write(
          key: StorageKeys.accessToken,
          value: newAccessToken,
        );

        // Some backends rotate refresh tokens too
        if (newRefreshToken != null) {
          await secureStorage.write(
            key: StorageKeys.refreshToken,
            value: newRefreshToken,
          );
        }

        return true;
      }
    } catch (_) {
      // Refresh failed
    }

    return false;
  }

  Future<void> _performLogout() async {
    await secureStorage.delete(key: StorageKeys.accessToken);
    await secureStorage.delete(key: StorageKeys.refreshToken);
    await secureStorage.delete(key: StorageKeys.isLoggedIn);
    // Token refresh failed — session is dead, force user back to login
    AppRouter.router.go('/login');
  }
}
