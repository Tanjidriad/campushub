import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio dio;
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  ApiClient._() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiBaseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: StorageKeys.accessToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Try refresh
            final refreshed = await _refreshToken();
            if (refreshed) {
              final token = await _storage.read(key: StorageKeys.accessToken);
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              final retryResponse = await dio.fetch(error.requestOptions);
              return handler.resolve(retryResponse);
            }
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }
  }

  factory ApiClient() {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Future<bool> _refreshToken() async {
    try {
      final refresh = await _storage.read(key: StorageKeys.refreshToken);
      if (refresh == null) return false;

      final response = await Dio().post(
        '${ApiConstants.apiBaseUrl}${ApiConstants.refreshToken}',
        data: {'refreshToken': refresh},
      );

      if (response.data['success'] == true) {
        await _storage.write(
          key: StorageKeys.accessToken,
          value: response.data['accessToken'],
        );
        if (response.data['refreshToken'] != null) {
          await _storage.write(
            key: StorageKeys.refreshToken,
            value: response.data['refreshToken'],
          );
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: StorageKeys.accessToken, value: access);
    await _storage.write(key: StorageKeys.refreshToken, value: refresh);
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }

  Future<bool> hasToken() async {
    final token = await _storage.read(key: StorageKeys.accessToken);
    return token != null;
  }
}
