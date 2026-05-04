import 'package:book_user_app/config/routes/app_router.dart';
import 'package:book_user_app/config/theme/app_theme.dart';
import 'package:book_user_app/core/locale/locale_cubit.dart';
import 'package:book_user_app/core/theme/display_preferences_cubit.dart';
import 'package:book_user_app/core/theme/theme_cubit.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:book_user_app/features/create_listing/presentation/bloc/create_listing_bloc.dart';
import 'package:book_user_app/features/chat/presentation/bloc/conversations_bloc.dart';
import 'package:book_user_app/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:book_user_app/core/services/fcm_service.dart';
import 'package:book_user_app/core/services/socket_service.dart';
import 'package:book_user_app/core/services/education_config_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:book_user_app/l10n/app_localizations.dart';

import 'dart:async';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Catch Flutter framework errors
      FlutterError.onError = (details) {
        debugPrint('🔴 FlutterError: ${details.exception}');
        debugPrint('🔴 Stack: ${details.stack}');
      };

      // Initialize Firebase
      await Firebase.initializeApp();

      // Set background message handler (must be top-level function)
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await initDependencies();

      // Initialize FCM service and setup notification tap navigation
      final fcmService = sl<FCMService>();
      await fcmService.initialize();
      fcmService.onNotificationTap = (conversationId, extras) {
        final uri = Uri(
          path: '/chat/detail/$conversationId',
          queryParameters: {
            if (extras['name']?.isNotEmpty == true) 'name': extras['name']!,
            if (extras['avatar']?.isNotEmpty == true) 'avatar': extras['avatar']!,
            if (extras['userId']?.isNotEmpty == true) 'userId': extras['userId']!,
            if (extras['listingId']?.isNotEmpty == true) 'listingId': extras['listingId']!,
            if (extras['listingTitle']?.isNotEmpty == true) 'listingTitle': extras['listingTitle']!,
            if (extras['listingImage']?.isNotEmpty == true) 'listingImage': extras['listingImage']!,
            if (extras['listingPrice']?.isNotEmpty == true) 'listingPrice': extras['listingPrice']!,
            if (extras['sellerId']?.isNotEmpty == true) 'sellerId': extras['sellerId']!,
          },
        );
        AppRouter.router.go(uri.toString());
      };
      // Pre-fetch education config for dynamic filter/form data
      EducationConfigService().fetchConfig();

      runApp(const MyApp());
    },
    (error, stackTrace) {
      // This catches ALL unhandled async errors — print them instead of crashing
      debugPrint('');
      debugPrint('🔴🔴🔴 UNCAUGHT ASYNC ERROR 🔴🔴🔴');
      debugPrint('🔴 Error: $error');
      debugPrint('🔴 Type: ${error.runtimeType}');
      debugPrint('🔴 Stack: $stackTrace');
      debugPrint('🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴');
      debugPrint('');
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// When the app comes back from background, reconnect the socket if it dropped.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SocketService().reconnectIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => DisplayPreferencesCubit()),
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(
          create: (context) => sl<AuthBloc>()..add(const AuthCheckRequested()),
          lazy: false,
        ),
        BlocProvider(create: (context) => sl<CreateListingBloc>()),

        // ConversationsBloc lives at the root so it can receive
        // message:notification events regardless of which screen is open.
        BlocProvider(create: (context) => sl<ConversationsBloc>(), lazy: false),

        // NotificationsBloc at root so badge count stays in sync everywhere
        BlocProvider.value(value: sl<NotificationsBloc>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                if (!state.user.isVerified) {
                  SocketService().disconnect();
                  if (AppRouter.router.state.uri.path != '/verify-email') {
                    AppRouter.router.go('/verify-email');
                  }
                  return;
                }
                // User just logged in (or app restored an existing session).
                // Connect socket and start listening for notifications so
                // ConversationsBloc gets updates on ANY screen.
                SocketService()
                    .connect()
                    .then((_) {
                      if (context.mounted) {
                        context.read<ConversationsBloc>().add(
                          const StartConversationsListening(),
                        );
                      }
                    })
                    .catchError((e) {
                      debugPrint('⚠️ Socket connect error (non-fatal): $e');
                    });

                final path = AppRouter.router.state.uri.path;
                if (path == '/login' || path == '/register' || path == '/verify-email') {
                  AppRouter.router.go('/home');
                }
              } else if (state is AuthUnauthenticated) {
                // Clean up on logout
                SocketService().disconnect();
                final path = AppRouter.router.state.uri.path;
                if (!AppRouter.isPublicRouteWhenUnauthenticated(path)) {
                  AppRouter.router.go('/login');
                }
              }
            },
            child: BlocBuilder<DisplayPreferencesCubit, bool>(
              builder: (context, oledBlack) {
                return BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) {
                    return BlocBuilder<LocaleCubit, Locale?>(
                      builder: (context, locale) {
                        return MaterialApp.router(
                          title: 'CampusHub Pro',
                          theme: AppTheme.lightTheme,
                          darkTheme: oledBlack
                              ? AppTheme.darkThemeOled
                              : AppTheme.darkTheme,
                          themeMode: themeMode,
                          locale: locale,
                          debugShowCheckedModeBanner: false,
                          localizationsDelegates:
                              AppLocalizations.localizationsDelegates,
                          supportedLocales: AppLocalizations.supportedLocales,
                          builder: (context, child) => HeroControllerScope.none(
                            child: child ?? const SizedBox.shrink(),
                          ),
                          routerConfig: AppRouter.router,
                        );
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
