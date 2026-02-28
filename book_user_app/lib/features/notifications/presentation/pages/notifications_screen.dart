import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_loader.dart';
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
        key = 'Today';
      } else if (dateOnly == yesterday) {
        key = 'Yesterday';
      } else if (dateOnly.isAfter(weekAgo)) {
        key = 'This Week';
      } else {
        key = 'Older';
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
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppPalette.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.arrow_left, size: 20.sp, color: Colors.black),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppPalette.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<NotificationsBloc>().add(MarkAllAsRead());
            },
            child: Text(
              'Mark all as read',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppPalette.primary,
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
                    color: AppPalette.error,
                  ), // Fixed: Use Iconsax.warning_2 or standard
                  SizedBox(height: 16.h),
                  Text(
                    state.errorMessage ?? 'Failed to load notifications',
                    style: TextStyle(color: AppPalette.textSecondary),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationsBloc>().add(
                        const LoadNotifications(refresh: true),
                      );
                    },
                    child: const Text('Retry'),
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
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Iconsax.notification_bing, // Standard icon
                      size: 48.sp,
                      color: AppPalette.textLight,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'All caught up!',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'No new notifications for you right now.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppPalette.textSecondary,
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
                        groupKey.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppPalette.textSecondary,
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
        context.goNamed('chat');
        break;
      case 'new_offer':
      case 'offer_accepted':
      case 'offer_declined':
      case 'offer_countered':
        if (data.containsKey('offerId')) {
          context.push('/offer/${data['offerId']}');
        }
        break;
    }
  }
}
