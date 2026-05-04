import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_loader.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
import '../../domain/entities/notification.dart' as domain;
import '../widgets/notification_tile.dart';

typedef NotificationEntity = domain.Notification;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<NotificationsBloc>().add(
      const LoadNotifications(refresh: true),
    );
    // Also load unread count to clear it if needed
    context.read<NotificationsBloc>().add(LoadUnreadCount());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<NotificationsBloc>().state;
      if (state.hasMore && state.status != NotificationsStatus.loading) {
        context.read<NotificationsBloc>().add(
          LoadNotifications(page: state.currentPage + 1),
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9); // Load when 90% scrolled
  }

  Map<String, List<NotificationEntity>> _groupNotifications(
    List<NotificationEntity> notifications,
  ) {
    final grouped = <String, List<NotificationEntity>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    for (var notification in notifications) {
      final date = notification.createdAt;
      final dateOnly = DateTime(date.year, date.month, date.day);

      String key;
      if (dateOnly == today) {
        key = 'today';
      } else if (dateOnly == yesterday) {
        key = 'yesterday';
      } else if (dateOnly.isAfter(weekAgo)) {
        key = 'thisWeek';
      } else {
        key = 'older';
      }

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(notification);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.of(context).background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.of(context).card,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.arrow_left,
              size: 20.sp,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.notifications,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.of(context).textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<NotificationsBloc>().add(MarkAllAsRead());
            },
            child: Text(
              l10n.markAllAsRead,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.of(context).primary,
              ),
            ),
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state.status == NotificationsStatus.loading &&
              state.notifications.isEmpty) {
            return const AppLoaderFullPage();
          }

          if (state.status == NotificationsStatus.error &&
              state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.warning_2,
                    size: 48.sp,
                    color: AppColors.of(context).error,
                  ), // Fixed: Use Iconsax.warning_2 or standard
                  SizedBox(height: 16.h),
                  Text(
                    state.errorMessage ?? l10n.failedToLoadNotifications,
                    style: TextStyle(
                      color: AppColors.of(context).textSecondary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationsBloc>().add(
                        const LoadNotifications(refresh: true),
                      );
                    },
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: AppColors.of(context).card,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.of(
                            context,
                          ).textPrimary.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Iconsax.notification_bing, // Standard icon
                      size: 48.sp,
                      color: AppColors.of(context).textLight,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    l10n.allCaughtUp,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    l10n.noNewNotifications,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.of(context).textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final groupedNotifications = _groupNotifications(state.notifications);
          final groups = groupedNotifications.keys
              .toList(); // Order: Today, Yesterday, This Week, Older

          return RefreshIndicator(
            onRefresh: () async {
              context.read<NotificationsBloc>().add(
                const LoadNotifications(refresh: true),
              );
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              itemCount: groups.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= groups.length) {
                  return Padding(
                    padding: EdgeInsets.all(16.h),
                    child: const AppLoaderFullPage(),
                  );
                }

                final groupKey = groups[index];
                final notifications = groupedNotifications[groupKey]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 4.w,
                      ),
                      child: Text(
                        _localizeGroupKey(l10n, groupKey).toUpperCase(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppColors.of(context).textSecondary,
                        ),
                      ),
                    ),
                    ...notifications.map(
                      (notification) => NotificationTile(
                        notification: notification,
                        onTap: () {
                          if (!notification.isRead) {
                            context.read<NotificationsBloc>().add(
                              MarkAsRead(notification.id),
                            );
                          }
                          _handleNotificationTap(context, notification);
                        },
                        onDelete: () {
                          context.read<NotificationsBloc>().add(
                            DeleteNotification(notification.id),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _localizeGroupKey(AppLocalizations l10n, String key) {
    switch (key) {
      case 'today':
        return l10n.today;
      case 'yesterday':
        return l10n.yesterday;
      case 'thisWeek':
        return l10n.thisWeek;
      case 'older':
        return l10n.older;
      default:
        return key;
    }
  }

  void _handleNotificationTap(BuildContext context, dynamic notification) {
    if (notification is! NotificationEntity) return;

    final data = notification.data;
    final type = notification.type;

    switch (type) {
      case 'listing_approved':
      case 'listing_rejected':
      case 'price_drop':
      case 'new_review':
        if (data.containsKey('listingId')) {
          context.pushNamed(
            'listing_detail',
            pathParameters: {'id': data['listingId']},
          );
        }
        break;
      case 'new_message':
      case 'new_offer':
      case 'offer_accepted':
      case 'offer_declined':
      case 'offer_countered':
        if (data.containsKey('conversationId')) {
          final uri = Uri(
            path: '/chat/detail/${data['conversationId']}',
            queryParameters: {
              if (data.containsKey('senderName')) 'name': data['senderName'],
              if (data.containsKey('senderId')) 'userId': data['senderId'],
            },
          );
          context.push(uri.toString());
        } else {
          // Fallback if older notification without conversationId
          context.goNamed('chat');
        }
        break;
    }
  }
}
