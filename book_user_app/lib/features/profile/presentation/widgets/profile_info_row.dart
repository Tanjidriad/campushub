import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isDark;
  final String? iconPath;

  const ProfileInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    required this.isDark,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: isDark ? AppPalette.gray800 : AppPalette.gray100,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (iconPath != null) ...[
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: Center(
                    child: SvgPicture.asset(
                      iconPath!,
                      width: 18.w,
                      height: 18.w,
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                        isDark ? Colors.white70 : Colors.black54,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color:
                    valueColor ?? (isDark ? Colors.grey[300] : Colors.black87),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
