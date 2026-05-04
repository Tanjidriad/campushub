import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/services/search_history_service.dart';
import 'dart:async';
import 'package:book_user_app/core/widgets/app_loader.dart';
import 'package:book_user_app/core/widgets/empty_state_widget.dart';
import 'package:book_user_app/core/widgets/fade_slide_in.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../injection_container/injection_container.dart';
import '../bloc/listings_bloc.dart';
import '../bloc/listings_event.dart';
import '../bloc/listings_state.dart';
import '../widgets/staggered_listing_card.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key, this.initialQuery});

  /// Optional preset when opening from home search chips.
  final String? initialQuery;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ListingsBloc>(),
      child: _SearchPageBody(initialQuery: initialQuery),
    );
  }
}

class _SearchPageBody extends StatefulWidget {
  const _SearchPageBody({this.initialQuery});

  final String? initialQuery;

  @override
  State<_SearchPageBody> createState() => _SearchPageBodyState();
}

class _SearchPageBodyState extends State<_SearchPageBody>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _recentSearches = [];
  Timer? _debounce;
  late final AnimationController _borderPulse;
  late final Animation<double> _borderOpacity;

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
    _hydrateRecentFromDisk();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
      final q = widget.initialQuery?.trim();
      if (q != null && q.isNotEmpty) {
        _searchController.text = q;
        context.read<ListingsBloc>().add(ListingsSearchRequested(query: q));
        _addToRecentSearches(q);
      }
    });
  }

  Future<void> _hydrateRecentFromDisk() async {
    final list = await sl<SearchHistoryService>().getRecentQueries();
    if (!mounted) return;
    setState(() {
      _recentSearches
        ..clear()
        ..addAll(list);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _borderPulse.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isEmpty) {
        context.read<ListingsBloc>().add(const ListingsSearchCleared());
      } else {
        final trimmed = query.trim();
        context.read<ListingsBloc>().add(
          ListingsSearchRequested(query: trimmed),
        );
        _addToRecentSearches(trimmed);
      }
    });
  }

  void _addToRecentSearches(String query) {
    sl<SearchHistoryService>().addQuery(query);
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 8) {
        _recentSearches.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        backgroundColor: AppColors.of(context).background,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left,
            color: AppColors.of(context).textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: AnimatedBuilder(
            animation: _borderOpacity,
            builder: (context, child) {
              final colors = AppColors.of(context);
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
            child: Builder(
              builder: (context) {
                final colors = AppColors.of(context);
                return Container(
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
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: l10n.searchDreamBooksHint,
                      hintStyle: TextStyle(
                        color: colors.textLight,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      prefixIcon: Icon(
                        Iconsax.search_normal,
                        color: colors.textLight,
                        size: 20.sp,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Iconsax.close_circle,
                                color: colors.textSecondary,
                                size: 20.sp,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                                setState(() {});
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 12.h,
                      ),
                      isDense: true,
                    ),
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    onChanged: (value) {
                      setState(() {});
                      _onSearchChanged(value);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: _searchController.text.isEmpty
          ? _buildEmptyState()
          : _buildSearchResults(),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(
              Iconsax.search_normal_1,
              size: 80.sp,
              color: AppColors.of(context).border,
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.searchForBooksPrompt,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.of(context).textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.startTypingDiscover,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.of(context).textLight,
              ),
            ),
            SizedBox(height: 32.h),
            _buildRecentSearches(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    final l10n = AppLocalizations.of(context)!;
    if (_recentSearches.isEmpty) return const SizedBox.shrink();

    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recentSearches,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _recentSearches.clear()),
                child: Text(
                  l10n.clear,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _recentSearches.map((search) {
              return Material(
                color: colors.subtleFill,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: () {
                    _searchController.text = search;
                    _searchController.selection = TextSelection.fromPosition(
                      TextPosition(offset: search.length),
                    );
                    _onSearchChanged(search);
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.clock,
                          size: 14.sp,
                          color: colors.textLight,
                        ),
                        SizedBox(width: 6.w),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 220.w),
                          child: Text(
                            search,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ListingsBloc, ListingsState>(
      builder: (context, state) {
        // Loading state
        if (state is ListingsLoading) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 60.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppLoader(color: AppColors.of(context).textPrimary, size: 30),
                  SizedBox(height: 16.h),
                  Text(
                    l10n.searching,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.of(context).textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Error state
        if (state is ListingsError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.warning_2,
                    size: 50.sp,
                    color: AppColors.of(context).error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    l10n.somethingWentWrong,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.of(context).textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.of(context).textLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Loaded state
        if (state is ListingsLoaded) {
          final listings = state.listings;

          if (listings.isEmpty) {
            return _buildNoResults();
          }

          final colors = AppColors.of(context);
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    "${state.totalItems} result${state.totalItems != 1 ? 's' : ''} for \"${_searchController.text.trim()}\"",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.w,
                  crossAxisSpacing: 12.w,
                  childCount: listings.length,
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    return FadeSlideIn(
                      index: index,
                      child: StaggeredListingCard(
                        listing: listing,
                        isSmall: index.isOdd,
                        onWishlistTap: () {
                          context.read<ListingsBloc>().add(
                            ListingWishlistToggled(listingId: listing.id),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              SliverPadding(padding: EdgeInsets.only(bottom: 24.h)),
            ],
          );
        }

        // Default / Initial state while typing
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.of(context).textPrimary,
                  strokeWidth: 2,
                ),
                SizedBox(height: 16.h),
                Text(
                  l10n.searching,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.of(context).textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoResults() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: EmptyStateWidget(
          icon: Iconsax.search_status,
          title: l10n.noResultsFound,
          subtitle: l10n.tryDifferentKeywords,
        ),
      ),
    );
  }
}
