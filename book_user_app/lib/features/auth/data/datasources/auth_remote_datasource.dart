import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  });

  Future<UserModel> login({required String email, required String password});

  Future<void> logout();

  Future<UserModel> getCurrentUser();

  Future<UserModel> updateProfile({
    String? name,
    String? username,
    String? phone,
    String? bio,
    String? location,
    String? educationLevel,
    String? stream,
    String? department,
    String? classOrSemester,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<void> resendVerification();

  Future<void> deleteAccount();

  Future<bool> checkUsernameAvailability(String username);

  Future<UserModel> updateAvatar(File imageFile);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await apiClient.post(
      ApiConstants.register,
      data: {'email': email, 'password': password, 'name': name},
    );

    if (response.statusCode == 201 && response.data['success'] == true) {
      final userData = response.data['data'];

      // Store tokens
      await apiClient.secureStorage.write(
        key: StorageKeys.accessToken,
        value: userData['accessToken'],
      );
      await apiClient.secureStorage.write(
        key: StorageKeys.refreshToken,
        value: userData['refreshToken'],
      );
      await apiClient.secureStorage.write(
        key: StorageKeys.isLoggedIn,
        value: 'true',
      );
      // Store user ID for chat functionality
      final userId = (userData['user']['_id'] ?? userData['user']['id'])
          ?.toString();
      if (userId != null) {
        await apiClient.secureStorage.write(
          key: StorageKeys.userId,
          value: userId,
        );
      }

      return UserModel.fromJson(userData['user']);
    } else {
      throw ApiException(
        message: parseErrorMessage(response.data['message']),
        statusCode: response.statusCode,
        data: response.data,
      );
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final userData = response.data['data'];

      // Store tokens
      await apiClient.secureStorage.write(
        key: StorageKeys.accessToken,
        value: userData['accessToken'],
      );
      await apiClient.secureStorage.write(
        key: StorageKeys.refreshToken,
        value: userData['refreshToken'],
      );
      await apiClient.secureStorage.write(
        key: StorageKeys.isLoggedIn,
        value: 'true',
      );
      // Store user ID for chat functionality
      final userId = (userData['user']['_id'] ?? userData['user']['id'])
          ?.toString();
      if (userId != null) {
        await apiClient.secureStorage.write(
          key: StorageKeys.userId,
          value: userId,
        );
      }

      return UserModel.fromJson(userData['user']);
    } else {
      throw ApiException(
        message: parseErrorMessage(response.data['message']),
        statusCode: response.statusCode,
        data: response.data,
      );
    }
  }

  @override
  Future<void> logout() async {
    final response = await apiClient.post('/auth/logout');

    if (response.statusCode == 200) {
      // Clear all stored data
      await apiClient.secureStorage.delete(key: StorageKeys.accessToken);
      await apiClient.secureStorage.delete(key: StorageKeys.refreshToken);
      await apiClient.secureStorage.delete(key: StorageKeys.isLoggedIn);
      await apiClient.secureStorage.delete(key: StorageKeys.userId);
    } else {
      throw ApiException(
        message: response.data['message'] ?? 'Logout failed',
        statusCode: response.statusCode,
        data: response.data,
      );
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await apiClient.get('/auth/me');

    if (response.statusCode == 200 && response.data['success'] == true) {
      return UserModel.fromJson(response.data['data']);
    } else {
      throw ApiException(
        message: response.data['message'] ?? 'Failed to get user',
        statusCode: response.statusCode,
        data: response.data,
      );
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? username,
    String? phone,
    String? bio,
    String? location,
    String? educationLevel,
    String? stream,
    String? department,
    String? classOrSemester,
  }) async {
    final response = await apiClient.put(
      '/auth/profile',
      data: {
        if (name != null) 'name': name,
        if (username != null) 'username': username,
        if (phone != null) 'phone': phone,
        if (bio != null) 'bio': bio,
        if (location != null) 'location': location,
        // Send values unconditionally so we can clear them by sending empty string if needed
        'educationLevel': educationLevel ?? '',
        'stream': stream ?? '',
        'department': department ?? '',
        'classOrSemester': classOrSemester ?? '',
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return UserModel.fromJson(response.data['data']);
    } else {
      throw ApiException(
        message: response.data['message'] ?? 'Failed to update profile',
        statusCode: response.statusCode,
        data: response.data,
      );
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await apiClient.put(
      '/auth/password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );

    if (response.statusCode != 200 || response.data['success'] != true) {
      throw ApiException(
        message: response.data['message'] ?? 'Failed to change password',
        statusCode: response.statusCode,
        data: response.data,
      );
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    final response = await apiClient.post(
      '/auth/forgot-password',
      data: {'email': email},
    );

    if (response.statusCode != 200 || response.data['success'] != true) {
      throw ApiException(
        message: response.data['message'] ?? 'Failed to send reset email',
        statusCode: response.statusCode,
        data: response.data,
      );
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await apiClient.post(
      '/auth/reset-password/$token',
      data: {'password': newPassword},
    );

    if (response.statusCode != 200 || response.data['success'] != true) {
      throw ApiException(
        message: response.data['message'] ?? 'Failed to reset password',
        statusCode: response.statusCode,
        data: response.data,
      );
    }
  }

  @override
  Future<void> resendVerification() async {
    final response = await apiClient.post('/auth/resend-verification');

    if (response.statusCode != 200 || response.data['success'] != true) {
      throw ApiException(
        message: response.data['message'] ?? 'Failed to resend verification',
        statusCode: response.statusCode,
        data: response.data,
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    final response = await apiClient.delete('/auth/me');

    if (response.statusCode == 200 && response.data['success'] == true) {
      // Clear all stored data
      await apiClient.secureStorage.delete(key: StorageKeys.accessToken);
      await apiClient.secureStorage.delete(key: StorageKeys.refreshToken);
      await apiClient.secureStorage.delete(key: StorageKeys.isLoggedIn);
      await apiClient.secureStorage.delete(key: StorageKeys.userId);
    } else {
      throw ApiException(
        message: response.data['message'] ?? 'Failed to delete account',
        statusCode: response.statusCode,
        data: response.data,
      );
    }
  }

  @override
  Future<bool> checkUsernameAvailability(String username) async {
    final response = await apiClient.get(
      '${ApiConstants.checkUsername}/$username',
    );

    if (response.statusCode == 200) {
      return response.data['available'] == true;
    } else {
      // For validation errors (400), return false but with message
      throw ApiException(
        message: response.data['message'] ?? 'Failed to check username',
        statusCode: response.statusCode,
        data: response.data,
      );
    }
  }

  @override
  Future<UserModel> updateAvatar(File imageFile) async {
    final fileName = imageFile.path.split('/').last;
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });

    final response = await apiClient.put('/auth/avatar', data: formData);

    if (response.statusCode == 200 && response.data['success'] == true) {
      return UserModel.fromJson(response.data['data']);
    } else {
      throw ApiException(
        message: response.data['message'] ?? 'Failed to update avatar',
        statusCode: response.statusCode,
        data: response.data,
      );
    }
  }
}
