import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/education_config.dart';
import '../../domain/entities/category.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Education Config State
  List<Map<String, dynamic>> _levels = [];
  List<Map<String, dynamic>> _bookTypes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<CategoryBloc>().add(LoadConfigEvent());
    context.read<CategoryBloc>().add(const LoadCategoriesEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _syncFromConfig(EducationConfig config) {
    _levels = config.levels
        .map(
          (l) => {
            'key': l.key ?? '',
            'label': l.label ?? '',
            'subLevels': l.subLevels
                .map((s) => {'key': s.key ?? '', 'label': s.label ?? ''})
                .toList(),
          },
        )
        .toList();
    _bookTypes = config.bookTypes
        .map((b) => {'key': b.key ?? '', 'label': b.label ?? ''})
        .toList();
  }

  EducationConfig _buildConfig() {
    return EducationConfig(
      levels: _levels
          .map(
            (l) => EducationLevel(
              key: l['key'],
              label: l['label'],
              subLevels: (l['subLevels'] as List)
                  .map((s) => SubLevel(key: s['key'], label: s['label']))
                  .toList(),
            ),
          )
          .toList(),
      bookTypes: _bookTypes
          .map((b) => BookType(key: b['key'], label: b['label']))
          .toList(),
    );
  }

  void _saveConfig() {
    context.read<CategoryBloc>().add(SaveConfigEvent(_buildConfig()));
  }

  // ═══════════════════════════════════════════════════════════
  // ─── EDUCATION DIALOGS ───────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  void _addLevel() {
    final keyCtl = TextEditingController();
    final labelCtl = TextEditingController();
    _showFormDialog(
      title: 'Add Education Level',
      icon: Icons.school_rounded,
      iconColor: AppColors.primary,
      fields: [
        _buildTextField(keyCtl, 'Key', hint: 'e.g., school'),
        _buildTextField(labelCtl, 'Label', hint: 'e.g., School'),
      ],
      onConfirm: () {
        if (keyCtl.text.isNotEmpty && labelCtl.text.isNotEmpty) {
          setState(() {
            _levels.add({
              'key': keyCtl.text.trim(),
              'label': labelCtl.text.trim(),
              'subLevels': <Map<String, dynamic>>[],
            });
          });
        }
      },
    );
  }

  void _addSubLevel(int levelIndex) {
    final keyCtl = TextEditingController();
    final labelCtl = TextEditingController();
    _showFormDialog(
      title: 'Add Sub-Level',
      icon: Icons.subdirectory_arrow_right_rounded,
      iconColor: AppColors.success,
      fields: [
        _buildTextField(keyCtl, 'Key', hint: 'e.g., class-6'),
        _buildTextField(labelCtl, 'Label', hint: 'e.g., Class 6'),
      ],
      onConfirm: () {
        if (keyCtl.text.isNotEmpty && labelCtl.text.isNotEmpty) {
          setState(() {
            (_levels[levelIndex]['subLevels'] as List).add({
              'key': keyCtl.text.trim(),
              'label': labelCtl.text.trim(),
            });
          });
        }
      },
    );
  }

  void _addBookType() {
    final keyCtl = TextEditingController();
    final labelCtl = TextEditingController();
    _showFormDialog(
      title: 'Add Book Type',
      icon: Icons.menu_book_rounded,
      iconColor: AppColors.info,
      fields: [
        _buildTextField(keyCtl, 'Key', hint: 'e.g., nctb'),
        _buildTextField(labelCtl, 'Label', hint: 'e.g., NCTB'),
      ],
      onConfirm: () {
        if (keyCtl.text.isNotEmpty && labelCtl.text.isNotEmpty) {
          setState(() {
            _bookTypes.add({
              'key': keyCtl.text.trim(),
              'label': labelCtl.text.trim(),
            });
          });
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── CATEGORY DIALOGS ────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  void _showAddCategoryDialog() {
    final nameCtl = TextEditingController();
    final descCtl = TextEditingController();
    final orderCtl = TextEditingController(text: '0');

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => _CategoryFormDialog(
        title: 'New Category',
        nameController: nameCtl,
        descriptionController: descCtl,
        orderController: orderCtl,
        existingImageUrl: null,
        initialHasEducationConfig: false,
        isEditMode: false,
        onConfirm: (Uint8List? imageBytes, bool hasEducationConfig) {
          if (nameCtl.text.isNotEmpty) {
            context.read<CategoryBloc>().add(
              CreateCategoryEvent(
                name: nameCtl.text.trim(),
                description: descCtl.text.trim().isEmpty
                    ? null
                    : descCtl.text.trim(),
                displayOrder: int.tryParse(orderCtl.text) ?? 0,
                imageBytes: imageBytes,
                hasEducationConfig: hasEducationConfig,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditCategoryDialog(Category category) {
    final nameCtl = TextEditingController(text: category.name);
    final descCtl = TextEditingController(text: category.description);
    final orderCtl = TextEditingController(
      text: category.displayOrder.toString(),
    );

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => _CategoryFormDialog(
        title: 'Edit Category',
        nameController: nameCtl,
        descriptionController: descCtl,
        orderController: orderCtl,
        existingImageUrl: category.image,
        initialHasEducationConfig: category.hasEducationConfig,
        isEditMode: true,
        onConfirm: (Uint8List? imageBytes, bool hasEducationConfig) {
          if (nameCtl.text.isNotEmpty) {
            context.read<CategoryBloc>().add(
              UpdateCategoryEvent(
                id: category.id,
                name: nameCtl.text.trim(),
                description: descCtl.text.trim().isEmpty
                    ? null
                    : descCtl.text.trim(),
                displayOrder: int.tryParse(orderCtl.text) ?? 0,
                imageBytes: imageBytes,
                hasEducationConfig: hasEducationConfig,
              ),
            );
          }
        },
      ),
    );
  }

  void _confirmDelete(Category category) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 340.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Danger header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.error.withAlpha(context.isDark ? 35 : 20),
                      AppColors.error.withAlpha(context.isDark ? 15 : 8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(
                          context.isDark ? 50 : 30,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: AppColors.error,
                        size: 28,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Delete Category',
                      style: AppTextStyles.h4.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: context.textSecondary,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Are you sure you want to delete ',
                          ),
                          TextSpan(
                            text: '"${category.name}"',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: context.textPrimary,
                            ),
                          ),
                          const TextSpan(
                            text:
                                '? This action cannot be undone and all associated listings will be affected.',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.textSecondary,
                              side: BorderSide(color: context.cardBorder),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.md,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                            ),
                            child: Text(
                              'Cancel',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: context.textMuted,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<CategoryBloc>().add(
                                DeleteCategoryEvent(category.id),
                              );
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.md,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.delete_outline, size: 18),
                                SizedBox(width: 6.w),
                                Text(
                                  'Delete',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Education form dialog
  void _showFormDialog({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> fields,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 340.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(context.isDark ? 20 : 12),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: iconColor.withAlpha(context.isDark ? 40 : 25),
                        borderRadius: AppRadius.md,
                      ),
                      child: Icon(icon, color: iconColor, size: 22),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Text(
                      title,
                      style: AppTextStyles.h4.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(mainAxisSize: MainAxisSize.min, children: fields),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.w),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.textSecondary,
                          side: BorderSide(color: context.cardBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.md,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: context.textMuted,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onConfirm();
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: iconColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.md,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          elevation: 0,
                        ),
                        child: Text(
                          'Confirm',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    String? hint,
    bool isRequired = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: context.textSecondary,
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTextStyles.bodyMedium.copyWith(
              color: context.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: context.textMuted,
              ),
              filled: true,
              fillColor: context.surface,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.sm,
                borderSide: BorderSide(color: context.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.sm,
                borderSide: BorderSide(color: context.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.sm,
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── BUILD ───────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryLoaded) {
          _syncFromConfig(state.config);
          if (state.categoryError != null) {
            _showSnack(state.categoryError!, isError: true);
          }
        } else if (state is CategorySaved || state is CategoryActionSuccess) {
          final message = (state is CategoryActionSuccess)
              ? state.message
              : 'Configuration saved successfully!';
          _showSnack(message);
          if (state is CategorySaved) {
            context.read<CategoryBloc>().add(LoadConfigEvent());
          }
        } else if (state is CategoryError) {
          _showSnack(state.message, isError: true);
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            _buildHeader(state),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildListingCategoriesTab(state),
                  _buildEducationConfigTab(state),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: AppRadius.xs,
              ),
              child: Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
        margin: EdgeInsets.all(AppSpacing.lg),
        elevation: 8,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── HEADER ──────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Widget _buildHeader(CategoryState state) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(bottom: BorderSide(color: context.cardBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(context.isDark ? 12 : 6),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: AppRadius.md,
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: AppRadius.sm,
                  boxShadow: AppShadows.sm,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: context.textPrimary,
                unselectedLabelColor: context.textMuted,
                labelStyle: AppTextStyles.labelMedium,
                unselectedLabelStyle: AppTextStyles.labelMedium,
                dividerColor: Colors.transparent,
                indicatorPadding: EdgeInsets.all(3.w),
                onTap: (_) => setState(() {}),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.grid_view_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('Categories'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.school_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('Education'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── LISTING CATEGORIES TAB ──────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Widget _buildListingCategoriesTab(CategoryState state) {
    if (state is CategoryLoading && state is! CategoryLoaded) {
      return _buildCategoryShimmerGrid();
    }

    if (state is CategoryLoaded) {
      if (state.isCategoriesLoading && state.categories.isEmpty) {
        return _buildCategoryShimmerGrid();
      }

      if (state.categories.isEmpty) {
        return EmptyState(
          icon: Icons.category_outlined,
          title: 'No categories yet',
          subtitle: 'Create your first category to organize listings.',
          actionLabel: 'Add Category',
          onAction: _showAddCategoryDialog,
        );
      }

      return RefreshIndicator(
        onRefresh: () async =>
            context.read<CategoryBloc>().add(const LoadCategoriesEvent()),
        color: AppColors.primary,
        child: AnimationLimiter(
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14.w,
              mainAxisSpacing: 14.h,
              childAspectRatio: 0.82,
            ),
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredGrid(
                position: index,
                columnCount: 2,
                duration: const Duration(milliseconds: 400),
                child: ScaleAnimation(
                  scale: 0.92,
                  child: FadeInAnimation(
                    child: _buildPremiumCategoryCard(state.categories[index]),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return const EmptyState(
      icon: Icons.hourglass_empty_rounded,
      title: 'Loading...',
      subtitle: 'Please wait while data loads.',
    );
  }

  Widget _buildCategoryShimmerGrid() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14.w,
          mainAxisSpacing: 14.h,
          childAspectRatio: 0.82,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: context.isDark
                ? Colors.white.withAlpha(8)
                : Colors.grey.withAlpha(30),
            highlightColor: context.isDark
                ? Colors.white.withAlpha(20)
                : Colors.grey.withAlpha(15),
            child: Container(
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: AppRadius.xl,
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── PREMIUM CATEGORY CARD ───────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Widget _buildPremiumCategoryCard(Category category) {
    final accentColor = _getCategoryAccentColor(category.name);
    final hasImage = category.image != null && category.image!.isNotEmpty;

    return GestureDetector(
      onTap: () => _showEditCategoryDialog(category),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: AppRadius.xl,
          border: Border.all(
            color: category.isActive
                ? accentColor.withAlpha(context.isDark ? 40 : 22)
                : context.cardBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: (category.isActive ? accentColor : Colors.black).withAlpha(
                context.isDark ? 12 : 8,
              ),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image Area ──
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background: image or gradient
                  if (hasImage)
                    CachedNetworkImage(
                      imageUrl: category.image!,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accentColor.withAlpha(context.isDark ? 40 : 25),
                              accentColor.withAlpha(context.isDark ? 20 : 12),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (ctx, url, err) =>
                          _buildCategoryGradientBg(accentColor, category.name),
                    )
                  else
                    _buildCategoryGradientBg(accentColor, category.name),

                  // Top-right: status + menu
                  Positioned(
                    top: 8.w,
                    right: 8.w,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Status pill
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: AppRadius.full,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  color: category.isActive
                                      ? AppColors.success
                                      : AppColors.warning,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (category.isActive
                                                  ? AppColors.success
                                                  : AppColors.warning)
                                              .withAlpha(100),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                category.isActive ? 'Active' : 'Hidden',
                                style: AppTextStyles.overline.copyWith(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 4.w),
                        _buildCardMenu(category),
                      ],
                    ),
                  ),

                  // Bottom gradient
                  if (hasImage)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 40.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(90),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Listing count badge
                  if (category.listingCount > 0)
                    Positioned(
                      bottom: 8.w,
                      left: 8.w,
                      child: ClipRRect(
                        borderRadius: AppRadius.xs,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(hasImage ? 80 : 40),
                              borderRadius: AppRadius.xs,
                              border: Border.all(
                                color: Colors.white.withAlpha(20),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_stories_rounded,
                                  size: 10,
                                  color: Colors.white.withAlpha(200),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${category.listingCount}',
                                  style: AppTextStyles.overline.copyWith(
                                    color: Colors.white,
                                    fontSize: 9.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info Footer ──
            Container(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 8.w, 10.h),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.cardBorder)),
              ),
              child: Row(
                children: [
                  // Accent dot
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Name + description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (category.description != null &&
                            category.description!.isNotEmpty)
                          Text(
                            category.description!,
                            style: AppTextStyles.overline.copyWith(
                              color: context.textMuted,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          Text(
                            'Order ${category.displayOrder}',
                            style: AppTextStyles.overline.copyWith(
                              color: context.textMuted,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Toggle
                  SizedBox(
                    height: 24.h,
                    width: 40.w,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Switch(
                        value: category.isActive,
                        onChanged: (val) => context.read<CategoryBloc>().add(
                          ToggleCategoryStatusEvent(category.id),
                        ),
                        activeThumbColor: AppColors.success,
                        activeTrackColor: AppColors.success.withAlpha(80),
                        inactiveThumbColor: context.textMuted,
                        inactiveTrackColor: context.cardBorder,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGradientBg(Color color, String name) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withAlpha(context.isDark ? 60 : 40),
            color.withAlpha(context.isDark ? 30 : 18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: color.withAlpha(context.isDark ? 40 : 25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.category_rounded,
                color: color.withAlpha(context.isDark ? 200 : 160),
                size: 28,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'No image',
              style: AppTextStyles.overline.copyWith(
                color: color.withAlpha(context.isDark ? 180 : 120),
                fontSize: 9.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardMenu(Category category) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
      color: context.cardColor,
      elevation: 12,
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: AppRadius.xs,
        ),
        child: Icon(
          Icons.more_horiz_rounded,
          color: Colors.white.withAlpha(220),
          size: 14,
        ),
      ),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'edit',
          height: 40.h,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: AppColors.info.withAlpha(context.isDark ? 30 : 15),
                  borderRadius: AppRadius.xs,
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 14,
                  color: AppColors.info,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Edit',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle',
          height: 40.h,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color:
                      (category.isActive
                              ? AppColors.warning
                              : AppColors.success)
                          .withAlpha(context.isDark ? 30 : 15),
                  borderRadius: AppRadius.xs,
                ),
                child: Icon(
                  category.isActive
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 14,
                  color: category.isActive
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                category.isActive ? 'Hide' : 'Show',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 8),
        PopupMenuItem(
          value: 'delete',
          height: 40.h,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(context.isDark ? 30 : 15),
                  borderRadius: AppRadius.xs,
                ),
                child: const Icon(
                  Icons.delete_rounded,
                  size: 14,
                  color: AppColors.error,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Delete',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (val) {
        if (val == 'edit') {
          _showEditCategoryDialog(category);
        } else if (val == 'toggle') {
          context.read<CategoryBloc>().add(
            ToggleCategoryStatusEvent(category.id),
          );
        } else if (val == 'delete') {
          _confirmDelete(category);
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── EDUCATION CONFIG TAB ────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Widget _buildEducationConfigTab(CategoryState state) {
    final isSaving = state is CategorySaving;

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<CategoryBloc>().add(LoadConfigEvent()),
      color: AppColors.primary,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
        children: [
          // Save Header Card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withAlpha(context.isDark ? 25 : 15),
                  AppColors.primaryDark.withAlpha(context.isDark ? 15 : 8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.lg,
              border: Border.all(
                color: AppColors.primary.withAlpha(context.isDark ? 40 : 25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(
                      context.isDark ? 40 : 20,
                    ),
                    borderRadius: AppRadius.md,
                  ),
                  child: const Icon(
                    Icons.settings_suggest_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Education Layout',
                        style: AppTextStyles.h4.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        'Configure search filters for the app',
                        style: AppTextStyles.caption.copyWith(
                          color: context.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildSaveButton(isSaving),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // ── Levels Section ──
          _buildSectionHeader(
            'Education Levels',
            Icons.school_rounded,
            AppColors.primary,
            _addLevel,
          ),
          SizedBox(height: 12.h),
          if (_levels.isEmpty)
            _buildEmptySection(
              'No levels configured',
              'Add education levels to organize book categories.',
            ),
          ...List.generate(_levels.length, (li) {
            final level = _levels[li];
            return AnimationConfiguration.staggeredList(
              position: li,
              duration: const Duration(milliseconds: 300),
              child: SlideAnimation(
                horizontalOffset: 30,
                child: FadeInAnimation(child: _buildLevelCard(li, level)),
              ),
            );
          }),

          SizedBox(height: 28.h),

          // ── Book Types Section ──
          _buildSectionHeader(
            'Book Types',
            Icons.menu_book_rounded,
            AppColors.info,
            _addBookType,
          ),
          SizedBox(height: 12.h),
          if (_bookTypes.isEmpty)
            _buildEmptySection(
              'No book types configured',
              'Add book types like NCTB, Notes, etc.',
            ),
          if (_bookTypes.isNotEmpty)
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: List.generate(_bookTypes.length, (i) {
                final bt = _bookTypes[i];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: AppRadius.sm,
                      border: Border.all(color: context.cardBorder),
                      boxShadow: AppShadows.sm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: AppColors.info.withAlpha(
                              context.isDark ? 30 : 15,
                            ),
                            borderRadius: AppRadius.xs,
                          ),
                          child: Icon(
                            Icons.auto_stories_rounded,
                            size: 14,
                            color: AppColors.info,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bt['label'] ?? '',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: context.textPrimary,
                              ),
                            ),
                            Text(
                              bt['key'] ?? '',
                              style: AppTextStyles.overline.copyWith(
                                color: context.textMuted,
                                fontSize: 9.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 8.w),
                        InkWell(
                          onTap: () => setState(() => _bookTypes.removeAt(i)),
                          borderRadius: AppRadius.full,
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: AppColors.error.withAlpha(15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isSaving) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isSaving ? null : _saveConfig,
        borderRadius: AppRadius.sm,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isSaving
                ? AppColors.success.withAlpha(60)
                : AppColors.success,
            borderRadius: AppRadius.sm,
            boxShadow: isSaving
                ? null
                : [
                    BoxShadow(
                      color: AppColors.success.withAlpha(40),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSaving)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withAlpha(200),
                  ),
                )
              else
                const Icon(Icons.save_rounded, size: 18, color: Colors.white),
              SizedBox(width: 8.w),
              Text(
                isSaving ? 'Saving...' : 'Save',
                style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    Color color,
    VoidCallback onAdd,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: color.withAlpha(context.isDark ? 30 : 15),
            borderRadius: AppRadius.xs,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(color: context.textPrimary),
        ),
        const Spacer(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onAdd,
            borderRadius: AppRadius.full,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: color.withAlpha(context.isDark ? 25 : 12),
                borderRadius: AppRadius.full,
                border: Border.all(
                  color: color.withAlpha(context.isDark ? 50 : 30),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 16, color: color),
                  SizedBox(width: 4.w),
                  Text(
                    'Add',
                    style: AppTextStyles.labelSmall.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySection(String title, String subtitle) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: context.cardBorder),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 32,
            color: context.textMuted.withAlpha(100),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(color: context.textMuted),
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: context.textMuted.withAlpha(150),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(int li, Map<String, dynamic> level) {
    final subLevels = level['subLevels'] as List;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.lg,
        border: Border.all(color: context.cardBorder),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 8.w, 0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withAlpha(context.isDark ? 40 : 25),
                        AppColors.primaryDark.withAlpha(
                          context.isDark ? 25 : 12,
                        ),
                      ],
                    ),
                    borderRadius: AppRadius.xs,
                    border: Border.all(
                      color: AppColors.primary.withAlpha(
                        context.isDark ? 50 : 30,
                      ),
                    ),
                  ),
                  child: Text(
                    level['key'] ?? '',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.primary,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    level['label'] ?? '',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(
                        context.isDark ? 30 : 15,
                      ),
                      borderRadius: AppRadius.xs,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: AppColors.success,
                    ),
                  ),
                  onPressed: () => _addSubLevel(li),
                  tooltip: 'Add Sub-Level',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.all(4.w),
                ),
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(
                        context.isDark ? 30 : 15,
                      ),
                      borderRadius: AppRadius.xs,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: AppColors.error,
                    ),
                  ),
                  onPressed: () => setState(() => _levels.removeAt(li)),
                  tooltip: 'Delete Level',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.all(4.w),
                ),
              ],
            ),
          ),
          if (subLevels.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
              child: Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: List.generate(subLevels.length, (si) {
                  final sub = subLevels[si];
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: AppRadius.xs,
                      border: Border.all(color: context.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          sub['label'] ?? '',
                          style: AppTextStyles.caption.copyWith(
                            color: context.textPrimary,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        InkWell(
                          onTap: () => setState(() => subLevels.removeAt(si)),
                          borderRadius: AppRadius.full,
                          child: Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: context.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ] else
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 14.h),
              child: Text(
                'No sub-levels yet — tap + to add',
                style: AppTextStyles.caption.copyWith(
                  color: context.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── HELPERS ─────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Color _getCategoryAccentColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('book') || lower.contains('text')) {
      return AppColors.info;
    }
    if (lower.contains('hous') || lower.contains('room')) {
      return AppColors.success;
    }
    if (lower.contains('service') || lower.contains('tutor')) {
      return const Color(0xFF8B5CF6);
    }
    if (lower.contains('event')) return AppColors.warning;
    if (lower.contains('tech') || lower.contains('gadget')) {
      return AppColors.accent;
    }
    return AppColors.primary;
  }
}

// ═══════════════════════════════════════════════════════════════
// ─── PREMIUM CATEGORY FORM DIALOG ───────────────────────────
// ═══════════════════════════════════════════════════════════════
class _CategoryFormDialog extends StatefulWidget {
  final String title;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController orderController;
  final String? existingImageUrl;
  final bool initialHasEducationConfig;
  final bool isEditMode;
  final void Function(Uint8List? imageBytes, bool hasEducationConfig) onConfirm;

  const _CategoryFormDialog({
    required this.title,
    required this.nameController,
    required this.descriptionController,
    required this.orderController,
    required this.existingImageUrl,
    required this.initialHasEducationConfig,
    this.isEditMode = false,
    required this.onConfirm,
  });

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog>
    with SingleTickerProviderStateMixin {
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;
  bool _hasEducationConfig = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _hasEducationConfig = widget.initialHasEducationConfig;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isPicking) return;
    _isPicking = true;
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedImage = picked;
          _selectedImageBytes = bytes;
        });
      }
    } catch (_) {
      // Silently handle picker errors (e.g. already_active)
    } finally {
      _isPicking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEditMode;
    final accentColor = isEdit ? AppColors.info : AppColors.primary;

    return ScaleTransition(
      scale: _scaleAnim,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Container(
          width: 400.w,
          constraints: BoxConstraints(maxHeight: 580.h),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: AppRadius.xxl,
            boxShadow: [
              BoxShadow(
                color: accentColor.withAlpha(context.isDark ? 30 : 20),
                blurRadius: 40,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withAlpha(context.isDark ? 60 : 25),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Image Header Area ──
                _buildDialogImageHeader(context, accentColor, isEdit),

                // ── Form Fields ──
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                  child: Column(
                    children: [
                      _buildPremiumField(
                        context,
                        controller: widget.nameController,
                        label: 'Category Name',
                        hint: 'e.g., Textbooks',
                        icon: Icons.label_rounded,
                        isRequired: true,
                      ),
                      SizedBox(height: 14.h),
                      _buildPremiumField(
                        context,
                        controller: widget.descriptionController,
                        label: 'Description',
                        hint: 'Short description...',
                        icon: Icons.notes_rounded,
                        maxLines: 2,
                      ),
                      SizedBox(height: 14.h),
                      _buildPremiumField(
                        context,
                        controller: widget.orderController,
                        label: 'Display Order',
                        hint: '0',
                        icon: Icons.sort_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 14.h),
                      Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(unselectedWidgetColor: context.textMuted),
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Requires Education Details (e.g. for Textbooks)',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: context.textPrimary,
                            ),
                          ),
                          activeColor: accentColor,
                          checkColor: Colors.white,
                          value: _hasEducationConfig,
                          onChanged: (val) {
                            setState(() {
                              _hasEducationConfig = val ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // ── Actions ──
                Container(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: context.textSecondary,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.md,
                              side: BorderSide(color: context.cardBorder),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: context.textMuted,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onConfirm(
                              _selectedImageBytes,
                              _hasEducationConfig,
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.md,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isEdit
                                    ? Icons.check_rounded
                                    : Icons.add_rounded,
                                size: 18,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                isEdit ? 'Update Category' : 'Create Category',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogImageHeader(
    BuildContext context,
    Color accentColor,
    bool isEdit,
  ) {
    final hasExisting =
        widget.existingImageUrl != null && widget.existingImageUrl!.isNotEmpty;
    final hasLocal = _selectedImage != null;
    final hasAnyImage = hasLocal || hasExisting;

    // ── When there's an image (local or existing) → full-bleed ──
    if (hasAnyImage) {
      return GestureDetector(
        onTap: _pickImage,
        child: SizedBox(
          width: double.infinity,
          height: 190.h,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasLocal)
                Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
              else
                CachedNetworkImage(
                  imageUrl: widget.existingImageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (ctx, url) => Container(
                    color: context.surface,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: accentColor,
                      ),
                    ),
                  ),
                  errorWidget: (ctx, url, err) => Container(
                    color: context.surface,
                    child: Icon(
                      Icons.broken_image_rounded,
                      size: 40,
                      color: context.textMuted,
                    ),
                  ),
                ),

              // Dark scrim
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(30),
                      Colors.black.withAlpha(140),
                    ],
                  ),
                ),
              ),

              // Title chip (bottom-left)
              Positioned(
                bottom: 14.w,
                left: 14.w,
                child: ClipRRect(
                  borderRadius: AppRadius.sm,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(90),
                        borderRadius: AppRadius.sm,
                        border: Border.all(color: Colors.white.withAlpha(25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isEdit
                                ? Icons.edit_rounded
                                : Icons.add_circle_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            widget.title,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Change image button (top-right)
              Positioned(
                top: 14.w,
                right: 14.w,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: AppRadius.sm,
                      border: Border.all(color: Colors.white.withAlpha(40)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'Change',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // NEW badge
              if (hasLocal)
                Positioned(
                  bottom: 14.w,
                  right: 14.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: AppRadius.xs,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withAlpha(80),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'NEW',
                      style: AppTextStyles.overline.copyWith(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // ── Empty state → distinct upload zone ──
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
        padding: EdgeInsets.symmetric(vertical: 28.h),
        decoration: BoxDecoration(
          color: context.isDark
              ? Colors.white.withAlpha(6)
              : accentColor.withAlpha(8),
          borderRadius: AppRadius.lg,
          border: Border.all(
            color: accentColor.withAlpha(context.isDark ? 60 : 40),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Upload icon
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(context.isDark ? 30 : 18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withAlpha(context.isDark ? 50 : 35),
                ),
              ),
              child: Icon(
                Icons.cloud_upload_rounded,
                color: accentColor,
                size: 30,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'Upload Category Image',
              style: AppTextStyles.labelLarge.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'PNG, JPG up to 2 MB · 400×400 recommended',
              style: AppTextStyles.caption.copyWith(color: context.textMuted),
            ),
            SizedBox(height: 14.h),
            // Browse button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: AppRadius.sm,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withAlpha(50),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.photo_library_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Browse Gallery',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // _buildDialogImagePlaceholder removed — empty state is now inline in _buildDialogImageHeader

  Widget _buildPremiumField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: context.textMuted),
            SizedBox(width: 6.w),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: context.textSecondary,
              ),
            ),
            if (isRequired) ...[
              SizedBox(width: 4.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(15),
                  borderRadius: AppRadius.xs,
                ),
                child: Text(
                  'Required',
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.error,
                    fontSize: 8.sp,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppTextStyles.bodyMedium.copyWith(color: context.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: context.textMuted,
            ),
            filled: true,
            fillColor: context.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(color: context.cardBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
