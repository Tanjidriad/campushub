import 'package:equatable/equatable.dart';

abstract class BlockedUsersEvent extends Equatable {
  const BlockedUsersEvent();

  @override
  List<Object> get props => [];
}

class FetchBlockedUsers extends BlockedUsersEvent {}

class UnblockUserEvent extends BlockedUsersEvent {
  final String userId;

  const UnblockUserEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}
