import 'package:book_user_app/features/notifications/domain/entities/notification.dart'
    as domain;
import 'package:equatable/equatable.dart';

enum NotificationsStatus { initial, loading, loaded, error }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<domain.Notification> notifications;
  final int unreadCount;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = false,
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<domain.Notification>? notifications,
    int? unreadCount,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [
    status,
    notifications,
    unreadCount,
    errorMessage,
    currentPage,
    totalPages,
    hasMore,
  ];
}
