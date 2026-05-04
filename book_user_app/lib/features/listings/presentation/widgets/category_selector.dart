import 'package:book_user_app/features/categories/domain/entities/category.dart';
import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:book_user_app/features/categories/presentation/bloc/categories_event.dart';
import 'package:book_user_app/features/categories/presentation/bloc/categories_state.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_event.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:book_user_app/core/widgets/press_scale.dart';

class CategorySelector extends StatefulWidget {
  const CategorySelector({super.key});

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  @override
  void initState() {
    super.initState();
    // Required: without this, bloc stays Initial and we only show gray placeholders.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<CategoriesBloc>();
      final s = bloc.state;
      if (s is CategoriesInitial || s is CategoriesError) {
        bloc.add(const CategoriesLoadRequested());
      }
    });
  }

  // Removed pastel pairs for a cleaner, minimalist design

  IconData _getIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'menu_book':
      case 'textbooks':
        return Icons.menu_book_rounded;
      case 'laptop':
      case 'electronics':
        return Icons.laptop_mac_rounded;
      case 'chair':
      case 'furniture':
        return Icons.chair_rounded;
      case 'checkroom':
      case 'clothing':
        return Icons.checkroom_rounded;
      case 'sports':
        return Icons.sports_basketball_rounded;
      case 'music_note':
      case 'music':
        return Icons.music_note_rounded;
      case 'palette':
      case 'art':
        return Icons.palette_rounded;
      case 'category':
      case 'other':
      default:
        return Icons.category_rounded;
    }
  }

  List<Color> _gradientFor(bool isDark, bool isSelected) {
    if (isSelected) {
      return [
        AppColors.of(context).primary.withOpacity(0.08),
        AppColors.of(context).primary.withOpacity(0.02),
      ];
    }
    if (isDark) {
      return [AppColors.of(context).subtleFill, AppColors.of(context).card];
    }
    return [AppColors.of(context).card, AppColors.of(context).card];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, categoriesState) {
        return BlocBuilder<ListingsBloc, ListingsState>(
          buildWhen: (previous, current) {
            return current is ListingsLoaded || current is ListingsLoading;
          },
          builder: (context, listingsState) {
            String? selectedCategory;
            if (listingsState is ListingsLoaded) {
              selectedCategory = listingsState.category;
            } else if (listingsState is ListingsLoading) {
              selectedCategory = listingsState.category;
            }

            if (categoriesState is CategoriesLoading) {
              return _buildShimmerLoader();
            }

            if (categoriesState is CategoriesError) {
              return _buildErrorState(categoriesState.message);
            }

            if (categoriesState is CategoriesLoaded) {
              return _buildCategoryGrid(
                categoriesState.categories,
                selectedCategory,
              );
            }

            return _buildShimmerLoader();
          },
        );
      },
    );
  }

  Widget _buildShimmerLoader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 0.88,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: AppColors.of(context).border.withOpacity(0.35),
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: GestureDetector(
        onTap: () {
          context.read<CategoriesBloc>().add(
            const CategoriesRefreshRequested(),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.of(context).error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.refresh,
                size: 18.sp,
                color: AppColors.of(context).error,
              ),
              SizedBox(width: 8.w),
              Text(
                'Tap to retry',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.of(context).error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(
    List<Category> categories,
    String? selectedCategory,
  ) {
    final displayCategories = categories.take(8).toList();
    final isDark = AppColors.of(context).isDark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 4.h, bottom: 4.h),
        itemCount: displayCategories.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 0.88,
        ),
        itemBuilder: (context, index) {
          final category = displayCategories[index];
          final isSelected = selectedCategory == category.slug;
          final gradient = _gradientFor(isDark, isSelected);
          return _CategoryCard(
            label: category.name,
            icon: _getIcon(category.icon),
            hasImage: category.image != null && category.image!.isNotEmpty,
            imageUrl: category.image,
            isSelected: isSelected,
            gradientColors: gradient,
            isDark: isDark,
            onTap: () {
              if (isSelected) {
                context.read<ListingsBloc>().add(
                  const ListingsFilterChanged(category: null),
                );
              } else {
                context.read<ListingsBloc>().add(
                  ListingsFilterChanged(category: category.slug),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.hasImage,
    this.imageUrl,
    required this.gradientColors,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final bool hasImage;
  final String? imageUrl;
  final List<Color> gradientColors;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return PressScale(
      hapticOnTap: false,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border.withOpacity(0.4),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(isDark ? 0.25 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 40.w,
                width: double.infinity,
                child: Center(
                  child: hasImage && imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl!,
                            width: 40.w,
                            height: 40.w,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Icon(
                              icon,
                              size: 28.sp,
                              color: colors.textPrimary.withOpacity(0.85),
                            ),
                          ),
                        )
                      : Icon(
                          icon,
                          size: 28.sp,
                          color: colors.textPrimary.withOpacity(0.88),
                        ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: colors.textPrimary,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
