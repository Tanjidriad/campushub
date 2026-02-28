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
      return _buildOutgoingMessage();
    } else {
      return _buildIncomingMessage();
    }
  }

  Widget _buildIncomingMessage() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (avatarUrl != null &&
            avatarUrl!.isNotEmpty &&
            avatarUrl!.startsWith('http'))
          CircleAvatar(
            radius: 16.r,
            backgroundImage: NetworkImage(avatarUrl!),
            backgroundColor: Colors.grey[300],
          )
        else if (avatarUrl != null)
          CircleAvatar(
            radius: 16.r,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, size: 16.sp, color: Colors.grey),
          ),
        SizedBox(width: 8.w),
        Container(
          constraints: BoxConstraints(maxWidth: 0.7.sw),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(2.r),
            ),
            border: Border.all(color: Colors.grey[100]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF0E141B)),
          ),
        ),
      ],
    );
  }

  Widget _buildOutgoingMessage() {
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
                color: const Color(0xFF007AFF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(2.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: type == MessageType.location
                  ? _buildLocationContent()
                  : Text(
                      message,
                      style: TextStyle(fontSize: 14.sp, color: Colors.white),
                    ),
            ),
            SizedBox(height: 4.h),
            Text(
              status.isNotEmpty ? status : time,
              style: TextStyle(color: Colors.grey[400], fontSize: 10.sp),
            ),
          ],
        ),
        SizedBox(width: 8.w),
        if (avatarUrl != null &&
            avatarUrl!.isNotEmpty &&
            avatarUrl!.startsWith('http'))
          CircleAvatar(
            radius: 16.r,
            backgroundImage: NetworkImage(avatarUrl!),
            backgroundColor: Colors.grey[300],
          )
        else if (avatarUrl != null)
          CircleAvatar(
            radius: 16.r,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, size: 16.sp, color: Colors.grey),
          ),
      ],
    );
  }

  Widget _buildLocationContent() {
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
                image: NetworkImage(locationImageUrl!),
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
              color: Colors.grey[300],
            ),
            child: Icon(Icons.location_off, size: 40.sp, color: Colors.grey),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
