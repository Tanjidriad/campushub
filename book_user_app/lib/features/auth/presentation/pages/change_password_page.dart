import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_snackbar.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:book_user_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onChangePassword() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthChangePasswordRequested(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthChangePasswordSuccess || current is AuthError,
      listener: (context, state) {
        if (state is AuthChangePasswordSuccess) {
          AppSnackBar.showSuccess(context, 'Password changed successfully');
          context.pop();
        } else if (state is AuthError) {
          AppSnackBar.showError(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Change Password')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create a new strong password.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.of(context).textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Current Password
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
                    child: Text(
                      'Current Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.of(context).textPrimary,
                      ),
                    ),
                  ),
                  AuthTextField(
                    controller: _currentPasswordController,
                    hintText: 'Enter your current password',
                    prefixIcon: FluentIcons.password_24_regular,
                    isObscure: _obscureCurrent,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrent
                            ? FluentIcons.eye_off_24_regular
                            : FluentIcons.eye_24_regular,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCurrent = !_obscureCurrent;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // New Password
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
                    child: Text(
                      'New Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.of(context).textPrimary,
                      ),
                    ),
                  ),
                  AuthTextField(
                    controller: _newPasswordController,
                    hintText: 'Enter your new password',
                    prefixIcon: FluentIcons.password_24_regular,
                    isObscure: _obscureNew,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew
                            ? FluentIcons.eye_off_24_regular
                            : FluentIcons.eye_24_regular,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNew = !_obscureNew;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Confirm Password
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
                    child: Text(
                      'Confirm New Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.of(context).textPrimary,
                      ),
                    ),
                  ),
                  AuthTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Type your new password again',
                    prefixIcon: FluentIcons.password_24_regular,
                    isObscure: _obscureConfirm,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? FluentIcons.eye_off_24_regular
                            : FluentIcons.eye_24_regular,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          backgroundColor: AppColors.of(context).primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: state is AuthChangePasswordLoading
                            ? null
                            : _onChangePassword,
                        child: state is AuthChangePasswordLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Change Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
