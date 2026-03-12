import '../../domain/entities/user_entity.dart';

class AdminUserModel extends AdminUserEntity {
  const AdminUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.avatar,
    required super.isBlocked,
    required super.isOnline,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      avatar: json['avatar'] as String?,
      isBlocked: json['isBlocked'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'avatar': avatar,
      'isBlocked': isBlocked,
      'isOnline': isOnline,
    };
  }
}
