import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/notification.dart' as domain;
import '../../../../core/theme/app_palette.dart';

class NotificationTile extends StatelessWidget {
  final domain.Notification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationTile({
    Key? key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = _getNotificationStyle(notification.type);
    final isRead = notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: AppPalette.error,
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(Iconsax.trash, color: Colors.white, size: 24.sp),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 2.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Colored Left Border
                Container(
                  width: 4.w,
                  decoration: BoxDecoration(
                    color: style.color,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      bottomLeft: Radius.circular(12.r),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon / Indicator
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: style.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                style.icon,
                                color: style.color,
                                size: 24.sp,
                              ),
                            ),
                            if (!isRead)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  width: 10.w,
                                  height: 10.w,
                                  decoration: BoxDecoration(
                                    color: style.color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: style.color.withOpacity(0.4),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(width: 16.w),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _getTitle(notification.type) ??
                                          notification.title,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: isRead
                                            ? AppPalette.textSecondary
                                            : AppPalette.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    _getTimeAgo(notification.createdAt),
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppPalette.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                notification.message,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isRead
                                      ? AppPalette.textSecondary.withOpacity(
                                          0.8,
                                        )
                                      : AppPalette.textSecondary,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (!isRead && _hasAction(notification.type))
                                Padding(
                                  padding: EdgeInsets.only(top: 8.h),
                                  child: Row(
                                    children: [
                                      _buildActionButton(
                                        context,
                                        'View Details',
                                        style.color,
                                        onTap,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d').format(dateTime);
    } else if (difference.inDays > 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String? _getTitle(String type) {
    switch (type) {
      case 'listing_approved':
        return 'Listing Approved';
      case 'listing_rejected':
        return 'Listing Rejected';
      case 'price_drop':
        return 'Price Drop Alert';
      case 'account_warning':
        return 'Account Warning';
      default:
        return null; // Use original title
    }
  }

  bool _hasAction(String type) {
    switch (type) {
      case 'listing_approved':
      case 'listing_rejected':
      case 'price_drop':
        return true;
      default:
        return false;
    }
  }

  _NotificationStyle _getNotificationStyle(String type) {
    switch (type) {
      case 'listing_approved':
        return _NotificationStyle(AppPalette.primary, Iconsax.verify5);
      case 'listing_rejected':
        return _NotificationStyle(AppPalette.error, Iconsax.close_circle5);
      case 'listing_expired':
        return _NotificationStyle(AppPalette.warning, Iconsax.timer_15);
      case 'price_drop':
        return _NotificationStyle(AppPalette.accent, Iconsax.discount_shape5);
      case 'wishlist_sold':
        return _NotificationStyle(AppPalette.warning, Iconsax.heart_slash5);
      case 'account_warning':
        return _NotificationStyle(AppPalette.error, Iconsax.warning_25);
      case 'new_review':
        return _NotificationStyle(AppPalette.warning, Iconsax.star1);
      case 'system':
      default:
        return _NotificationStyle(
          AppPalette.textSecondary,
          Iconsax.info_circle5,
        );
    }
  }
}

class _NotificationStyle {
  final Color color;
  final IconData icon;

  _NotificationStyle(this.color, this.icon);
}
