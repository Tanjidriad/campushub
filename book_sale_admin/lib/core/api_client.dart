import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio dio;
  final _storage = const FlutterSecureStorage(aOptions: AndroidOptions());
  Completer<bool>? _refreshCompleter;

  ApiClient._() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiBaseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: <String, dynamic>{
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
    // If a refresh is already in progress, wait for it
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer<bool>();
    try {
      final refresh = await _storage.read(key: StorageKeys.refreshToken);
      if (refresh == null) {
        _refreshCompleter!.complete(false);
        return false;
      }

      final response = await Dio().post(
        '${ApiConstants.apiBaseUrl}${ApiConstants.refreshToken}',
        data: {'refreshToken': refresh},
      );

      if (response.data['success'] == true) {
        final tokenData =
            response.data['data'] as Map<String, dynamic>? ?? const {};
        final accessToken = tokenData['accessToken'] as String?;
        final refreshToken = tokenData['refreshToken'] as String?;

        if (accessToken == null || accessToken.isEmpty) {
          _refreshCompleter!.complete(false);
          return false;
        }

        await _storage.write(key: StorageKeys.accessToken, value: accessToken);
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await _storage.write(
            key: StorageKeys.refreshToken,
            value: refreshToken,
          );
        }
        _refreshCompleter!.complete(true);
        return true;
      }
      _refreshCompleter!.complete(false);
    } catch (e) {
      if (kDebugMode) debugPrint('Token refresh failed: $e');
      _refreshCompleter!.complete(false);
    } finally {
      _refreshCompleter = null;
    }
    return false;
  }

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: StorageKeys.accessToken, value: access);
    await _storage.write(key: StorageKeys.refreshToken, value: refresh);
  }

  Future<void> saveUserData({
    required String id,
    required String name,
    required String email,
    required String role,
    String? avatar,
  }) async {
    await _storage.write(key: StorageKeys.userId, value: id);
    await _storage.write(key: StorageKeys.userName, value: name);
    await _storage.write(key: StorageKeys.userEmail, value: email);
    await _storage.write(key: StorageKeys.userRole, value: role);
    if (avatar != null) {
      await _storage.write(key: StorageKeys.userAvatar, value: avatar);
    }
  }

  Future<Map<String, String?>> getSavedUserData() async {
    return {
      'id': await _storage.read(key: StorageKeys.userId),
      'name': await _storage.read(key: StorageKeys.userName),
      'email': await _storage.read(key: StorageKeys.userEmail),
      'role': await _storage.read(key: StorageKeys.userRole),
      'avatar': await _storage.read(key: StorageKeys.userAvatar),
    };
  }

  Future<void> clearTokens() async {
    for (final key in [
      StorageKeys.accessToken,
      StorageKeys.refreshToken,
      StorageKeys.userId,
      StorageKeys.userName,
      StorageKeys.userEmail,
      StorageKeys.userRole,
      StorageKeys.userAvatar,
    ]) {
      await _storage.delete(key: key);
    }
  }

  Future<bool> hasToken() async {
    final token = await _storage.read(key: StorageKeys.accessToken);
    return token != null;
  }
}
