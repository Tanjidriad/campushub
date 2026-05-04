import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuickReplies extends StatelessWidget {
  final Function(String) onReplySelected;

  const QuickReplies({super.key, required this.onReplySelected});

  @override
  Widget build(BuildContext context) {
    final replies = [
      'Yes, still available',
      'Where to meet?',
      'Is price negotiable?',
      'I\'m here',
    ];

    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.of(context).card,
        border: Border(
          top: BorderSide(color: AppColors.of(context).subtleFill),
        ),
      ),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        scrollDirection: Axis.horizontal,
        itemCount: replies.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => onReplySelected(replies[index]),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.of(context).inputFill,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.of(context).border),
              ),
              child: Text(
                replies[index],
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.of(context).textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
