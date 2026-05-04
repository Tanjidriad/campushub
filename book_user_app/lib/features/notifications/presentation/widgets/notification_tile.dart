import 'package:flutter/material.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final style = _getNotificationStyle(context, notification.type);
    final isRead = notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.of(context).error,
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(
          Iconsax.trash,
          color: AppColors.of(context).onPrimary,
          size: 24.sp,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 2.w),
          decoration: BoxDecoration(
            color: AppColors.of(context).card,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.of(context).textPrimary.withOpacity(0.05),
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
                                      color: AppColors.of(context).card,
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
                                      _getTitle(l10n, notification.type) ??
                                          notification.title,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: isRead
                                            ? AppColors.of(
                                                context,
                                              ).textSecondary
                                            : AppColors.of(context).textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    _getTimeAgo(
                                      context,
                                      notification.createdAt,
                                    ),
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.of(
                                        context,
                                      ).textSecondary,
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
                                      ? AppColors.of(
                                          context,
                                        ).textSecondary.withOpacity(0.8)
                                      : AppColors.of(context).textSecondary,
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
                                        l10n.viewDetails,
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

  String _getTimeAgo(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d').format(dateTime);
    } else if (difference.inDays > 1) {
      return l10n.daysAgo(difference.inDays);
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inHours > 0) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return l10n.minutesAgo(difference.inMinutes);
    } else {
      return l10n.justNow;
    }
  }

  String? _getTitle(AppLocalizations l10n, String type) {
    switch (type) {
      case 'listing_approved':
        return l10n.listingApproved;
      case 'listing_rejected':
        return l10n.listingRejected;
      case 'price_drop':
        return l10n.priceDropAlert;
      case 'account_warning':
        return l10n.accountWarning;
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

  _NotificationStyle _getNotificationStyle(BuildContext context, String type) {
    switch (type) {
      case 'listing_approved':
        return _NotificationStyle(
          AppColors.of(context).primary,
          Iconsax.verify5,
        );
      case 'listing_rejected':
        return _NotificationStyle(
          AppColors.of(context).error,
          Iconsax.close_circle5,
        );
      case 'listing_expired':
        return _NotificationStyle(
          AppColors.of(context).warning,
          Iconsax.timer_15,
        );
      case 'price_drop':
        return _NotificationStyle(
          AppColors.of(context).accent,
          Iconsax.discount_shape5,
        );
      case 'wishlist_sold':
        return _NotificationStyle(
          AppColors.of(context).warning,
          Iconsax.heart_slash5,
        );
      case 'account_warning':
        return _NotificationStyle(
          AppColors.of(context).error,
          Iconsax.warning_25,
        );
      case 'new_review':
        return _NotificationStyle(AppColors.of(context).warning, Iconsax.star1);
      case 'system':
      default:
        return _NotificationStyle(
          AppColors.of(context).textSecondary,
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
