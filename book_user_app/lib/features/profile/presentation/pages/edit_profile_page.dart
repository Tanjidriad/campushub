import 'dart:async';
import 'dart:io';

import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:book_user_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:book_user_app/features/auth/domain/entities/user.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:book_user_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:book_user_app/core/services/education_config_service.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
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

  // Education configuration
  String? _selectedEducationLevel;
  String? _selectedStream;
  String? _selectedDepartment;
  String? _selectedClassOrSemester;
  final _configService = EducationConfigService();
  EducationConfig? _eduConfig;

  List<EducationLevel> get _educationLevels =>
      (_eduConfig ?? EducationConfig.fallback).levels;

  List<String> get _classOrSemesterOptions {
    if (_selectedEducationLevel == null) return [];
    final config = _eduConfig ?? EducationConfig.fallback;
    final level = config.levels
        .where((l) => l.key == _selectedEducationLevel)
        .toList();
    if (level.isEmpty) return [];

    final rootSubLevels = level.first.subLevels;
    if (rootSubLevels.isNotEmpty) {
      return rootSubLevels.map((s) => s.label).toList();
    }

    if (_selectedDepartment != null) {
      try {
        final stream = _streamOptions.firstWhere((s) => s.key == _selectedStream);
        final dept = stream.departments.firstWhere((d) => d.key == _selectedDepartment);
        return dept.subLevels.map((s) => s.label).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  List<EducationStream> get _streamOptions {
    if (_selectedEducationLevel == null) return [];
    final config = _eduConfig ?? EducationConfig.fallback;
    final level = config.levels
        .where((l) => l.key == _selectedEducationLevel)
        .toList();
    if (level.isEmpty) return [];
    return level.first.streams;
  }

  List<EducationDepartment> get _departmentOptions {
    if (_selectedStream == null) return [];
    try {
      final stream = _streamOptions.firstWhere((s) => s.key == _selectedStream);
      return stream.departments;
    } catch (e) {
      return [];
    }
  }

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

    _selectedEducationLevel = widget.user.educationLevel;
    _selectedStream = widget.user.stream;
    _selectedDepartment = widget.user.department;
    _selectedClassOrSemester = widget.user.classOrSemester;

    _usernameController.addListener(_onUsernameChanged);
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await _configService.fetchConfig();
    if (mounted) setState(() => _eduConfig = config);
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
    final l10n = AppLocalizations.of(context)!;
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
        _usernameMessage = l10n.currentUsernameMessage;
      });
      return;
    }

    final regex = RegExp(r'^[a-z0-9_]+$');
    if (!regex.hasMatch(username)) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = false;
        _usernameMessage = l10n.usernameInvalidChars;
      });
      return;
    }

    if (username.length < 3) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = false;
        _usernameMessage = l10n.usernameMinLength;
      });
      return;
    }

    if (username.length > 20) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = false;
        _usernameMessage = l10n.usernameMaxLength;
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
              ? AppLocalizations.of(context)!.usernameAvailable
              : AppLocalizations.of(context)!.usernameTaken;
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
        AppSnackBar.showError(context, 'Error picking image: $e');
      }
    }
  }

  void _showImagePickerOptions() {
    final l10n = AppLocalizations.of(context)!;
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
                l10n.changeProfilePicture,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Iconsax.camera,
                    color: AppColors.of(context).primary,
                  ),
                ),
                title: Text(l10n.takeAPhoto),
                subtitle: Text(l10n.useYourCamera),
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
                    color: AppColors.of(context).primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Iconsax.gallery,
                    color: AppColors.of(context).primary,
                  ),
                ),
                title: Text(l10n.chooseFromGallery),
                subtitle: Text(l10n.selectExistingPhoto),
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
      AppSnackBar.showWarning(
        context,
        AppLocalizations.of(context)!.chooseAvailableUsername,
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
          educationLevel: _selectedEducationLevel,
          stream: _selectedStream,
          department: _selectedDepartment,
          classOrSemester: _selectedClassOrSemester,
        ),
      );
    }
  }

  Widget _buildUsernameField() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          controller: _usernameController,
          hintText: l10n.username,
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
                      ? AppColors.of(context).success
                      : AppColors.of(context).error,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    _usernameMessage!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: _isUsernameAvailable == true
                          ? AppColors.of(context).success
                          : AppColors.of(context).error,
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
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.of(context).primary,
          ),
        ),
      );
    }

    if (_isUsernameAvailable == true) {
      return Icon(
        Icons.check_circle,
        color: AppColors.of(context).success,
        size: 24.sp,
      );
    }

    if (_isUsernameAvailable == false) {
      return Icon(
        Icons.cancel,
        color: AppColors.of(context).error,
        size: 24.sp,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Update the current avatar URL if it changed
          if (state.user.avatar != _currentAvatarUrl) {
            setState(() {
              _currentAvatarUrl = state.user.avatar;
              _selectedImage = null; // Clear local selection
            });
            AppSnackBar.showSuccess(context, l10n.profilePictureUpdated);
          } else {
            // Profile update successful, pop the page
            context.pop();
          }
        } else if (state is AuthError) {
          AppSnackBar.showError(context, state.message);
        }
      },
      listenWhen: (previous, current) {
        return (previous is AuthLoading || previous is AuthAvatarUploading) &&
            (current is AuthAuthenticated || current is AuthError);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.editProfile), centerTitle: true),
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
                              color: AppColors.of(context).surface,
                              border: Border.all(
                                color: AppColors.of(context).primary,
                                width: 2,
                              ),
                              image: _selectedImage != null
                                  ? DecorationImage(
                                      image: FileImage(_selectedImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : _currentAvatarUrl != null
                                  ? DecorationImage(
                                      image: CachedNetworkImageProvider(
                                        _currentAvatarUrl!,
                                      ),
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
                                    color: AppColors.of(context).textSecondary,
                                  )
                                : null,
                          ),
                          // Upload overlay
                          if (isUploading)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.of(context).textSecondary,
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.of(context).card,
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
                                  color: AppColors.of(context).primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.of(context).card,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Iconsax.camera,
                                  size: 16.sp,
                                  color: AppColors.of(context).card,
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
                  l10n.tapToChangePhoto,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.of(context).textSecondary,
                  ),
                ),
                SizedBox(height: 24.h),

                // Name
                AuthTextField(
                  controller: _nameController,
                  hintText: l10n.fullName,
                  prefixIcon: Iconsax.user,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.nameIsRequired;
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
                  hintText: l10n.phoneNumber,
                  prefixIcon: Iconsax.call,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final cleaned = value.replaceAll(
                        RegExp(r'[\s\-\(\)]'),
                        '',
                      );
                      if (!RegExp(r'^\+?\d{7,15}$').hasMatch(cleaned)) {
                        return l10n.validPhoneNumber;
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Location
                AuthTextField(
                  controller: _locationController,
                  hintText: l10n.campusDormLocation,
                  prefixIcon: Iconsax.location,
                ),
                SizedBox(height: 16.h),

                // Bio
                AuthTextField(
                  controller: _bioController,
                  hintText: l10n.bio,
                  prefixIcon: Iconsax.edit,
                  maxLines: 3,
                  validator: (value) {
                    if (value != null && value.length > 300) {
                      return l10n.bioMaxLength;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),

                // Education Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.of(context).primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.school_rounded,
                            size: 20.sp,
                            color: AppColors.of(context).primary,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            l10n.educationLevel, // Using as title
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.of(context).primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Education Level
                      Text(
                        l10n.educationLevel,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _educationLevels.map((level) {
                          final isSelected = _selectedEducationLevel == level.key;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedEducationLevel = level.key;
                                _selectedStream = null;
                                _selectedDepartment = null;
                                _selectedClassOrSemester = null;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.of(context).primary
                                    : AppColors.of(context).surface,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.of(context).primary
                                      : AppColors.of(context).border,
                                ),
                              ),
                              child: Text(
                                level.label,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.of(context).onPrimary
                                      : AppColors.of(context).textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      // Streams
                      if (_selectedEducationLevel != null && _streamOptions.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        Text(
                          'Stream / Department',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: _streamOptions.map((opt) {
                            final isSelected = _selectedStream == opt.key;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedStream = opt.key;
                                  _selectedDepartment = null;
                                  _selectedClassOrSemester = null;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 7.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.of(context).primary
                                      : AppColors.of(context).surface,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.of(context).primary
                                        : AppColors.of(context).border,
                                  ),
                                ),
                                child: Text(
                                  opt.label,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.of(context).onPrimary
                                        : AppColors.of(context).textPrimary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      // Departments
                      if (_selectedStream != null && _departmentOptions.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        Text(
                          'Department',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: _departmentOptions.map((opt) {
                            final isSelected = _selectedDepartment == opt.key;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDepartment = opt.key;
                                  _selectedClassOrSemester = null;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 7.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.of(context).primary
                                      : AppColors.of(context).surface,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.of(context).primary
                                        : AppColors.of(context).border,
                                  ),
                                ),
                                child: Text(
                                  opt.label,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.of(context).onPrimary
                                        : AppColors.of(context).textPrimary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      // Class / Semester
                      if (_selectedEducationLevel != null && _classOrSemesterOptions.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        Text(
                          _selectedEducationLevel == 'university'
                              ? l10n.semester
                              : l10n.classLabel,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: _classOrSemesterOptions.map((opt) {
                            final isSelected = _selectedClassOrSemester == opt;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedClassOrSemester = opt;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 7.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.of(context).primary
                                      : AppColors.of(context).surface,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.of(context).primary
                                        : AppColors.of(context).border,
                                  ),
                                ),
                                child: Text(
                                  opt,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.of(context).onPrimary
                                        : AppColors.of(context).textPrimary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
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
                          ? CircularProgressIndicator(
                              color: AppColors.of(context).onPrimary,
                            )
                          : Text(l10n.saveChanges),
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
