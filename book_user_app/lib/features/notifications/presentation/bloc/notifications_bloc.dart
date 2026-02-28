import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notifications_repository.dart';
import 'package:book_user_app/core/services/socket_service.dart'; // Assuming this path for SocketService
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository repository;

  final SocketService _socketService;

  NotificationsBloc({required this.repository, SocketService? socketService})
    : _socketService = socketService ?? SocketService(),
      super(const NotificationsState()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadUnreadCount>(_onLoadUnreadCount);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<StartNotificationListening>(_onStartListening);
    on<StopNotificationListening>(_onStopListening);
    on<NotificationReceived>(_onNotificationReceived);
  }

  @override
  Future<void> close() {
    _socketService.removeMessageListener(_handleNewMessage);
    return super.close();
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    debugPrint('🔔 NotificationsBloc: New message received via socket: $data');
    if (!isClosed) {
      add(NotificationReceived(data));
    }
  }

  void _onStartListening(
    StartNotificationListening event,
    Emitter<NotificationsState> emit,
  ) {
    debugPrint('🔔 NotificationsBloc: Starting to listen for socket messages');
    _socketService.addMessageListener(_handleNewMessage);
    // You can add other listeners here like 'notification:new' if backend supports it
  }

  void _onStopListening(
    StopNotificationListening event,
    Emitter<NotificationsState> emit,
  ) {
    _socketService.removeMessageListener(_handleNewMessage);
  }

  Future<void> _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationsState> emit,
  ) async {
    // 1. Increment unread count
    emit(state.copyWith(unreadCount: state.unreadCount + 1));

    // 2. Ideally, we should also add the notification to the list if it's open
    // For now, let's trigger a refresh if the list is loaded
    if (state.status == NotificationsStatus.loaded) {
      add(const LoadNotifications(refresh: true));
    }
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    if (event.refresh) {
      emit(
        state.copyWith(
          status: NotificationsStatus.loading,
          currentPage: 1,
          notifications: [],
        ),
      );
    } else if (state.status == NotificationsStatus.initial) {
      emit(state.copyWith(status: NotificationsStatus.loading));
    }

    final result = await repository.getNotifications(
      page: event.page,
      limit: 20,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotificationsStatus.error,
          errorMessage: failure.message ?? 'An unknown error occurred',
        ),
      ),
      (paginatedResponse) {
        final newNotifications = event.refresh
            ? paginatedResponse.items
            : [...state.notifications, ...paginatedResponse.items];

        emit(
          state.copyWith(
            status: NotificationsStatus.loaded,
            notifications: newNotifications,
            currentPage: paginatedResponse.currentPage,
            totalPages: paginatedResponse.totalPages,
            hasMore:
                paginatedResponse.currentPage < paginatedResponse.totalPages,
          ),
        );
      },
    );
  }

  Future<void> _onLoadUnreadCount(
    LoadUnreadCount event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await repository.getUnreadCount();

    result.fold(
      (failure) => null, // Silently fail for unread count
      (count) => emit(state.copyWith(unreadCount: count)),
    );
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await repository.markAsRead(event.id);

    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: failure.message ?? 'An unknown error occurred',
        ),
      ),
      (_) {
        // Optimistic update - actually we should just decrement unread count
        if (state.unreadCount > 0) {
          emit(state.copyWith(unreadCount: state.unreadCount - 1));
        }

        add(const LoadNotifications(refresh: true));
      },
    );
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await repository.markAllAsRead();

    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: failure.message ?? 'An unknown error occurred',
        ),
      ),
      (_) {
        emit(state.copyWith(unreadCount: 0));
        add(const LoadNotifications(refresh: true));
      },
    );
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await repository.deleteNotification(event.id);

    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: failure.message ?? 'An unknown error occurred',
        ),
      ),
      (_) {
        final updatedNotifications = state.notifications
            .where((n) => n.id != event.id)
            .toList();
        emit(state.copyWith(notifications: updatedNotifications));
      },
    );
  }
}
