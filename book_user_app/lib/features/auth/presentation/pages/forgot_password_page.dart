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

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      AppSnackBar.showWarning(context, l10n.loginEmailRequired);
      return;
    }
    if (!_isValidEmail(email)) {
      AppSnackBar.showWarning(context, l10n.validEmailRequired);
      return;
    }

    context.read<AuthBloc>().add(AuthForgotPasswordRequested(email: email));
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthForgotPasswordSuccess) {
          AppSnackBar.showSuccess(context, l10n.resetLinkSent);
          context.pop(); // Go back to login
        } else if (state is AuthError) {
          AppSnackBar.showError(context, state.message);
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
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
              onPressed: () => context.pop(),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Text(
                  l10n.forgotPasswordTitle,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.of(context).textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  l10n.forgotPasswordDescription,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.of(context).textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h),
                _buildLabel(l10n.emailAddress),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthForgotPasswordLoading;
                    return AuthTextField(
                      controller: _emailController,
                      hintText: l10n.enterEmailHint,
                      prefixIcon: Iconsax.sms,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                    );
                  },
                ),
                SizedBox(height: 32.h),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthForgotPasswordLoading;
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
                                l10n.sendResetLink,
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
