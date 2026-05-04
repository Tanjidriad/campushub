import 'package:book_user_app/core/constants/api_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiConstants', () {
    test('apiPrefix is /api', () {
      expect(ApiConstants.apiPrefix, '/api');
    });

    test('login endpoint is under /auth', () {
      expect(ApiConstants.login.startsWith('/auth/'), true);
    });
  });
}

