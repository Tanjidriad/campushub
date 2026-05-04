import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileInfoHeader extends StatelessWidget {
  final String name;
  final String? username;
  final bool isVerified;
  final double rating;
  final int reviewCount;

  const ProfileInfoHeader({
    super.key,
    required this.name,
    this.username,
    this.isVerified = false,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        left: 135.w,
        right: 10.w,
      ), // 124 accounts for 20 left padding + 90 avatar + minimal margin
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: AppColors.of(context).textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isVerified) ...[
                SizedBox(width: 4.w),
                Icon(
                  Icons.verified,
                  color: theme.colorScheme.secondary,
                  size: 18.sp,
                ),
              ],
            ],
          ),
          if (username != null && username!.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              '@$username',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.of(context).textSecondary,
                fontSize: 13.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(
                Icons.star,
                color: AppColors.of(context).warning,
                size: 16.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                '${rating.toStringAsFixed(1)} ${l10n.reviews}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.of(context).textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
