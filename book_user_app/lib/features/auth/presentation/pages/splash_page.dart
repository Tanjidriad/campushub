import 'package:book_user_app/core/constants/api_constants.dart';
import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:book_user_app/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _secureStorage = const FlutterSecureStorage();
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Check auth status when splash loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(const AuthCheckRequested());
    });
  }

  void _handleAuthState(AuthState state) async {
    if (!mounted || _navigated) return;

    // Only handle final states, not loading
    if (state is AuthLoading) return;

    _navigated = true;

    if (state is AuthAuthenticated) {
      if (state.user.isVerified) {
        context.go('/home');
      } else {
        context.go('/verify-email');
      }
    } else {
      // Not logged in - check onboarding
      final hasSeenOnboarding = await _secureStorage.read(
        key: StorageKeys.hasSeenOnboarding,
      );

      if (!mounted) return;

      if (hasSeenOnboarding == 'true') {
        context.go('/login');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        _handleAuthState(state);
      },
      child: Scaffold(
        backgroundColor: AppColors.of(context).primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school,
                size: 100.sp,
                color: AppColors.of(context).onPrimary,
              ),
              SizedBox(height: 20.h),
              Text(
                l10n.appName,
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).onPrimary,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                l10n.forStudentsOnly,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.of(context).onPrimary.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 40.h),
              AppLoader(color: AppColors.of(context).onPrimary, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
