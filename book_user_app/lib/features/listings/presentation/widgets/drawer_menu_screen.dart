import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class DrawerMenuScreen extends StatelessWidget {
  const DrawerMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.primary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),

              // User profile area — reads from AuthBloc
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  String userName = 'Guest';
                  String? userBio;
                  String? avatarUrl;

                  if (state is AuthAuthenticated) {
                    userName = state.user.name;
                    userBio = state.user.bio;
                    avatarUrl = state.user.avatar;
                  }

                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 28.r,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        backgroundImage:
                            avatarUrl != null && avatarUrl.isNotEmpty
                            ? CachedNetworkImageProvider(avatarUrl)
                            : null,
                        child: avatarUrl == null || avatarUrl.isEmpty
                            ? Icon(
                                Iconsax.user,
                                color: Colors.white,
                                size: 28.sp,
                              )
                            : null,
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (userBio != null && userBio.isNotEmpty) ...[
                              SizedBox(height: 2.h),
                              Text(
                                userBio,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 13.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 40.h),
              Divider(
                color: Colors.white.withValues(alpha: 0.15),
                thickness: 1,
              ),
              SizedBox(height: 16.h),

              // Menu items
              _DrawerMenuItem(
                icon: Iconsax.home_2,
                label: 'Home',
                isActive: true,
                onTap: () => ZoomDrawer.of(context)!.close(),
              ),
              _DrawerMenuItem(
                icon: Iconsax.user,
                label: 'My Profile',
                onTap: () {
                  ZoomDrawer.of(context)!.close();
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (context.mounted) context.pushNamed('profile');
                  });
                },
              ),
              _DrawerMenuItem(
                icon: Iconsax.heart,
                label: 'Wishlist',
                onTap: () {
                  ZoomDrawer.of(context)!.close();
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (context.mounted) context.pushNamed('wishlist');
                  });
                },
              ),
              _DrawerMenuItem(
                icon: Iconsax.message,
                label: 'Messages',
                onTap: () {
                  ZoomDrawer.of(context)!.close();
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (context.mounted) context.pushNamed('conversations');
                  });
                },
              ),
              _DrawerMenuItem(
                icon: Iconsax.notification,
                label: 'Notifications',
                onTap: () {
                  ZoomDrawer.of(context)!.close();
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (context.mounted) context.pushNamed('notifications');
                  });
                },
              ),
              _DrawerMenuItem(
                icon: Iconsax.setting_2,
                label: 'Settings',
                onTap: () => ZoomDrawer.of(context)!.close(),
              ),

              const Spacer(),

              // Logout
              Divider(
                color: Colors.white.withValues(alpha: 0.15),
                thickness: 1,
              ),
              SizedBox(height: 8.h),
              _DrawerMenuItem(
                icon: Iconsax.logout,
                label: 'Sign Out',
                isDestructive: true,
                onTap: () {
                  // Handle sign out
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final bool isDestructive;

  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? Colors.red[300]!
        : isActive
        ? Colors.white
        : Colors.white.withValues(alpha: 0.65);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(width: 16.w),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (isActive) ...[
              const Spacer(),
              Container(
                width: 6.w,
                height: 6.w,
                decoration: const BoxDecoration(
                  color: AppPalette.success,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
