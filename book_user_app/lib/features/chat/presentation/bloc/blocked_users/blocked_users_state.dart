import 'package:book_user_app/features/auth/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

abstract class BlockedUsersState extends Equatable {
  const BlockedUsersState();

  @override
  List<Object?> get props => [];
}

class BlockedUsersInitial extends BlockedUsersState {}

class BlockedUsersLoading extends BlockedUsersState {}

class BlockedUsersLoaded extends BlockedUsersState {
  final List<User> blockedUsers;

  const BlockedUsersLoaded({required this.blockedUsers});

  @override
  List<Object?> get props => [blockedUsers];
}

class BlockedUsersError extends BlockedUsersState {
  final String message;

  const BlockedUsersError({required this.message});

  @override
  List<Object?> get props => [message];
}

class UnblockUserSuccess extends BlockedUsersState {
  final String unblockedUserId;

  const UnblockUserSuccess({required this.unblockedUserId});

  @override
  List<Object?> get props => [unblockedUserId];
}
