import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:book_user_app/features/categories/presentation/bloc/categories_state.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_event.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // State variables
  // null means 'All' — stores the slug sent to the API, not the display name
  String? _selectedCategorySlug;
  RangeValues _priceRange = const RangeValues(0, 500);
  String? _selectedCondition; // null means all

  final double _minPriceLimit = 0;
  final double _maxPriceLimit = 1000;

  // Static data
  // Key = display label, Value = backend enum value
  final Map<String, String> _conditions = {
    'New': 'new',
    'Like New': 'like-new',
    'Good': 'good',
    'Fair': 'fair',
    'Poor': 'poor',
  };

  @override
  void initState() {
    super.initState();
    // Initialize state from current ListingsBloc state
    final state = context.read<ListingsBloc>().state;
    if (state is ListingsLoaded) {
      _selectedCategorySlug = state.category; // null = 'All'
      _priceRange = RangeValues(
        state.minPrice ?? _minPriceLimit,
        state.maxPrice ?? _maxPriceLimit,
      );
      _selectedCondition = state.condition;
    }
  }

  void _applyFilters() {
    // Preserve the active sort — sort is controlled by the inline SortFilterBar
    final current = context.read<ListingsBloc>().state;
    final currentSort = current is ListingsLoaded ? current.sortBy : null;
    final currentOrder = current is ListingsLoaded ? current.sortOrder : null;

    context.read<ListingsBloc>().add(
      ListingsFilterChanged(
        category: _selectedCategorySlug,
        minPrice: _priceRange.start.round().toDouble(),
        maxPrice: _priceRange.end.round().toDouble(),
        condition: _selectedCondition,
        sortBy: currentSort,
        sortOrder: currentOrder,
      ),
    );
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _selectedCategorySlug = null; // null = All
      _priceRange = const RangeValues(0, 1000);
      _selectedCondition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.85.sh, // Take up 85% of screen height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 12.h),
              width: 48.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Text(
                  "Filter & Sort",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "Reset",
                    style: TextStyle(
                      color: AppPalette.accent,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 100.h), // Space for fixed button
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Section
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Category",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppPalette.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        BlocBuilder<CategoriesBloc, CategoriesState>(
                          builder: (context, state) {
                            // Build list of {name, slug} pairs; 'All' has slug=null
                            final List<Map<String, String?>> categories = [
                              {'name': 'All', 'slug': null},
                            ];
                            if (state is CategoriesLoaded) {
                              for (final c in state.categories) {
                                categories.add({
                                  'name': c.name,
                                  'slug': c.slug,
                                });
                              }
                            }

                            return Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: categories.map((cat) {
                                final slug = cat['slug'];
                                final name = cat['name']!;
                                final isSelected =
                                    _selectedCategorySlug == slug;
                                return GestureDetector(
                                  onTap: () => setState(
                                    () => _selectedCategorySlug = slug,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppPalette.primary
                                          : AppPalette.gray50,
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : AppPalette.gray200,
                                      ),
                                    ),
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : AppPalette.textPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, indent: 24.w, endIndent: 24.w),

                  // Condition Section
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Condition",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppPalette.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: _conditions.entries.map((entry) {
                            final label = entry.key; // 'Like New'
                            final apiValue = entry.value; // 'like-new'
                            final isSelected = _selectedCondition == apiValue;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedCondition = null; // Toggle off
                                  } else {
                                    _selectedCondition = apiValue;
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppPalette.primary
                                      : AppPalette.gray50,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : AppPalette.gray200,
                                  ),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : AppPalette.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, indent: 24.w, endIndent: 24.w),

                  // Price Range Section
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Price Range",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppPalette.textPrimary,
                              ),
                            ),
                            Text(
                              "\$${_priceRange.start.round()} - \$${_priceRange.end.round()}",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppPalette.accent,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: AppPalette.accent,
                            inactiveTrackColor: AppPalette.gray200,
                            thumbColor: Colors.white,
                            trackHeight: 4.h,
                            rangeThumbShape: RoundRangeSliderThumbShape(
                              enabledThumbRadius: 12.r,
                              elevation: 2,
                            ),
                            overlayColor: AppPalette.accent.withOpacity(0.2),
                          ),
                          child: RangeSlider(
                            values: _priceRange,
                            min: _minPriceLimit,
                            max: _maxPriceLimit,
                            onChanged: (values) {
                              setState(() {
                                _priceRange = values;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPriceInput(
                                "Min Price",
                                _priceRange.start.round(),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: _buildPriceInput(
                                "Max Price",
                                _priceRange.end.round(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // (Sort is now available inline above the listings)
                ],
              ),
            ),
          ),

          // Sticky Footer
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppPalette.gray100)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Show Results",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInput(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppPalette.textSecondary,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppPalette.gray50,
            border: Border.all(color: AppPalette.gray200),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Text(
                "\$",
                style: TextStyle(
                  color: AppPalette.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
