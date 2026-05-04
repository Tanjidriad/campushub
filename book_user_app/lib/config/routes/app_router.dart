import 'package:book_user_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:book_user_app/features/auth/presentation/pages/login_page.dart';
import 'package:book_user_app/features/auth/presentation/pages/onboarding_page.dart';
import 'package:book_user_app/features/auth/presentation/pages/register_page.dart';
import 'package:book_user_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:book_user_app/features/auth/presentation/pages/splash_page.dart';
import 'package:book_user_app/features/auth/presentation/pages/verify_email_page.dart';
import 'package:book_user_app/features/listings/presentation/pages/home_page.dart';
import 'package:book_user_app/features/create_listing/presentation/pages/index.dart';
import 'package:book_user_app/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:book_user_app/features/auth/presentation/pages/change_password_page.dart';
import 'package:book_user_app/features/chat/presentation/pages/blocked_users_page.dart';
import 'package:book_user_app/features/profile/presentation/pages/profile_page.dart';
import 'package:book_user_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:book_user_app/features/auth/domain/entities/user.dart';
import 'package:book_user_app/features/chat/presentation/pages/chat_page.dart';
import 'package:book_user_app/features/chat/presentation/pages/messages_page.dart';
import 'package:book_user_app/features/listings/presentation/pages/listing_detail_page.dart';
import 'package:book_user_app/features/profile/presentation/pages/user_profile_page.dart';
import 'package:book_user_app/features/profile/presentation/pages/seller_profile_route_page.dart';
import 'package:book_user_app/features/listings/presentation/pages/promote_listing_page.dart';
import 'package:book_user_app/features/listings/presentation/pages/edit_listing_page.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:book_user_app/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:book_user_app/features/offers/presentation/pages/offer_request_page.dart';
import 'package:book_user_app/features/offers/presentation/bloc/offer_bloc.dart';
import 'package:book_user_app/features/reviews/presentation/pages/write_review_page.dart';
import 'package:book_user_app/features/reviews/presentation/bloc/reviews_bloc.dart';
import 'package:book_user_app/features/listings/presentation/pages/see_all_listings_page.dart';
import 'package:book_user_app/features/listings/presentation/pages/category_hub_page.dart';
import 'package:book_user_app/features/settings/presentation/pages/settings_page.dart';
import 'package:book_user_app/features/wishlist/presentation/pages/wishlist_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static const String home = '/home';
  static const String wishlist = '/wishlist';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String chat = '/chat';
  static const String createListingPhotos = '/create-listing/photos';
  static const String createListingDetails = '/create-listing/details';
  static const String createListingPrice = '/create-listing/price';
  static const String listingDetail = 'listing_detail';
  static const String offerDetail = '/offer';

  /// Routes that must stay reachable while signed out (deep links, onboarding).
  /// Keep in sync with [router] public auth routes.
  static bool isPublicRouteWhenUnauthenticated(String path) {
    if (path == '/' ||
        path == '/onboarding' ||
        path == '/login' ||
        path == '/register' ||
        path == '/forgot-password') {
      return true;
    }
    if (path.startsWith('/reset-password/')) return true;
    return false;
  }

  static final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final location = state.uri.path;
      const publicRoutes = {
        '/',
        '/onboarding',
        '/login',
        '/register',
        '/forgot-password',
        '/verify-email',
      };
      final isResetPasswordRoute = location.startsWith('/reset-password/');

      // Global guard: authenticated-but-unverified users are blocked
      // from all feature routes until email verification is complete.
      if (authState is AuthAuthenticated &&
          !authState.user.isVerified &&
          !publicRoutes.contains(location) &&
          !isResetPasswordRoute) {
        return '/verify-email';
      }

      // Handle deep links with custom URL scheme (campushub://)
      final uri = state.uri;
      debugPrint('🔗 GoRouter redirect - uri: $uri, path: ${uri.path}');

      // Check if this is a deep link with custom scheme
      if (uri.scheme == 'campushub') {
        // Extract the path from the deep link
        final path = uri.path.isEmpty ? '/${uri.host}${uri.path}' : uri.path;
        debugPrint('🔗 Deep link detected, redirecting to: $path');

        // For campushub://reset-password/token, host is "reset-password" and path has the token
        if (uri.host == 'reset-password') {
          final token = uri.path.replaceFirst('/', '');
          return '/reset-password/$token';
        }

        return path;
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-password/:token',
        name: 'reset-password',
        builder: (context, state) {
          final token = state.pathParameters['token'] ?? '';
          return ResetPasswordPage(token: token);
        },
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        builder: (context, state) {
          final justRegistered = state.extra as bool? ?? false;
          return VerifyEmailPage(justRegistered: justRegistered);
        },
      ),
      GoRoute(
        path: '/wishlist',
        name: 'wishlist',
        builder: (context, state) => const WishlistPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/change-password',
        name: 'change-password',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/blocked-users',
        name: 'blocked-users',
        builder: (context, state) => const BlockedUsersPage(),
      ),
      GoRoute(
        path: '/see-all/:type',
        name: 'see-all',
        builder: (context, state) {
          final typeStr = state.pathParameters['type'] ?? 'latest';
          final type = SeeAllType.values.firstWhere(
            (e) => e.name == typeStr,
            orElse: () => SeeAllType.latest,
          );
          return SeeAllListingsPage(type: type);
        },
      ),
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => BlocProvider.value(
          value: sl<CategoriesBloc>(),
          child: const CategoryHubPage(),
        ),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) {
          final initialTab = state.extra as int? ?? 0;
          return ProfilePage(initialTabIndex: initialTab);
        },
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'edit_profile',
        builder: (context, state) {
          final user = state.extra as User;
          return EditProfilePage(user: user);
        },
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const MessagesPage(),
        routes: [
          GoRoute(
            path: 'detail/:conversationId',
            name: 'chat_detail',
            builder: (context, state) {
              final conversationId =
                  state.pathParameters['conversationId'] ?? '';
              final queryParams = state.uri.queryParameters;
              final listingPrice = double.tryParse(
                queryParams['listingPrice'] ?? '',
              );

              return ChatPage(
                conversationId: conversationId,
                otherUserName: queryParams['name'],
                otherUserAvatar: queryParams['avatar'],
                otherUserId: queryParams['userId'],
                listingId: queryParams['listingId'],
                listingTitle: queryParams['listingTitle'],
                listingImage: queryParams['listingImage'],
                listingPrice: listingPrice,
                sellerId: queryParams['sellerId'],
                currentUserId: queryParams['currentUserId'],
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/profile/public/:id',
        name: 'public_profile',
        builder: (context, state) {
          final userId = state.pathParameters['id'] ?? '';
          return UserProfilePage(userId: userId);
        },
      ),
      GoRoute(
        path: '/seller/:id',
        name: 'seller_profile',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final extra = state.extra as Listing?;
          return SellerProfileRoutePage(
            sellerId: id,
            extraListing: extra,
          );
        },
      ),
      // Create Listing Routes
      // Create Listing Routes
      GoRoute(
        path: '/create-listing/photos',
        name: 'create_listing_photos',
        builder: (context, state) => const CreateListingPhotosPage(),
      ),
      GoRoute(
        path: '/create-listing/details',
        name: 'create_listing_details',
        builder: (context, state) => BlocProvider.value(
          value: sl<CategoriesBloc>(),
          child: const CreateListingDetailsPage(),
        ),
      ),
      GoRoute(
        path: '/create-listing/price',
        name: 'create_listing_price',
        builder: (context, state) => const CreateListingPricePage(),
      ),
      GoRoute(
        path: '/listing/:id',
        name: 'listing_detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ListingDetailPage(listingId: id);
        },
        routes: [
          GoRoute(
            path: 'edit',
            name: 'edit_listing',
            builder: (context, state) {
              final listing = state.extra as Listing;
              return EditListingPage(listing: listing);
            },
          ),
          GoRoute(
            path: 'promote',
            name: 'promote_listing',
            builder: (context, state) {
              final listing = state.extra as Listing;
              return BlocProvider(
                create: (_) => sl<ListingsBloc>(),
                child: PromoteListingPage(listing: listing),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => BlocProvider.value(
          value: sl<NotificationsBloc>(),
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: '/offer/:offerId',
        name: 'offer_detail',
        builder: (context, state) {
          final offerId = state.pathParameters['offerId'] ?? '';
          return BlocProvider(
            create: (_) => sl<OfferBloc>(),
            child: OfferRequestPage(offerId: offerId),
          );
        },
      ),
      GoRoute(
        path: '/write-review',
        name: 'write_review',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BlocProvider(
            create: (_) => sl<ReviewsBloc>(),
            child: WriteReviewPage(
              sellerId: extra['sellerId'] as String,
              sellerName: extra['sellerName'] as String,
              sellerAvatar: extra['sellerAvatar'] as String?,
              listingId: extra['listingId'] as String?,
              listingTitle: extra['listingTitle'] as String?,
            ),
          );
        },
      ),
    ],
  );
}
