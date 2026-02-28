import 'dart:ui';
import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileHeader extends StatelessWidget {
  final String? avatarUrl;
  final bool isDark;

  const ProfileHeader({
    super.key,
    required this.avatarUrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover Photo Area (Blurred)
        Container(
          height: 150.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppPalette.gray800 : const Color(0xFFE0E0E0),
            image: avatarUrl != null && avatarUrl!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(avatarUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: isDark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white.withOpacity(0.2),
              ),
            ),
          ),
        ),

        // Square Avatar Overlap
        Positioned(
          bottom: -82.h,
          left: 20.w,
          child: Container(
            width: 112.w,
            height: 112.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.r),
              color: isDark ? AppPalette.gray800 : Colors.white,
              border: Border.all(
                color: isDark ? AppPalette.gray900 : const Color(0xFFF1F1F1),
                width: 4,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.r),
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.person, size: 40.sp, color: Colors.grey),
                    )
                  : Icon(Icons.person, size: 40.sp, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
