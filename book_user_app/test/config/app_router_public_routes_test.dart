import 'package:book_user_app/config/routes/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRouter.isPublicRouteWhenUnauthenticated', () {
    test('allows onboarding and auth flows', () {
      expect(AppRouter.isPublicRouteWhenUnauthenticated('/'), isTrue);
      expect(AppRouter.isPublicRouteWhenUnauthenticated('/onboarding'), isTrue);
      expect(AppRouter.isPublicRouteWhenUnauthenticated('/login'), isTrue);
      expect(AppRouter.isPublicRouteWhenUnauthenticated('/register'), isTrue);
      expect(
        AppRouter.isPublicRouteWhenUnauthenticated('/forgot-password'),
        isTrue,
      );
      expect(
        AppRouter.isPublicRouteWhenUnauthenticated('/reset-password/abc123'),
        isTrue,
      );
    });

    test('does not allow protected sections', () {
      expect(AppRouter.isPublicRouteWhenUnauthenticated('/home'), isFalse);
      expect(AppRouter.isPublicRouteWhenUnauthenticated('/chat'), isFalse);
    });
  });
}
