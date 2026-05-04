import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable standard section wrap for the Premium Dashboard.
/// Implements CodeCanyon-level typography and consistent vertical rhythms.
class DashboardSectionContainer extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final Widget child;
  final bool compactPadding;

  const DashboardSectionContainer({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
    required this.child,
    this.compactPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: colors.textPrimary,
                    ) ??
                    TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      letterSpacing: -0.5,
                    ),
              ),
              if (actionLabel != null && onActionTap != null)
                GestureDetector(
                  onTap: onActionTap,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 2.h, left: 16.w, top: 4.h),
                    child: Text(
                      actionLabel!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.primary, // Using primary color for modern call-to-actions
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: compactPadding ? 8.h : 12.h),
        child,
        SizedBox(height: 24.h), // Consistent space before the next section
      ],
    );
  }
}
