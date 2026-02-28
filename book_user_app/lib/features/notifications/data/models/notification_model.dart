import '../../domain/entities/notification.dart';

class NotificationModel extends Notification {
  NotificationModel({
    required String id,
    required String type,
    required String title,
    required String message,
    required Map<String, dynamic> data,
    required bool isRead,
    required DateTime createdAt,
  }) : super(
         id: id,
         type: type,
         title: title,
         message: message,
         data: data,
         isRead: isRead,
         createdAt: createdAt,
       );

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      type: json['type'],
      title: json['title'],
      message: json['body'] ?? json['message'] ?? '',
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : {},
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
