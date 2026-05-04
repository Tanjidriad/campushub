import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_event.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_state.dart';
import 'package:book_user_app/features/listings/presentation/widgets/filter_bottom_sheet.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

/// Sort options: sortBy/sortOrder sent to API.
const _kSortOptions = [
  {'sortBy': null, 'sortOrder': null},
  {'sortBy': 'createdAt', 'sortOrder': 'desc'},
  {'sortBy': 'price', 'sortOrder': 'asc'},
  {'sortBy': 'price', 'sortOrder': 'desc'},
];

List<String> _sortLabels(AppLocalizations l10n) => [
  l10n.recommended,
  l10n.newestFirst,
  l10n.priceLowToHigh,
  l10n.priceHighToLow,
];

class SortFilterBar extends StatelessWidget {
  const SortFilterBar({super.key});

  void _openFilterSheet(BuildContext context) {
    final listingsBloc = context.read<ListingsBloc>();
    final categoriesBloc = context.read<CategoriesBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: listingsBloc),
          BlocProvider.value(value: categoriesBloc),
        ],
        child: const FilterBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ListingsBloc, ListingsState>(
      buildWhen: (prev, curr) =>
          curr is ListingsLoaded || curr is ListingsLoading,
      builder: (context, state) {
        final loaded = state is ListingsLoaded ? state : null;
        final labels = _sortLabels(l10n);
        final activeSort = _resolveActiveSort(loaded, labels);
        final chips = _buildActiveChips(loaded, context);
        final hasFilters = chips.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row: Sort dropdown + Filter button ──────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  // Sort pill dropdown
                  _SortDropdown(currentLabel: activeSort),
                  const Spacer(),
                  // Filter button
                  GestureDetector(
                    onTap: () => _openFilterSheet(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: hasFilters
                            ? AppColors.of(context).primary
                            : AppColors.of(context).card,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: hasFilters
                              ? AppColors.of(context).primary
                              : AppColors.of(context).border,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.of(
                              context,
                            ).textPrimary.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.filter,
                            size: 16.sp,
                            color: hasFilters
                                ? AppColors.of(context).onPrimary
                                : AppColors.of(context).textPrimary,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            hasFilters ? l10n.filtered : l10n.filter,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: hasFilters
                                  ? AppColors.of(context).onPrimary
                                  : AppColors.of(context).textPrimary,
                            ),
                          ),
                          if (hasFilters) ...[
                            SizedBox(width: 6.w),
                            Container(
                              width: 18.w,
                              height: 18.w,
                              decoration: BoxDecoration(
                                color: AppColors.of(context).card,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${chips.length}',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.of(context).primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Active filter chips ───────────────────────────────────────
            if (chips.isNotEmpty) ...[
              SizedBox(height: 10.h),
              SizedBox(
                height: 34.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: chips.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (_, i) => chips[i],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Returns the label of the currently active sort option.
  String _resolveActiveSort(ListingsLoaded? state, List<String> labels) {
    if (state == null) return labels[0];
    for (int i = 0; i < _kSortOptions.length; i++) {
      final opt = _kSortOptions[i];
      if (opt['sortBy'] == state.sortBy &&
          opt['sortOrder'] == state.sortOrder) {
        return labels[i];
      }
    }
    return labels[0];
  }

  /// Builds the active filter chips from the current state.
  List<Widget> _buildActiveChips(ListingsLoaded? state, BuildContext context) {
    if (state == null) return [];
    final chips = <Widget>[];

    if (state.category != null) {
      chips.add(
        _FilterChip(
          label: state.category!,
          onRemove: () => context.read<ListingsBloc>().add(
            ListingsFilterChanged(
              category: null,
              condition: state.condition,
              minPrice: state.minPrice,
              maxPrice: state.maxPrice,
              sortBy: state.sortBy,
              sortOrder: state.sortOrder,
            ),
          ),
        ),
      );
    }

    if (state.condition != null) {
      chips.add(
        _FilterChip(
          label: _conditionLabel(state.condition!),
          onRemove: () => context.read<ListingsBloc>().add(
            ListingsFilterChanged(
              category: state.category,
              condition: null,
              minPrice: state.minPrice,
              maxPrice: state.maxPrice,
              sortBy: state.sortBy,
              sortOrder: state.sortOrder,
            ),
          ),
        ),
      );
    }

    if (state.minPrice != null || state.maxPrice != null) {
      final min = state.minPrice?.round() ?? 0;
      final max = state.maxPrice?.round() ?? 1000;
      if (min != 0 || max != 1000) {
        chips.add(
          _FilterChip(
            label: '\$$min – \$$max',
            onRemove: () => context.read<ListingsBloc>().add(
              ListingsFilterChanged(
                category: state.category,
                condition: state.condition,
                minPrice: null,
                maxPrice: null,
                sortBy: state.sortBy,
                sortOrder: state.sortOrder,
              ),
            ),
          ),
        );
      }
    }

    return chips;
  }

  String _conditionLabel(String apiValue) {
    const map = {
      'new': 'New',
      'like-new': 'Like New',
      'good': 'Good',
      'fair': 'Fair',
      'poor': 'Poor',
    };
    return map[apiValue] ?? apiValue;
  }
}

// ── Sort Dropdown ─────────────────────────────────────────────────────────────

class _SortDropdown extends StatelessWidget {
  final String currentLabel;

  const _SortDropdown({required this.currentLabel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSortMenu(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.of(context).card,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.of(context).border),
          boxShadow: [
            BoxShadow(
              color: AppColors.of(context).textPrimary.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.sort,
              size: 16.sp,
              color: AppColors.of(context).textPrimary,
            ),
            SizedBox(width: 6.w),
            Text(
              currentLabel,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.of(context).textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18.sp,
              color: AppColors.of(context).textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showSortMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = _sortLabels(l10n);
    final listingsBloc = context.read<ListingsBloc>();
    final overlay = Overlay.of(context).context.findRenderObject()!;
    final box = context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero, ancestor: overlay);

    showMenu<Map<String, String?>>(
      context: context,
      color: AppColors.of(context).card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: AppColors.of(context).subtleFill),
      ),
      elevation: 8,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + box.size.height + 6,
        offset.dx + box.size.width,
        0,
      ),
      items: List.generate(_kSortOptions.length, (i) {
        final opt = _kSortOptions[i];
        final label = labels[i];
        final isSelected = label == currentLabel;
        return PopupMenuItem(
          value: {'sortBy': opt['sortBy'], 'sortOrder': opt['sortOrder']},
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? AppColors.of(context).primary
                        : AppColors.of(context).textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 16.sp,
                  color: AppColors.of(context).primary,
                ),
            ],
          ),
        );
      }),
    ).then((selected) {
      if (selected == null) return;
      final current = listingsBloc.state;
      if (current is ListingsLoaded) {
        listingsBloc.add(
          ListingsFilterChanged(
            category: current.category,
            condition: current.condition,
            minPrice: current.minPrice,
            maxPrice: current.maxPrice,
            sortBy: selected['sortBy'],
            sortOrder: selected['sortOrder'],
          ),
        );
      }
    });
  }
}

// ── Dismissible Chip ──────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.of(context).primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.of(context).primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.of(context).primary,
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 14.sp,
              color: AppColors.of(context).primary,
            ),
          ),
        ],
      ),
    );
  }
}
