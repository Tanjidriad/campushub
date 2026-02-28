import 'package:book_user_app/core/theme/app_palette.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppPalette.background,
      padding: EdgeInsets.fromLTRB(16.w, 45.h, 16.w, 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo placeholder imitating the AD red intertwined logo
          Row(
            children: [
              Text(
                "a",
                style: TextStyle(
                  color: AppPalette.primary,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                ),
              ),
              Text(
                "D",
                style: TextStyle(
                  color: AppPalette.primary,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Notification Badge
              BlocBuilder<NotificationsBloc, NotificationsState>(
                builder: (context, state) {
                  return GestureDetector(
                    onTap: () {
                      context.pushNamed('notifications');
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: const BoxDecoration(
                            color: Colors.transparent, // Removed grey circle
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Iconsax.notification,
                            color: Colors.grey[800], // Matched hamburger color
                            size: 28.sp, // Slightly larger to match mockup
                          ),
                        ),
                        if (state.unreadCount > 0)
                          Positioned(
                            right: 4.w, // Adjusted position
                            top: 4.w,
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16.w,
                                minHeight: 16.w,
                              ),
                              child: Center(
                                child: Text(
                                  '${state.unreadCount}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(width: 16.w),
              // Hamburger menu
              GestureDetector(
                onTap: onMenuTap,
                child: Icon(
                  Icons.menu_rounded,
                  color: Colors.grey[800],
                  size: 32.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
