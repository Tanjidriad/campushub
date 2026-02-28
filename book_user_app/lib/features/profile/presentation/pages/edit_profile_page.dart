import 'dart:async';
import 'dart:io';

import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:book_user_app/features/auth/domain/entities/user.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:book_user_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;

  // Username availability state
  bool _isCheckingUsername = false;
  bool? _isUsernameAvailable;
  String? _usernameMessage;
  Timer? _debounceTimer;
  String? _originalUsername;

  // Image picker
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _usernameController = TextEditingController(text: widget.user.username);
    _phoneController = TextEditingController(text: widget.user.phone);
    _bioController = TextEditingController(text: widget.user.bio);
    _locationController = TextEditingController(text: widget.user.location);
    _originalUsername = widget.user.username?.toLowerCase();
    _currentAvatarUrl = widget.user.avatar;

    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _usernameController.removeListener(_onUsernameChanged);
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onUsernameChanged() {
    final username = _usernameController.text.trim().toLowerCase();
    _debounceTimer?.cancel();

    if (username.isEmpty) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = null;
        _usernameMessage = null;
      });
      return;
    }

    if (username == _originalUsername) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = true;
        _usernameMessage = 'This is your current username';
      });
      return;
    }

    final regex = RegExp(r'^[a-z0-9_]+$');
    if (!regex.hasMatch(username)) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = false;
        _usernameMessage = 'Only letters, numbers, and underscores allowed';
      });
      return;
    }

    if (username.length < 3) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = false;
        _usernameMessage = 'Username must be at least 3 characters';
      });
      return;
    }

    if (username.length > 20) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = false;
        _usernameMessage = 'Username cannot exceed 20 characters';
      });
      return;
    }

    setState(() {
      _isCheckingUsername = true;
      _isUsernameAvailable = null;
      _usernameMessage = null;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      await _checkUsernameAvailability(username);
    });
  }

  Future<void> _checkUsernameAvailability(String username) async {
    try {
      final dataSource = sl<AuthRemoteDataSource>();
      final isAvailable = await dataSource.checkUsernameAvailability(username);

      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
          _isUsernameAvailable = isAvailable;
          _usernameMessage = isAvailable
              ? 'Username is available!'
              : 'Username is already taken';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
          _isUsernameAvailable = false;
          _usernameMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // Upload immediately
        if (mounted) {
          context.read<AuthBloc>().add(
            AuthUpdateAvatarRequested(imageFile: _selectedImage!),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Change Profile Picture',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppPalette.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Iconsax.camera, color: AppPalette.primary),
                ),
                title: const Text('Take a Photo'),
                subtitle: const Text('Use your camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              SizedBox(height: 8.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppPalette.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Iconsax.gallery, color: AppPalette.primary),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select an existing photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_usernameController.text.trim().isNotEmpty &&
        _isUsernameAvailable == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose an available username')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthUpdateProfileRequested(
          name: _nameController.text.trim(),
          username: _usernameController.text.trim().isEmpty
              ? null
              : _usernameController.text.trim().toLowerCase(),
          phone: _phoneController.text.trim(),
          bio: _bioController.text.trim(),
          location: _locationController.text.trim(),
        ),
      );
    }
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          controller: _usernameController,
          hintText: 'Username',
          prefixIcon: Icons.alternate_email,
          suffixIcon: _buildUsernameSuffix(),
        ),
        if (_usernameMessage != null) ...[
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Row(
              children: [
                Icon(
                  _isUsernameAvailable == true
                      ? Icons.check_circle
                      : Icons.cancel,
                  size: 14.sp,
                  color: _isUsernameAvailable == true
                      ? Colors.green
                      : Colors.red,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    _usernameMessage!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: _isUsernameAvailable == true
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget? _buildUsernameSuffix() {
    if (_isCheckingUsername) {
      return Padding(
        padding: EdgeInsets.all(12.w),
        child: SizedBox(
          width: 20.w,
          height: 20.w,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: AppPalette.primary,
          ),
        ),
      );
    }

    if (_isUsernameAvailable == true) {
      return Icon(Icons.check_circle, color: Colors.green, size: 24.sp);
    }

    if (_isUsernameAvailable == false) {
      return Icon(Icons.cancel, color: Colors.red, size: 24.sp);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Update the current avatar URL if it changed
          if (state.user.avatar != _currentAvatarUrl) {
            setState(() {
              _currentAvatarUrl = state.user.avatar;
              _selectedImage = null; // Clear local selection
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            // Profile update successful, pop the page
            context.pop();
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      listenWhen: (previous, current) {
        return (previous is AuthLoading || previous is AuthAvatarUploading) &&
            (current is AuthAuthenticated || current is AuthError);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar with upload capability
                BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (prev, curr) =>
                      curr is AuthAvatarUploading || curr is AuthAuthenticated,
                  builder: (context, state) {
                    final isUploading = state is AuthAvatarUploading;

                    return GestureDetector(
                      onTap: isUploading ? null : _showImagePickerOptions,
                      child: Stack(
                        children: [
                          Container(
                            width: 100.w,
                            height: 100.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppPalette.surface,
                              border: Border.all(
                                color: AppPalette.primary,
                                width: 2,
                              ),
                              image: _selectedImage != null
                                  ? DecorationImage(
                                      image: FileImage(_selectedImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : _currentAvatarUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(_currentAvatarUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child:
                                (_selectedImage == null &&
                                    _currentAvatarUrl == null)
                                ? Icon(
                                    Icons.person,
                                    size: 50.sp,
                                    color: AppPalette.textSecondary,
                                  )
                                : null,
                          ),
                          // Upload overlay
                          if (isUploading)
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black45,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                ),
                              ),
                            ),
                          // Camera icon overlay
                          if (!isUploading)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: AppPalette.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Iconsax.camera,
                                  size: 16.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tap to change photo',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppPalette.textSecondary,
                  ),
                ),
                SizedBox(height: 24.h),

                // Name
                AuthTextField(
                  controller: _nameController,
                  hintText: 'Full Name',
                  prefixIcon: Iconsax.user,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Username
                _buildUsernameField(),
                SizedBox(height: 16.h),

                // Phone
                AuthTextField(
                  controller: _phoneController,
                  hintText: 'Phone Number',
                  prefixIcon: Iconsax.call,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16.h),

                // Location
                AuthTextField(
                  controller: _locationController,
                  hintText: 'Campus / Dorm Location',
                  prefixIcon: Iconsax.location,
                ),
                SizedBox(height: 16.h),

                // Bio
                AuthTextField(
                  controller: _bioController,
                  hintText: 'Bio',
                  prefixIcon: Iconsax.edit,
                  maxLines: 3,
                ),
                SizedBox(height: 32.h),

                // Save Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 56.h),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save Changes'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
