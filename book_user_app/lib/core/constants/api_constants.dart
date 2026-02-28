import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  ApiConstants._();

  // Production URL
  static const String _productionUrl = 'https://coolify.codingwithriad.me';

  // Set to true to use production server, false for local development
  static const bool useProduction = true;

  // Local development settings
  static const String _localIp = '10.0.2.2';
  static const int _port = 3000;

  static String get baseUrl {
    if (useProduction) {
      return _productionUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:$_port';
    }

    if (Platform.isAndroid) {
      return 'http://$_localIp:$_port';
    }

    if (Platform.isIOS) {
      return 'http://localhost:$_port';
    }

    return 'http://localhost:$_port';
  }

  static const String apiPrefix = '/api';
  static String get apiBaseUrl => '$baseUrl$apiPrefix';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String listing = '/listings';
  static const String chat = '/chat';
  static const String profile = '/users/profile';
  static const String checkUsername = '/auth/check-username'; // + /:username
}

class StorageKeys {
  StorageKeys._();

  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
  static const String isLoggedIn = 'is_logged_in';
  static const String hasSeenOnboarding = 'has_seen_onboarding';
}
