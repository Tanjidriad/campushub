import 'dart:async';

import 'package:book_user_app/core/services/search_history_service.dart';
import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/widgets/filter_bottom_sheet.dart';
import 'package:book_user_app/features/listings/presentation/pages/search_page.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

class CleanSearchBar extends StatefulWidget {
  const CleanSearchBar({super.key});

  @override
  State<CleanSearchBar> createState() => _CleanSearchBarState();
}

class _CleanSearchBarState extends State<CleanSearchBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _borderPulse;
  late final Animation<double> _borderOpacity;
  Timer? _hintTimer;
  int _hintIndex = 0;
  List<String> _recent = [];

  final List<String> _rotatingHintsEn = const [
    'Search textbooks…',
    'Find electronics…',
    'Browse furniture…',
    'Score deals near you…',
    'Search by course or title…',
  ];

  @override
  void initState() {
    super.initState();
    _borderPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    _borderOpacity = Tween<double>(begin: 0.12, end: 0.45).animate(
      CurvedAnimation(parent: _borderPulse, curve: Curves.easeInOut),
    );
    _hintTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        _hintIndex = (_hintIndex + 1) % _rotatingHintsEn.length;
      });
    });
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final list = await sl<SearchHistoryService>().getRecentQueries();
    if (!mounted) return;
    setState(() => _recent = list.take(5).toList());
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _borderPulse.dispose();
    super.dispose();
  }

  String _hintFor(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'bn') {
      return AppLocalizations.of(context)!.searchWithKeywords;
    }
    return _rotatingHintsEn[_hintIndex % _rotatingHintsEn.length];
  }

  void _openSearch({String? preset}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(initialQuery: preset),
      ),
    ).then((_) => _loadRecent());
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _borderOpacity,
            builder: (context, child) {
              final pulse = _borderOpacity.value;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.r),
                  gradient: LinearGradient(
                    colors: [
                      colors.primary.withOpacity(0.08 + pulse * 0.15),
                      colors.accent.withOpacity(0.06 + pulse * 0.12),
                    ],
                  ),
                ),
                padding: EdgeInsets.all(1.2.w),
                child: child,
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withAlpha(10),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: colors.border.withAlpha(127),
                    blurRadius: 1,
                    spreadRadius: 0,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.search_normal,
                    color: colors.textLight,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openSearch(),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: Text(
                          _hintFor(context),
                          key: ValueKey<String>(_hintFor(context)),
                          style: TextStyle(
                            color: colors.textLight,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _openSearch(),
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Semantics(
                        label: 'Voice search',
                        button: true,
                        child: Icon(
                          Iconsax.microphone_2,
                          color: colors.textSecondary,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      final listingsBloc = context.read<ListingsBloc>();
                      final categoriesBloc = context.read<CategoriesBloc>();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (sheetContext) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: listingsBloc),
                            BlocProvider.value(value: categoriesBloc),
                          ],
                          child: const FilterBottomSheet(),
                        ),
                      );
                    },
                    child: Semantics(
                      label: 'Filter listings',
                      button: true,
                      child: Icon(
                        Iconsax.setting_4,
                        color: colors.textSecondary,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_recent.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              'Recent',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 6.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: _recent
                  .map(
                    (q) => Material(
                      color: colors.subtleFill,
                      borderRadius: BorderRadius.circular(999),
                      child: InkWell(
                        onTap: () => _openSearch(preset: q),
                        borderRadius: BorderRadius.circular(999),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          child: Text(
                            q,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
