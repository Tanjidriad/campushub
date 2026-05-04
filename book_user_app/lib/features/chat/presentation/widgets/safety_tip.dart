import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SafetyTip extends StatelessWidget {
  const SafetyTip({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.of(context).accent.withOpacity(0.08), // bg-blue-50
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.of(context).accent.withOpacity(0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.security,
              size: 14.sp,
              color: AppColors.of(context).accent,
            ),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                'Safety Tip: Always meet in public places like the library.',
                style: TextStyle(
                  color: AppColors.of(context).accent,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
