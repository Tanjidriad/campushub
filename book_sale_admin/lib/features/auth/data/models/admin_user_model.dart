import '../../domain/entities/admin_user.dart';

class AdminUserModel extends AdminUser {
  const AdminUserModel({
    super.id,
    super.name,
    super.email,
    super.role,
    super.avatar,
    super.accessToken,
    super.refreshToken,
  });

  factory AdminUserModel.fromJson(
    Map<String, dynamic> json, {
    String? accessToken,
    String? refreshToken,
  }) {
    return AdminUserModel(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      avatar: json['avatar'],
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
