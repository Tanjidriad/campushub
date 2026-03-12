import 'package:equatable/equatable.dart';

class AdminUser extends Equatable {
  final String? id;
  final String? name;
  final String? email;
  final String? role;
  final String? avatar;
  final String? accessToken;
  final String? refreshToken;

  const AdminUser({
    this.id,
    this.name,
    this.email,
    this.role,
    this.avatar,
    this.accessToken,
    this.refreshToken,
  });

  @override
  List<Object?> get props => [id, name, email, role, avatar];
}
