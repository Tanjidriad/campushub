import 'package:equatable/equatable.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsersEvent extends UsersEvent {
  final String? search;
  final String? role;
  final String? status;

  const LoadUsersEvent({this.search, this.role, this.status});

  @override
  List<Object?> get props => [search, role, status];
}

class ToggleBanEvent extends UsersEvent {
  final String userId;

  const ToggleBanEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ChangeRoleEvent extends UsersEvent {
  final String userId;
  final String newRole;

  const ChangeRoleEvent({required this.userId, required this.newRole});

  @override
  List<Object?> get props => [userId, newRole];
}
