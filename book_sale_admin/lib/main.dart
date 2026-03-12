import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'core/theme/theme_bloc.dart';
import 'injection_container.dart' as di;

// Feature imports
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const AdminApp());
}

class AdminApp extends StatefulWidget {
  const AdminApp({super.key});

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = di.sl<AuthBloc>()..add(CheckAuthEvent());
    _router = createRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeBloc()..add(LoadThemeEvent())),
        BlocProvider.value(value: _authBloc),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) => BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                // When we become unauthenticated, go to login
                if (state is Unauthenticated || state is AuthError) {
                  _router.go(AppRoutes.login);
                }
              },
              child: MaterialApp.router(
                title: 'CampusHub Admin',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,
                routerConfig: _router,
              ),
            ),
          );
        },
      ),
    );
  }
}
