import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_snackbar.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:book_user_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:book_user_app/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:iconsax/iconsax.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;

  const ResetPasswordPage({super.key, required this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final l10n = AppLocalizations.of(context)!;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty) {
      AppSnackBar.showWarning(context, l10n.newPasswordRequired);
      return;
    }
    if (password.length < 6) {
      AppSnackBar.showWarning(context, l10n.passwordMinLength);
      return;
    }
    if (password != confirmPassword) {
      AppSnackBar.showWarning(context, l10n.passwordsDoNotMatch);
      return;
    }

    context.read<AuthBloc>().add(
      AuthResetPasswordRequested(token: widget.token, newPassword: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthResetPasswordSuccess) {
          AppSnackBar.showSuccess(context, l10n.passwordResetSuccess);
          context.go('/login');
        } else if (state is AuthError) {
          AppSnackBar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.of(context).background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.of(context).textPrimary,
            ),
            onPressed: () => context.go('/login'),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Text(
                l10n.resetPasswordTitle,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                l10n.resetPasswordDescription,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.of(context).textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),
              _buildLabel(l10n.newPasswordLabel),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthResetPasswordLoading;
                  return AuthTextField(
                    controller: _passwordController,
                    hintText: l10n.enterNewPasswordHint,
                    prefixIcon: Iconsax.lock,
                    isObscure: _obscurePassword,
                    enabled: !isLoading,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                        color: AppColors.of(context).textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 16.h),
              _buildLabel(l10n.confirmPassword),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthResetPasswordLoading;
                  return AuthTextField(
                    controller: _confirmPasswordController,
                    hintText: l10n.confirmNewPasswordHint,
                    prefixIcon: Iconsax.lock,
                    isObscure: _obscureConfirmPassword,
                    enabled: !isLoading,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Iconsax.eye_slash
                            : Iconsax.eye,
                        color: AppColors.of(context).textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 32.h),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthResetPasswordLoading;
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.of(context).primary,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 24.h,
                              child: const AppLoaderSmall(),
                            )
                          : Text(
                              l10n.resetPasswordButton,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.of(context).onPrimary,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.of(context).textPrimary,
        ),
      ),
    );
  }
}
