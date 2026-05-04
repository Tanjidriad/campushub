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
import 'package:book_user_app/l10n/app_localizations.dart';
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
  Timer? _cooldownTimer;
  bool _isChecking = false;
  int _cooldownSeconds = 0;

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
    _cooldownTimer?.cancel();
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

  void _startCooldown() {
    setState(() => _cooldownSeconds = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _cooldownSeconds--;
        if (_cooldownSeconds <= 0) {
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.isVerified) {
            _stopPolling();
            // Show dynamic success and redirect
            AppSnackBar.showSuccess(context, l10n.emailVerifiedSuccess);
            context.go('/home');
          }
        } else if (state is AuthResendVerificationSuccess) {
          AppSnackBar.showSuccess(context, l10n.verificationEmailSent);
          _startCooldown();
        } else if (state is AuthError) {
          // Don't show error for polling checks unless specifically requested
          // But for resend, we might want to show error
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.of(context).background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.verify,
                  size: 80.sp,
                  color: AppColors.of(context).primary,
                ),
                SizedBox(height: 24.h),
                Text(
                  l10n.verifyYourEmail,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.of(context).textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  l10n.verifyEmailDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.of(context).textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 48.h),

                // Resend Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isOnCooldown = _cooldownSeconds > 0;
                    return TextButton.icon(
                      onPressed: isOnCooldown ? null : _handleResendEmail,
                      icon: const Icon(Iconsax.refresh),
                      label: Text(
                        isOnCooldown
                            ? "Resend in ${_cooldownSeconds}s"
                            : l10n.resendEmail,
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.of(context).primary,
                        disabledForegroundColor: AppColors.of(
                          context,
                        ).textSecondary,
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
                    side: BorderSide(color: AppColors.of(context).primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 16.h,
                    ),
                  ),
                  child: Text(
                    l10n.verifiedMyEmail,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.of(context).primary,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                  },
                  child: Text(
                    l10n.backToLogin,
                    style: TextStyle(
                      color: AppColors.of(context).textSecondary,
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
