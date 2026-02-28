import 'package:book_user_app/features/categories/domain/entities/category.dart';
import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:book_user_app/features/categories/presentation/bloc/categories_event.dart';
import 'package:book_user_app/features/categories/presentation/bloc/categories_state.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_event.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategorySelector extends StatefulWidget {
  const CategorySelector({super.key});

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  @override
  void initState() {
    super.initState();
    // Load categories when widget initializes
    context.read<CategoriesBloc>().add(const CategoriesLoadRequested());
  }

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

            // Show loading state
            if (categoriesState is CategoriesLoading) {
              return _buildShimmerLoader();
            }

            // Show error state with retry
            if (categoriesState is CategoriesError) {
              return _buildErrorState(categoriesState.message);
            }

            // Show categories
            if (categoriesState is CategoriesLoaded) {
              return _buildCategoryList(
                categoriesState.categories,
                selectedCategory,
              );
            }

            // Initial state - show shimmer
            return _buildShimmerLoader();
          },
        );
      },
    );
  }

  Widget _buildShimmerLoader() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: List.generate(5, (index) {
          return Container(
            height: 48.h,
            width: 100.w,
            margin: EdgeInsets.only(right: 12.w),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(50.r),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: GestureDetector(
        onTap: () {
          context.read<CategoriesBloc>().add(
            const CategoriesRefreshRequested(),
          );
        },
        child: Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(50.r),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh, size: 18.sp, color: Colors.red[400]),
              SizedBox(width: 8.w),
              Text(
                "Tap to retry",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    List<Category> categories,
    String? selectedCategory,
  ) {
    final displayCategories = categories.take(10).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 4.h), // Minimal top gap
        itemCount: displayCategories.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 5.w,
          mainAxisSpacing: 8.h,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          final category = displayCategories[index];
          final isSelected = selectedCategory == category.slug;
          return _buildCategoryItem(
            label: category.name,
            icon: _getIcon(category.icon),
            hasImage: category.image != null && category.image!.isNotEmpty,
            imageUrl: category.image,
            isSelected: isSelected,
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

  Widget _buildCategoryItem({
    required String label,
    IconData? icon,
    required bool isSelected,
    required bool hasImage,
    String? imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 65.w, // Total outer size
            height: 65.w,
            padding: EdgeInsets.all(
              4.w,
            ), // The white gap between border and image
            decoration: BoxDecoration(
              color: Colors.white, // Inner gap color
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppPalette.primary
                    : Colors.grey[300]!, // Outer ring
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Container(
              // Inner container that holds the image/icon and its background color
              decoration: BoxDecoration(
                color: isSelected
                    ? AppPalette.primary
                    : AppPalette.gray100, // Background for icon fallback
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              clipBehavior: Clip.antiAlias,
              // Add padding inside the background circle so the image/icon doesn't touch the edge
              padding: EdgeInsets.all(2.w),
              child: hasImage && imageUrl != null
                  ? ClipOval(
                      // Ensure the inner image stays circular
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          icon ?? Icons.category_rounded,
                          size: 20.sp,
                          color: isSelected
                              ? Colors.white
                              : AppPalette.textSecondary,
                        ),
                      ),
                    )
                  : Icon(
                      icon ?? Icons.category_rounded,
                      size: 20.sp,
                      color: isSelected
                          ? Colors.white
                          : AppPalette.textSecondary,
                    ),
            ),
          ),
          SizedBox(height: 6.h), // Reduced spacing between circle and label
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? AppPalette.textPrimary
                  : AppPalette.textSecondary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
