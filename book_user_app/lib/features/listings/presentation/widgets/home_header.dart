import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:book_user_app/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:book_user_app/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class SimpleHomeHeader extends StatelessWidget {
  final VoidCallback? onMenuTap;
  const SimpleHomeHeader({super.key, this.onMenuTap});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(16.w, 50.h, 16.w, 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Iconsax.book_15,
                    color: colors.onPrimary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      final rawName = authState is AuthAuthenticated
                          ? authState.user.name
                          : null;
                      final first = rawName == null || rawName.isEmpty
                          ? null
                          : rawName.split(' ').first;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            first != null
                                ? '${_greeting()}, $first 👋'
                                : _greeting(),
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'CampusHub',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                  color: colors.textPrimary,
                                ) ??
                                TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Action Row (Notifications & Menu)
          Row(
            children: [
              BlocBuilder<NotificationsBloc, NotificationsState>(
                builder: (context, state) {
                  return Semantics(
                    label:
                        'Notifications${state.unreadCount > 0 ? ", ${state.unreadCount} unread" : ""}',
                    button: true,
                    child: GestureDetector(
                      onTap: () {
                        context.pushNamed('notifications');
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: colors.border, width: 1),
                            ),
                            child: Icon(
                              Iconsax.notification,
                              color: colors.textPrimary,
                              size: 22.sp,
                            ),
                          ),
                          if (state.unreadCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: colors.error,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colors.background,
                                    width: 2,
                                  ),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 16.w,
                                  minHeight: 16.w,
                                ),
                                child: Center(
                                  child: Text(
                                    '${state.unreadCount > 99 ? '99+' : state.unreadCount}',
                                    style: TextStyle(
                                      color: colors.onPrimary,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w800,
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
              ),
              SizedBox(width: 12.w),
              Semantics(
                label: 'Open menu',
                button: true,
                child: GestureDetector(
                  onTap: onMenuTap,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.border, width: 1),
                    ),
                    child: Icon(
                      Icons.menu_rounded,
                      color: colors.textPrimary,
                      size: 22.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
