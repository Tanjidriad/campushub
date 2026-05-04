class ApiConstants {
  ApiConstants._();

  // Base URL from --dart-define, fallback to production
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://campushub-1-kf0n.onrender.com',
  );
  static const String apiBaseUrl = '$baseUrl/api';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';

  // Admin endpoints
  static const String dashboard = '/admin/dashboard';
  static const String activity = '/admin/activity';
  static const String auditLogs = '/admin/audit-logs';
  static const String users = '/admin/users';
  static const String listings = '/admin/listings';
  static const String pendingListings = '/admin/listings/pending';
  static const String bulkApprove = '/admin/listings/bulk-approve';
  static const String bulkReject = '/admin/listings/bulk-reject';
  static const String bulkDelete = '/admin/listings/bulk-delete';
  static const String reports = '/admin/reports';
  static const String exportUsers = '/admin/export/users';
  static const String exportListings = '/admin/export/listings';
  static const String educationConfig = '/education-config';
  static const String adminEducationConfig = '/admin/education-config';
  static const String categories = '/categories';
  static const String adminCategories = '/categories/admin';
}

class StorageKeys {
  StorageKeys._();
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';
  static const String userRole = 'user_role';
  static const String userAvatar = 'user_avatar';
}
