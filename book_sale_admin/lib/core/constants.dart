class ApiConstants {
  ApiConstants._();

  // Production URL — same as user app
  static const String baseUrl = 'https://coolify.codingwithriad.me';
  static const String apiBaseUrl = '$baseUrl/api';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';

  // Admin endpoints
  static const String dashboard = '/admin/dashboard';
  static const String activity = '/admin/activity';
  static const String users = '/admin/users';
  static const String listings = '/admin/listings';
  static const String pendingListings = '/admin/listings/pending';
  static const String reports = '/admin/reports';
  static const String educationConfig = '/education-config';
  static const String adminEducationConfig = '/admin/education-config';
}

class StorageKeys {
  StorageKeys._();
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
}
