import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) {
    // Client-side validation with snackbar feedback
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      AppSnackBar.showWarning(context, l10n.loginEmailRequired);
      return;
    }

    if (!_isValidEmail(email)) {
      AppSnackBar.showWarning(context, l10n.validEmailRequired);
      return;
    }

    if (password.isEmpty) {
      AppSnackBar.showWarning(context, l10n.loginPasswordRequired);
      return;
    }

    if (password.length < 6) {
      AppSnackBar.showWarning(context, l10n.passwordMinLength);
      return;
    }

    // All validations passed, proceed with login
    context.read<AuthBloc>().add(
      AuthLoginRequested(email: email, password: password),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Enforce verification gate after login.
          if (state.user.isVerified) {
            context.go('/home');
          } else {
            context.go('/verify-email');
          }
        } else if (state is AuthError) {
          // Show error message with custom snackbar
          AppSnackBar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final colors = AppColors.of(context);
        final l10n = AppLocalizations.of(context)!;
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: colors.background,
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                // Background Image with Overlay
                Positioned.fill(
                  bottom: MediaQuery.of(context).size.height * 0.65,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          "https://lh3.googleusercontent.com/aida-public/AB6AXuD-X1sGDui-Fsy2ZNob62Iqn_qfk3WjZEBwjSiv4aOeqNv3HSMYosvGn6lWuO6petKotII7c40naj9tYH3on_EtIiT22XFbsKZU8cdJqbLdNvRdeL2pIjjcub4pFdgkUwI3-WmBYt9nfivIHjGg2npMYRM-YSbmhfyOLib58-SINF2oI8XUbFBT89gwjw_I041HKX7TcgnCKfmvW5pKJ9y1vlaWQ3cbL2TSy1ZQRZYQ08R1p4g8Y6XRk52vJDxluvp7a_ojEwGhRG8",
                        ),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            colors.primary.withOpacity(0.4),
                            colors.background,
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Logo Overlay
                Positioned(
                  top: 60.h,
                  left: 24.w,
                  right: 24.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.of(
                                    context,
                                  ).textPrimary.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.school_rounded,
                              color: AppColors.of(context).onPrimary,
                              size: 28.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            l10n.appName,
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.of(context).onPrimary,
                              shadows: [
                                Shadow(
                                  color: AppColors.of(
                                    context,
                                  ).textPrimary.withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Text(
                          l10n.loginSubtitle,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.of(
                              context,
                            ).onPrimary.withOpacity(0.95),
                            shadows: [
                              Shadow(
                                color: AppColors.of(
                                  context,
                                ).textPrimary.withOpacity(0.3),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content Card
                Positioned.fill(
                  top: 220.h,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.of(
                            context,
                          ).textPrimary.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 24.w,
                        right: 24.w,
                        top: 32.h,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 32.h,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.studentLogin,
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // Email Field
                            _buildLabel(l10n.email),
                            AuthTextField(
                              controller: _emailController,
                              hintText: l10n.enterEmailHint,
                              prefixIcon: Iconsax.user,
                              keyboardType: TextInputType.emailAddress,
                              enabled: state is! AuthLoginLoading,
                            ),

                            SizedBox(height: 16.h),

                            // Password Field
                            _buildLabel(l10n.password),
                            AuthTextField(
                              controller: _passwordController,
                              hintText: l10n.enterPasswordHint,
                              prefixIcon: Iconsax.lock,
                              isObscure: !_isPasswordVisible,
                              enabled: state is! AuthLoginLoading,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Iconsax.eye
                                      : Iconsax.eye_slash,
                                  color: colors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 12.h),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  context.push('/forgot-password');
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  l10n.forgotPassword,
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 24.h),

                            // Login Button
                            ElevatedButton(
                              onPressed: state is AuthLoginLoading
                                  ? null
                                  : () => _handleLogin(context),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 56.h),
                                backgroundColor: colors.primary,
                                disabledBackgroundColor: colors.primary
                                    .withOpacity(0.6),
                                elevation: 4,
                                shadowColor: colors.primary.withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: state is AuthLoginLoading
                                  ? SizedBox(
                                      height: 24.h,
                                      child: const AppLoaderSmall(),
                                    )
                                  : Text(
                                      l10n.logIn,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.of(context).onPrimary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),

                            SizedBox(height: 32.h),

                            // Register Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.noAccountPrompt,
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: state is AuthLoginLoading
                                      ? null
                                      : () {
                                          context.push('/register');
                                        },
                                  child: Text(
                                    l10n.signUp,
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                      decoration: TextDecoration.underline,
                                      decorationColor: colors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h, left: 4.w),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.of(context).textPrimary,
        ),
      ),
    );
  }
}
