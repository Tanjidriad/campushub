import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum MessageType { text, location, image }

class MessageBubble extends StatelessWidget {
  final bool isMe;
  final String message;
  final String time;
  final String status;
  final String? avatarUrl;
  final MessageType type;
  final String? locationImageUrl;

  const MessageBubble({
    super.key,
    required this.isMe,
    required this.message,
    required this.time,
    this.status = '',
    this.avatarUrl,
    this.type = MessageType.text,
    this.locationImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (isMe) {
      return _buildOutgoingMessage(context);
    } else {
      return _buildIncomingMessage(context);
    }
  }

  Widget _buildIncomingMessage(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (avatarUrl != null &&
            avatarUrl!.isNotEmpty &&
            avatarUrl!.startsWith('http'))
          CircleAvatar(
            radius: 16.r,
            backgroundImage: CachedNetworkImageProvider(avatarUrl!),
            backgroundColor: AppColors.of(context).border,
          )
        else if (avatarUrl != null)
          CircleAvatar(
            radius: 16.r,
            backgroundColor: AppColors.of(context).border,
            child: Icon(
              Icons.person,
              size: 16.sp,
              color: AppColors.of(context).textSecondary,
            ),
          ),
        SizedBox(width: 8.w),
        Container(
          constraints: BoxConstraints(maxWidth: 0.7.sw),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.of(context).chatBubbleIncoming,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(2.r),
            ),
            border: Border.all(color: AppColors.of(context).subtleFill),
            boxShadow: [
              BoxShadow(
                color: AppColors.of(context).textPrimary.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.of(context).textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutgoingMessage(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: 0.7.sw),
              padding: type == MessageType.location
                  ? const EdgeInsets.all(4)
                  : EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.of(context).chatBubbleOutgoing,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(2.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.of(context).textPrimary.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: type == MessageType.location
                  ? _buildLocationContent(context)
                  : Text(
                      message,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.of(context).onPrimary,
                      ),
                    ),
            ),
            SizedBox(height: 4.h),
            Text(
              status.isNotEmpty ? status : time,
              style: TextStyle(
                color: AppColors.of(context).textLight,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
        SizedBox(width: 8.w),
        if (avatarUrl != null &&
            avatarUrl!.isNotEmpty &&
            avatarUrl!.startsWith('http'))
          CircleAvatar(
            radius: 16.r,
            backgroundImage: CachedNetworkImageProvider(avatarUrl!),
            backgroundColor: AppColors.of(context).border,
          )
        else if (avatarUrl != null)
          CircleAvatar(
            radius: 16.r,
            backgroundColor: AppColors.of(context).border,
            child: Icon(
              Icons.person,
              size: 16.sp,
              color: AppColors.of(context).textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _buildLocationContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (locationImageUrl != null &&
            locationImageUrl!.isNotEmpty &&
            locationImageUrl!.startsWith('http'))
          Container(
            height: 120.h,
            width: 200.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              image: DecorationImage(
                image: CachedNetworkImageProvider(locationImageUrl!),
                fit: BoxFit.cover,
              ),
            ),
          )
        else
          Container(
            height: 120.h,
            width: 200.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.of(context).border,
            ),
            child: Icon(
              Icons.location_off,
              size: 40.sp,
              color: AppColors.of(context).textSecondary,
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.of(context).onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
