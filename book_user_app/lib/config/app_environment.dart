import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Environment helper for resolving the base API URL.
///
/// Production buyers should pass `--dart-define=API_BASE_URL=https://api.yourdomain.com`
/// at build time. For local development, sensible defaults are provided for
/// Android emulators, iOS simulators, and Flutter web.
class AppEnvironment {
  static const String _apiBaseUrlFromEnv = String.fromEnvironment(
    'API_BASE_URL',
  );

  static const int _defaultPort = 3000;
  static const String _androidLocalIp = '192.168.0.116';

  /// Base URL for all API calls (without `/api` prefix).
  static String get baseUrl {
    if (_apiBaseUrlFromEnv.isNotEmpty) {
      return _apiBaseUrlFromEnv;
    }

    return 'https://campushub-1-kf0n.onrender.com';
  }
}
