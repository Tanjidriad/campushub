import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/users_response.dart';

abstract class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<AdminUserEntity> users;
  final UserStats stats;

  const UsersLoaded({required this.users, required this.stats});

  @override
  List<Object?> get props => [users, stats];
}

class UsersError extends UsersState {
  final String message;

  const UsersError(this.message);

  @override
  List<Object?> get props => [message];
}
