import 'package:book_user_app/config/app_environment.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl {
    return AppEnvironment.baseUrl;
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
  static const String profile = '/auth/profile';
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
