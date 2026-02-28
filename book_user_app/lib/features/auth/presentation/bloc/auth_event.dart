import 'dart:io';

import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class AuthResendVerificationRequested extends AuthEvent {
  const AuthResendVerificationRequested();
}

class AuthGetCurrentUserRequested extends AuthEvent {
  const AuthGetCurrentUserRequested();
}

class AuthUpdateProfileRequested extends AuthEvent {
  final String? name;
  final String? username;
  final String? phone;
  final String? bio;
  final String? location;

  const AuthUpdateProfileRequested({
    this.name,
    this.username,
    this.phone,
    this.bio,
    this.location,
  });

  @override
  List<Object?> get props => [name, username, phone, bio, location];
}

class AuthUpdateAvatarRequested extends AuthEvent {
  final File imageFile;

  const AuthUpdateAvatarRequested({required this.imageFile});

  @override
  List<Object> get props => [imageFile];
}

class AuthUserUpdated extends AuthEvent {
  final User user;

  const AuthUserUpdated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthResetPasswordRequested extends AuthEvent {
  final String token;
  final String newPassword;

  const AuthResetPasswordRequested({
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object> get props => [token, newPassword];
}
