import 'package:equatable/equatable.dart';

class AdminUserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final bool isBlocked;
  final bool isOnline;

  const AdminUserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    required this.isBlocked,
    required this.isOnline,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    avatar,
    isBlocked,
    isOnline,
  ];
}
