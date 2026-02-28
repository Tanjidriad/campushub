import 'dart:async';
import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_snackbar.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class VerifyEmailPage extends StatefulWidget {
  final bool justRegistered;
  const VerifyEmailPage({super.key, this.justRegistered = false});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage>
    with WidgetsBindingObserver {
  Timer? _verificationCheckTimer;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Always start polling to detect verification
    _startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // User came back to app (e.g., from email/browser)
      // Add small delay to ensure proper state update
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _checkVerificationStatus();
        }
      });
    }
  }

  void _startPolling() {
    _stopPolling();
    // Check every 3 seconds for faster response
    _verificationCheckTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkVerificationStatus(),
    );
  }

  void _stopPolling() {
    _verificationCheckTimer?.cancel();
    _verificationCheckTimer = null;
  }

  Future<void> _checkVerificationStatus() async {
    if (_isChecking || !mounted) return;
    _isChecking = true;

    // Refresh user data to check verification status
    context.read<AuthBloc>().add(const AuthCheckRequested());

    // Small delay before allowing another check
    await Future.delayed(const Duration(milliseconds: 500));
    _isChecking = false;
  }

  void _handleResendEmail() {
    context.read<AuthBloc>().add(const AuthResendVerificationRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.isVerified) {
            _stopPolling();
            // Show dynamic success and redirect
            AppSnackBar.showSuccess(context, 'Email verified successfully!');
            context.go('/home');
          }
        } else if (state is AuthResendVerificationSuccess) {
          AppSnackBar.showSuccess(context, 'Verification email sent!');
        } else if (state is AuthError) {
          // Don't show error for polling checks unless specifically requested
          // But for resend, we might want to show error
        }
      },
      child: Scaffold(
        backgroundColor: AppPalette.background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.verify, size: 80.sp, color: AppPalette.primary),
                SizedBox(height: 24.h),
                Text(
                  "Verify your email",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  "We've sent a verification link to your email address. Please click the link to verify your account.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppPalette.textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 48.h),

                // Resend Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    // Logic to throttle resend could be added here
                    return TextButton.icon(
                      onPressed: _handleResendEmail,
                      icon: const Icon(Iconsax.refresh),
                      label: const Text("Resend Email"),
                      style: TextButton.styleFrom(
                        foregroundColor: AppPalette.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 16.h),

                // Manual Check Button
                OutlinedButton(
                  onPressed: _checkVerificationStatus,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppPalette.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 16.h,
                    ),
                  ),
                  child: Text(
                    "I've verified my email",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.primary,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),
                TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: Text(
                    "Back to Login",
                    style: TextStyle(
                      color: AppPalette.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
