import 'dart:ui';
import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_cached_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileHeader extends StatelessWidget {
  final String? avatarUrl;

  const ProfileHeader({super.key, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover Photo Area (Blurred)
        Container(
          height: 150.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.border,
            image: avatarUrl != null && avatarUrl!.isNotEmpty
                ? DecorationImage(
                    image: CachedNetworkImageProvider(avatarUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: colors.isDark
                    ? colors.textPrimary.withOpacity(0.5)
                    : colors.onPrimary.withOpacity(0.2),
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
              color: colors.card,
              border: Border.all(color: colors.border, width: 4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.r),
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? AppCachedImage(
                      imageUrl: avatarUrl,
                      fit: BoxFit.cover,
                      errorWidget: Icon(
                        Icons.person,
                        size: 40.sp,
                        color: colors.textSecondary,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 40.sp,
                      color: colors.textSecondary,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
