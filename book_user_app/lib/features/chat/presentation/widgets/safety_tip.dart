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
          color: Colors.blue[50], // bg-blue-50
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.blue[100]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.security, size: 14.sp, color: Colors.blue[600]),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                'Safety Tip: Always meet in public places like the library.',
                style: TextStyle(color: Colors.blue[600], fontSize: 12.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
