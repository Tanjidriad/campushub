import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animCtl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtl, curve: Curves.easeOutCubic));
    _animCtl.forward();
  }

  void _login() {
    if (_emailCtl.text.isEmpty || _passwordCtl.text.isEmpty) return;
    context.read<AuthBloc>().add(
      LoginEvent(email: _emailCtl.text.trim(), password: _passwordCtl.text),
    );
  }

  @override
  void dispose() {
    _animCtl.dispose();
    _emailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0C1015),
                      const Color(0xFF0F1A1D),
                      const Color(0xFF0C1015),
                    ]
                  : [
                      const Color(0xFFE6FAF7),
                      const Color(0xFFF0FDFB),
                      const Color(0xFFF8FAFB),
                    ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -80,
                right: -60,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withOpacity(isDark ? 0.12 : 0.1),
                        AppColors.primary.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -80,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withOpacity(isDark ? 0.08 : 0.06),
                        AppColors.accent.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ── Logo ──
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: AppColors.primaryGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.35),
                                    blurRadius: 28,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              'CampusHub',
                              style: AppTextStyles.h1.copyWith(
                                color: context.textPrimary,
                                letterSpacing: -1.0,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(
                                  isDark ? 0.15 : 0.1,
                                ),
                                borderRadius: AppRadius.full,
                              ),
                              child: Text(
                                'ADMIN PANEL',
                                style: AppTextStyles.overline.copyWith(
                                  color: AppColors.primary,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Sign in to manage your campus marketplace',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: context.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 36.h),

                            // ── Glass Card ──
                            Container(
                              padding: EdgeInsets.all(24.w),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.cardDark.withOpacity(0.7)
                                    : Colors.white.withOpacity(0.85),
                                borderRadius: AppRadius.xl,
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.cardBorderDark.withOpacity(
                                          0.5,
                                        )
                                      : AppColors.cardBorderLight.withOpacity(
                                          0.6,
                                        ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      isDark ? 0.2 : 0.06,
                                    ),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      isDark ? 0.1 : 0.02,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Email
                                  Text(
                                    'Email',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: context.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  TextField(
                                    controller: _emailCtl,
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(
                                      color: context.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'admin@campushub.com',
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: context.textMuted,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20.h),

                                  // Password
                                  Text(
                                    'Password',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: context.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  TextField(
                                    controller: _passwordCtl,
                                    obscureText: _obscurePassword,
                                    style: TextStyle(
                                      color: context.textPrimary,
                                    ),
                                    onSubmitted: (_) => _login(),
                                    decoration: InputDecoration(
                                      hintText: '••••••••',
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: context.textMuted,
                                        size: 20,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: context.textMuted,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),

                                  // Error inline
                                  BlocBuilder<AuthBloc, AuthState>(
                                    builder: (context, state) {
                                      if (state is AuthError) {
                                        return Padding(
                                          padding: EdgeInsets.only(top: 12.h),
                                          child: Container(
                                            padding: EdgeInsets.all(12.w),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? AppColors.error.withOpacity(
                                                      0.1,
                                                    )
                                                  : AppColors.errorLight,
                                              borderRadius: AppRadius.sm,
                                              border: Border.all(
                                                color: AppColors.error
                                                    .withOpacity(0.2),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.error_outline,
                                                  color: AppColors.error,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 8.w),
                                                Expanded(
                                                  child: Text(
                                                    state.message,
                                                    style: AppTextStyles
                                                        .bodySmall
                                                        .copyWith(
                                                          color:
                                                              AppColors.error,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),

                                  SizedBox(height: 24.h),

                                  // Gradient login button
                                  BlocBuilder<AuthBloc, AuthState>(
                                    builder: (context, state) {
                                      final isLoading = state is AuthLoading;
                                      return SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: AppColors.primaryGradient,
                                            ),
                                            borderRadius: AppRadius.md,
                                            boxShadow: isLoading
                                                ? []
                                                : AppShadows.primaryGlow(0.3),
                                          ),
                                          child: ElevatedButton(
                                            onPressed: isLoading
                                                ? null
                                                : _login,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: AppRadius.md,
                                              ),
                                              elevation: 0,
                                            ),
                                            child: isLoading
                                                ? const SizedBox(
                                                    width: 22,
                                                    height: 22,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2.5,
                                                          color: Colors.white,
                                                        ),
                                                  )
                                                : Text(
                                                    'Sign In',
                                                    style: AppTextStyles
                                                        .labelLarge
                                                        .copyWith(
                                                          color: Colors.white,
                                                        ),
                                                  ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 28.h),
                            Text(
                              'CampusHub Admin Panel v1.0',
                              style: AppTextStyles.caption.copyWith(
                                color: context.textMuted.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
