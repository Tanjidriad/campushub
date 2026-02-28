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
import 'package:iconsax/iconsax.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validation
    if (name.isEmpty) {
      AppSnackBar.showWarning(context, 'Please enter your full name');
      return;
    }
    if (email.isEmpty) {
      AppSnackBar.showWarning(context, 'Please enter your email address');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      AppSnackBar.showWarning(context, 'Please enter a valid email address');
      return;
    }
    if (password.isEmpty) {
      AppSnackBar.showWarning(context, 'Please create a password');
      return;
    }
    if (password.length < 6) {
      AppSnackBar.showWarning(
        context,
        'Password must be at least 6 characters',
      );
      return;
    }
    if (password != confirmPassword) {
      AppSnackBar.showWarning(context, 'Passwords do not match');
      return;
    }

    // Dispatch registration event
    context.read<AuthBloc>().add(
      AuthRegisterRequested(email: email, password: password, name: name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegistrationSuccess) {
          AppSnackBar.showSuccess(
            context,
            'Account created! Please verify your email.',
          );
          context.go('/verify-email', extra: true);
        } else if (state is AuthError) {
          AppSnackBar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppPalette.background,
        body: Stack(
          children: [
            // Background Image with Overlay
            Positioned.fill(
              bottom: MediaQuery.of(context).size.height * 0.65,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
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
                        AppPalette.primary.withOpacity(0.4),
                        AppPalette.background,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Logo Overlay on Image
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
                          color: AppPalette.primary,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        "CampusHub Pro",
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
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
                      "Join the exclusive student marketplace.",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.95),
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
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

            // Main Content Card (Scrollable)
            Positioned.fill(
              top: 220.h,
              child: Container(
                decoration: BoxDecoration(
                  color: AppPalette.background,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 32.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Student Registration",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppPalette.textPrimary,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Inputs
                      _buildLabel("Full Name"),
                      AuthTextField(
                        controller: _nameController,
                        hintText: "Enter your full name",
                        prefixIcon: Iconsax.user,
                        keyboardType: TextInputType.name,
                      ),

                      SizedBox(height: 16.h),

                      _buildLabel("Email Address"),
                      AuthTextField(
                        controller: _emailController,
                        hintText: "Enter your student email",
                        prefixIcon: Iconsax.sms,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      SizedBox(height: 16.h),

                      _buildLabel("Password"),
                      AuthTextField(
                        controller: _passwordController,
                        hintText: "Create a password",
                        prefixIcon: Iconsax.lock,
                        isObscure: _obscurePassword,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          child: Icon(
                            _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                            color: AppPalette.textSecondary,
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      _buildLabel("Confirm Password"),
                      AuthTextField(
                        controller: _confirmPasswordController,
                        hintText: "Confirm your password",
                        prefixIcon: Iconsax.lock,
                        isObscure: _obscureConfirmPassword,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                          child: Icon(
                            _obscureConfirmPassword
                                ? Iconsax.eye_slash
                                : Iconsax.eye,
                            color: AppPalette.textSecondary,
                          ),
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Sign Up Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthRegisterLoading;
                          return ElevatedButton(
                            onPressed: isLoading ? null : _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 56.h),
                              backgroundColor: AppPalette.primary,
                              elevation: 4,
                              shadowColor: AppPalette.primary.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: 24.h,
                                    width: 24.h,
                                    child: const AppLoaderSmall(),
                                  )
                                : Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          );
                        },
                      ),

                      SizedBox(height: 24.h),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: AppPalette.textSecondary,
                              fontSize: 14.sp,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.pop();
                            },
                            child: Text(
                              "Log In",
                              style: TextStyle(
                                color: AppPalette.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppPalette.textPrimary,
        ),
      ),
    );
  }
}
