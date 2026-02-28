import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Register new user
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
  });

  /// Login user
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Logout user
  Future<Either<Failure, void>> logout();

  /// Get current user profile
  Future<Either<Failure, User>> getCurrentUser();

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? username,
    String? phone,
    String? bio,
    String? location,
  });

  /// Change password
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Forgot password
  Future<Either<Failure, void>> forgotPassword({required String email});

  /// Reset password
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Resend verification email
  Future<Either<Failure, void>> resendVerification();

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Get stored access token
  Future<String?> getAccessToken();

  /// Get stored refresh token
  Future<String?> getRefreshToken();

  /// Delete account
  Future<Either<Failure, void>> deleteAccount();

  /// Update user avatar
  Future<Either<Failure, User>> updateAvatar(File imageFile);
}
