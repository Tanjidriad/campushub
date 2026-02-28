import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

class LoadNotifications extends NotificationsEvent {
  final int page;
  final bool refresh;

  const LoadNotifications({this.page = 1, this.refresh = false});

  @override
  List<Object> get props => [page, refresh];
}

class LoadUnreadCount extends NotificationsEvent {}

class MarkAsRead extends NotificationsEvent {
  final String id;

  const MarkAsRead(this.id);

  @override
  List<Object> get props => [id];
}

class MarkAllAsRead extends NotificationsEvent {}

class DeleteNotification extends NotificationsEvent {
  final String id;

  const DeleteNotification(this.id);

  @override
  List<Object> get props => [id];
}

class StartNotificationListening extends NotificationsEvent {}

class StopNotificationListening extends NotificationsEvent {}

class NotificationReceived extends NotificationsEvent {
  final Map<String, dynamic> data;

  const NotificationReceived(this.data);

  @override
  List<Object> get props => [data];
}
