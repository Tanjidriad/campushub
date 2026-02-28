import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileInfoHeader extends StatelessWidget {
  final String name;
  final String? username;
  final bool isVerified;
  final double rating;
  final int reviewCount;
  final bool isDark;

  const ProfileInfoHeader({
    super.key,
    required this.name,
    this.username,
    this.isVerified = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    color: isDark ? Colors.white : Colors.black,
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
                color: Colors.grey,
                fontSize: 13.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16.sp),
              SizedBox(width: 4.w),
              Text(
                '${rating.toStringAsFixed(1)} Reviews',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
