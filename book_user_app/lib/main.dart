import 'package:book_user_app/config/routes/app_router.dart';
import 'package:book_user_app/config/theme/app_theme.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:book_user_app/features/create_listing/presentation/bloc/create_listing_bloc.dart';
import 'package:book_user_app/features/chat/presentation/bloc/conversations_bloc.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:book_user_app/core/services/fcm_service.dart';
import 'package:book_user_app/core/services/socket_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        if (extras['userId']?.isNotEmpty == true) 'userId': extras['userId']!,
      },
    );
    AppRouter.router.go(uri.toString());
  };
  fcmService.onOfferNotificationTap = (offerId) {
    AppRouter.router.push('/offer/$offerId');
  };

  runApp(const MyApp());
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
        BlocProvider(
          create: (context) => sl<AuthBloc>()..add(const AuthCheckRequested()),
          lazy: false,
        ),
        BlocProvider(create: (context) => sl<CreateListingBloc>()),

        // ConversationsBloc lives at the root so it can receive
        // message:notification events regardless of which screen is open.
        BlocProvider(create: (context) => sl<ConversationsBloc>(), lazy: false),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                // User just logged in (or app restored an existing session).
                // Connect socket and start listening for notifications so
                // ConversationsBloc gets updates on ANY screen.
                SocketService().connect().then((_) {
                  if (context.mounted) {
                    context.read<ConversationsBloc>().add(
                      const StartConversationsListening(),
                    );
                  }
                });
              } else if (state is AuthUnauthenticated) {
                // Clean up on logout
                SocketService().disconnect();
              }
            },
            child: MaterialApp.router(
              title: 'CampusHub Pro',
              theme: AppTheme.lightTheme,
              debugShowCheckedModeBanner: false,
              routerConfig: AppRouter.router,
            ),
          );
        },
      ),
    );
  }
}
