import 'package:equatable/equatable.dart';
import 'user_entity.dart';

class UserStats extends Equatable {
  final int total;
  final int active;
  final int banned;
  final int admins;

  const UserStats({
    required this.total,
    required this.active,
    required this.banned,
    required this.admins,
  });

  @override
  List<Object?> get props => [total, active, banned, admins];
}

class UsersResponse extends Equatable {
  final List<AdminUserEntity> users;
  final UserStats stats;

  const UsersResponse({required this.users, required this.stats});

  @override
  List<Object?> get props => [users, stats];
}
