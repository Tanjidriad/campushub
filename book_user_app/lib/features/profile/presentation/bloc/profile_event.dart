import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class UserProfileLoadRequested extends ProfileEvent {
  final String userId;

  const UserProfileLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}
