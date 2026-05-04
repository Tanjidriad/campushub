import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_snackbar.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
// ignore_for_file: deprecated_member_use

import 'package:book_user_app/config/routes/app_router.dart';
import 'package:book_user_app/core/services/education_config_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/bloc/categories_bloc.dart';
import '../../../categories/presentation/bloc/categories_event.dart';
import '../../../categories/presentation/bloc/categories_state.dart';
import '../bloc/create_listing_bloc.dart';

class CreateListingDetailsPage extends StatefulWidget {
  const CreateListingDetailsPage({super.key});

  @override
  State<CreateListingDetailsPage> createState() =>
      _CreateListingDetailsPageState();
}

class _CreateListingDetailsPageState extends State<CreateListingDetailsPage> {
  Category? _selectedCategory;
  String _selectedCondition = 'good';
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  // Education fields (dynamic from API)
  String? _selectedEducationLevel;
  String? _selectedStream;
  String? _selectedDepartment;
  String? _selectedClassOrSemester;
  String? _selectedBookType;
  final _configService = EducationConfigService();
  EducationConfig? _eduConfig;

  final List<Map<String, dynamic>> _conditions = [
    {'value': 'new', 'label': 'New', 'icon': Icons.verified},
    {'value': 'like-new', 'label': 'Like New', 'icon': Icons.favorite},
    {'value': 'good', 'label': 'Good', 'icon': Icons.thumb_up},
    {'value': 'fair', 'label': 'Fair', 'icon': Icons.build},
  ];

  List<EducationLevel> get _educationLevels =>
      (_eduConfig ?? EducationConfig.fallback).levels;

  List<BookType> get _bookTypes =>
      (_eduConfig ?? EducationConfig.fallback).bookTypes;

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
    _loadConfig();
    context.read<CategoriesBloc>().add(const CategoriesLoadRequested());
  }

  Future<void> _loadConfig() async {
    final config = await _configService.fetchConfig();
    if (mounted) setState(() => _eduConfig = config);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  String _conditionLabel(AppLocalizations l10n, String value) {
    switch (value) {
      case 'new':
        return l10n.conditionNew;
      case 'like-new':
        return l10n.conditionLikeNew;
      case 'good':
        return l10n.conditionGood;
      case 'fair':
        return l10n.conditionFair;
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = AppColors.of(context).border;
    final surfaceColor = AppColors.of(context).surface;

    final bool showBookFields = _selectedCategory?.hasEducationConfig ?? false;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // TopAppBar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: AppColors.of(context).overlay,
                      child: Icon(
                        Icons.arrow_back,
                        color: theme.textTheme.bodyLarge?.color,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      l10n.addDetails,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 40.w),
                ],
              ),
            ),

            // PageIndicators
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withOpacity(
                            isDark ? 0.2 : 0.3,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        width: 32.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: borderColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    l10n.stepTwoOfThree,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.of(context).textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    Text(
                      l10n.itemInformation,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      l10n.itemInfoSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.of(context).textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Category Field
                    Text(
                      l10n.category,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    BlocBuilder<CategoriesBloc, CategoriesState>(
                      builder: (context, state) {
                        if (state is CategoriesLoading) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: const CircularProgressIndicator(),
                            ),
                          );
                        }

                        List<Category> options = [];
                        if (state is CategoriesLoaded) {
                          options = state.categories
                              .where((c) => c.isActive)
                              .toList();
                        }

                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: borderColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Category>(
                              value: _selectedCategory,
                              hint: Text(
                                l10n.selectCategory,
                                style: TextStyle(
                                  color: theme.disabledColor,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              isExpanded: true,
                              icon: Icon(
                                Icons.expand_more,
                                color: AppColors.of(context).textSecondary,
                              ),
                              items: options.map((category) {
                                return DropdownMenuItem<Category>(
                                  value: category,
                                  child: Text(category.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                  _selectedEducationLevel = null;
                                  _selectedStream = null;
                                  _selectedDepartment = null;
                                  _selectedClassOrSemester = null;
                                  _selectedBookType = null;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 24.h),

                    // Condition Field
                    Text(
                      l10n.condition,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.w,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _conditions.length,
                      itemBuilder: (context, index) {
                        final condition = _conditions[index];
                        final isSelected =
                            _selectedCondition == condition['value'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCondition = condition['value'] as String;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withOpacity(
                                      isDark ? 0.2 : 0.1,
                                    )
                                  : surfaceColor,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : borderColor,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  condition['icon'] as IconData,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : AppColors.of(context).iconMuted,
                                  size: 24.sp,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  _conditionLabel(
                                    l10n,
                                    condition['value'] as String,
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 24.h),

                    // Title Field
                    Text(
                      l10n.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _titleController,
                      maxLength: 50,
                      decoration: InputDecoration(
                        hintText: l10n.whatAreYouSellingHint,
                        hintStyle: TextStyle(
                          color: AppColors.of(context).textLight,
                        ),
                        filled: true,
                        fillColor: surfaceColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Description Field
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.description,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '0/500',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.of(context).textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: l10n.descriptionHint,
                        hintStyle: TextStyle(
                          color: AppColors.of(context).textLight,
                        ),
                        filled: true,
                        fillColor: surfaceColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),

                    // ── Book Details Section (textbooks / school_supplies) ────
                    if (showBookFields) ...[
                      SizedBox(height: 32.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(
                            isDark ? 0.08 : 0.05,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.menu_book_rounded,
                                  size: 20.sp,
                                  color: theme.colorScheme.primary,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  l10n.bookDetails,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              l10n.bookDetailsSubtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.of(context).textSecondary,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Education Level
                            Text(
                              l10n.educationLevel,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: _educationLevels.map((level) {
                                final isSelected =
                                    _selectedEducationLevel == level.key;
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
                                          ? theme.colorScheme.primary
                                          : surfaceColor,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : borderColor,
                                      ),
                                    ),
                                    child: Text(
                                      level.label,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.of(context).onPrimary
                                            : theme.textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            // Class / Semester
                            if (_selectedEducationLevel != null &&
                                _classOrSemesterOptions.isNotEmpty) ...[
                              SizedBox(height: 16.h),
                              Text(
                                _selectedEducationLevel == 'university'
                                    ? l10n.semester
                                    : l10n.classLabel,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                children: _classOrSemesterOptions.map((opt) {
                                  final isSelected =
                                      _selectedClassOrSemester == opt;
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
                                            ? theme.colorScheme.primary
                                            : surfaceColor,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : borderColor,
                                        ),
                                      ),
                                      child: Text(
                                        opt,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? AppColors.of(context).onPrimary
                                              : theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],

                            // Streams
                            if (_selectedEducationLevel != null &&
                                _streamOptions.isNotEmpty) ...[
                              SizedBox(height: 16.h),
                              Text(
                                'Stream / Department',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                children: _streamOptions.map((opt) {
                                  final isSelected =
                                      _selectedStream == opt.key;
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
                                            ? theme.colorScheme.primary
                                            : surfaceColor,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : borderColor,
                                        ),
                                      ),
                                      child: Text(
                                        opt.label,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? AppColors.of(context).onPrimary
                                              : theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],

                            // Departments
                            if (_selectedStream != null &&
                                _departmentOptions.isNotEmpty) ...[
                              SizedBox(height: 16.h),
                              Text(
                                'Department',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                children: _departmentOptions.map((opt) {
                                  final isSelected =
                                      _selectedDepartment == opt.key;
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
                                            ? theme.colorScheme.primary
                                            : surfaceColor,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : borderColor,
                                        ),
                                      ),
                                      child: Text(
                                        opt.label,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? AppColors.of(context).onPrimary
                                              : theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],

                            // Subject
                            SizedBox(height: 16.h),
                            Text(
                              l10n.subjectOptional,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextField(
                              controller: _subjectController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                hintText: l10n.subjectHint,
                                hintStyle: TextStyle(
                                  color: AppColors.of(context).textLight,
                                ),
                                filled: true,
                                fillColor: surfaceColor,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),

                            // Book Type
                            SizedBox(height: 16.h),
                            Text(
                              l10n.bookType,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: _bookTypes.map((bt) {
                                final isSelected = _selectedBookType == bt.key;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedBookType = bt.key;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 7.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : surfaceColor,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : borderColor,
                                      ),
                                    ),
                                    child: Text(
                                      bt.label,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.of(context).onPrimary
                                            : theme.textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withOpacity(0.9),
          border: Border(top: BorderSide(color: AppColors.of(context).border)),
          boxShadow: [
            BoxShadow(
              color: AppColors.of(context).textPrimary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedCategory == null) {
                  AppSnackBar.showWarning(context, l10n.categoryRequired);
                  return;
                }
                if (_titleController.text.isEmpty) {
                  AppSnackBar.showWarning(context, l10n.titleRequired);
                  return;
                }
                if (_descriptionController.text.isEmpty) {
                  AppSnackBar.showWarning(context, l10n.descriptionRequired);
                  return;
                }

                context.read<CreateListingBloc>().add(
                  DetailsUpdated(
                    title: _titleController.text,
                    category: _selectedCategory!.slug,
                    condition: _selectedCondition,
                    description: _descriptionController.text,
                    educationLevel: showBookFields
                        ? _selectedEducationLevel
                        : null,
                    stream: showBookFields
                        ? _selectedStream
                        : null,
                    department: showBookFields
                        ? _selectedDepartment
                        : null,
                    classOrSemester: showBookFields
                        ? _selectedClassOrSemester
                        : null,
                    subject:
                        showBookFields && _subjectController.text.isNotEmpty
                        ? _subjectController.text
                        : null,
                    bookType: showBookFields ? _selectedBookType : null,
                  ),
                );

                context.push(AppRouter.createListingPrice);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: AppColors.of(context).onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 4,
                shadowColor: theme.colorScheme.primary.withOpacity(0.25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.nextPricePickup,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward, size: 20.sp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
