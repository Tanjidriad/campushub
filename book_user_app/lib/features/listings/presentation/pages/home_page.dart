import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_event.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_state.dart';
import 'package:book_user_app/features/listings/presentation/widgets/category_selector.dart';
import 'package:book_user_app/features/listings/presentation/widgets/custom_bottom_nav.dart';
import 'package:book_user_app/features/listings/presentation/widgets/drawer_menu_screen.dart';
import 'package:book_user_app/features/listings/presentation/widgets/hero_search_section.dart';
import 'package:book_user_app/features/listings/presentation/widgets/home_header.dart';
import 'package:book_user_app/features/listings/presentation/widgets/staggered_listing_card.dart';
import 'package:book_user_app/features/listings/presentation/widgets/education_filter_bar.dart';
import 'package:book_user_app/features/listings/presentation/widgets/featured_listings_section.dart';
import 'package:book_user_app/features/listings/presentation/widgets/dashboard_section_container.dart';
import 'package:book_user_app/features/listings/presentation/widgets/staff_picks_section.dart';
import 'package:book_user_app/features/listings/presentation/widgets/recommended_for_you_section.dart';
import 'package:book_user_app/features/listings/presentation/widgets/sort_filter_bar.dart';
import 'package:book_user_app/features/listings/presentation/widgets/deals_near_you_section.dart';
import 'package:book_user_app/features/listings/presentation/widgets/highlights_banner_section.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:book_user_app/core/widgets/empty_state_widget.dart';
import 'package:book_user_app/core/widgets/fade_slide_in.dart';
import 'package:book_user_app/features/listings/presentation/widgets/recently_viewed_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:book_user_app/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:book_user_app/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:book_user_app/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:book_user_app/core/services/socket_service.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _drawerController = ZoomDrawerController();

  @override
  void initState() {
    super.initState();
    // Connect socket — non-critical, so catch any errors
    sl<SocketService>().connect().catchError((e) {
      debugPrint('⚠️ HomePage socket connect error (non-fatal): $e');
    });

    // Start socket listening (has internal guard against duplicates)
    final notificationsBloc = sl<NotificationsBloc>();
    notificationsBloc.add(StartNotificationListening());

    // Only load notifications if they haven't been loaded yet
    if (notificationsBloc.state.status == NotificationsStatus.initial) {
      notificationsBloc.add(const LoadNotifications());
      notificationsBloc.add(LoadUnreadCount());
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeroMode(
      enabled: false,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                sl<ListingsBloc>()..add(const ListingsLoadRequested()),
          ),
          BlocProvider.value(value: sl<CategoriesBloc>()),
          BlocProvider.value(value: sl<NotificationsBloc>()),
        ],
        child: ZoomDrawer(
          controller: _drawerController,
          menuScreen: const DrawerMenuScreen(),
          mainScreen: _HomePageContent(drawerController: _drawerController),
          borderRadius: 24.r,
          showShadow: true,
          angle: -8,
          menuBackgroundColor: AppColors.of(context).primary,
          slideWidth: MediaQuery.of(context).size.width * 0.65,
          openCurve: Curves.easeInOutCubic,
          closeCurve: Curves.easeInOutCubic,
          duration: const Duration(milliseconds: 400),
          reverseDuration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  final ZoomDrawerController drawerController;
  const _HomePageContent({required this.drawerController});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: Stack(
        children: [
          // ─── PREMIUM OVERLAP BACKGROUND BLOCK ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160.h,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.of(context).isDark 
                    ? AppColors.of(context).card 
                    : AppColors.of(context).subtleFill,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32.r),
                ),
              ),
            ),
          ),

          // Main content: pinned header + scrollable body
          Column(
            children: [
              // Pinned Header (transparent, shows block behind it)
              SimpleHomeHeader(
                onMenuTap: () => drawerController.toggle?.call(),
              ),

              // Scrollable Content below
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<ListingsBloc>().add(
                      const ListingsRefreshRequested(),
                    );
                  },
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification n) {
                      if (n.metrics.axis != Axis.vertical) return false;
                      final bloc = context.read<ListingsBloc>();
                      final s = bloc.state;
                      if (s is! ListingsLoaded) return false;
                      if (!s.hasMore || s.isLoadingMore) return false;
                      final remaining =
                          n.metrics.maxScrollExtent - n.metrics.pixels;
                      if (remaining < 320) {
                        bloc.add(const ListingsLoadMoreRequested());
                      }
                      return false;
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                        // Un-pinned Search Bar (acts as the overlapping element now)
                        const CleanSearchBar(),

                        SizedBox(height: 12.h),
                        // ─── Highlights Banner (Price Drops + New Arrivals) ───
                        const HighlightsBannerSection(),

                        DashboardSectionContainer(
                          title: l10n.category,
                          actionLabel: l10n.viewAll,
                          onActionTap: () => context.pushNamed('categories'),
                          compactPadding: true,
                          child: Padding(
                            padding: EdgeInsets.only(left: 12.w),
                            child: const CategorySelector(),
                          ),
                        ),

                        // ─── Recommended For You Section ───
                        BlocBuilder<ListingsBloc, ListingsState>(
                          buildWhen: (previous, current) =>
                              current is ListingsLoading ||
                              current is ListingsLoaded ||
                              current is ListingsInitial,
                          builder: (context, state) {
                            if (state is ListingsLoading ||
                                state is ListingsInitial) {
                              return _buildFeaturedShimmer(context);
                            }
                            if (state is ListingsLoaded &&
                                state.recommendedListings.isNotEmpty) {
                              return RecommendedForYouSection(
                                listings: state.recommendedListings,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                        // ─── Featured Ads Section ───
                        BlocBuilder<ListingsBloc, ListingsState>(
                          buildWhen: (previous, current) =>
                              current is ListingsLoading ||
                              current is ListingsLoaded ||
                              current is ListingsInitial,
                          builder: (context, state) {
                            if (state is ListingsLoading ||
                                state is ListingsInitial) {
                              return _buildFeaturedShimmer(context);
                            }
                            if (state is ListingsLoaded &&
                                state.featuredListings.isNotEmpty) {
                              return FeaturedListingsSection(
                                listings: state.featuredListings,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                        // ─── Deals Near You Section ───
                        const DealsNearYouSection(),

                        // ─── Staff Picks Section ───
                        BlocBuilder<ListingsBloc, ListingsState>(
                          buildWhen: (previous, current) =>
                              current is ListingsLoading ||
                              current is ListingsLoaded ||
                              current is ListingsInitial,
                          builder: (context, state) {
                            if (state is ListingsLoading ||
                                state is ListingsInitial) {
                              return _buildStaffPicksShimmer(context);
                            }
                            if (state is ListingsLoaded &&
                                state.staffPicks.isNotEmpty) {
                              return StaffPicksSection(
                                listings: state.staffPicks,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                        // Education filter — power-user narrowing, just above Latest Ads
                        const EducationFilterBar(),
                        SizedBox(height: 16.h),

                        // ─── Latest Ads Section ───
                        DashboardSectionContainer(
                          title: l10n.latestAds,
                          actionLabel: l10n.seeAll,
                          onActionTap: () => context.pushNamed(
                            'see-all',
                            pathParameters: {'type': 'latest'},
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SortFilterBar(),
                              SizedBox(height: 16.h),
                              // Listings with BLoC
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: BlocBuilder<ListingsBloc, ListingsState>(
                                  buildWhen: (previous, current) =>
                                      current is ListingsLoading ||
                                      current is ListingsLoaded ||
                                      current is ListingsInitial ||
                                      current is ListingsError,
                                  builder: (context, state) {
                                    if (state is ListingsLoading) {
                                      return _buildLoadingState(context);
                                    }

                                    if (state is ListingsError) {
                                      return _buildErrorState(context, state.message);
                                    }

                                    if (state is ListingsLoaded) {
                                      if (state.listings.isEmpty) {
                                        return _buildEmptyState(context);
                                      }
                                      return _buildListingsContent(context, state);
                                    }

                                    // Initial state - show loading
                                    return _buildLoadingState(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const RecentlyViewedSection(),

                        SizedBox(height: 100.h), // Space for bottom nav
                      ],
                    ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: const CustomBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.of(context).border,
      highlightColor: AppColors.of(context).subtleFill,
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.of(context).card,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: AppColors.of(context).border,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14.h,
                        width: double.infinity,
                        color: AppColors.of(context).border,
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 12.h,
                        width: 120.w,
                        color: AppColors.of(context).border,
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 12.h,
                        width: 80.w,
                        color: AppColors.of(context).border,
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

  Widget _buildFeaturedShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.of(context).border,
      highlightColor: AppColors.of(context).subtleFill,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 20.h,
              width: 140.w,
              decoration: BoxDecoration(
                color: AppColors.of(context).card,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 250.h,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Container(
                  width: 180.w,
                  decoration: BoxDecoration(
                    color: AppColors.of(context).card,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Container(
                          margin: EdgeInsets.all(5.w),
                          decoration: BoxDecoration(
                            color: AppColors.of(context).border,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 8.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 12.h,
                              width: 90.w,
                              color: AppColors.of(context).border,
                            ),
                            SizedBox(height: 6.h),
                            Container(
                              height: 11.h,
                              width: 130.w,
                              color: AppColors.of(context).border,
                            ),
                            SizedBox(height: 4.h),
                            Container(
                              height: 10.h,
                              width: 100.w,
                              color: AppColors.of(context).border,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildStaffPicksShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.of(context).border,
      highlightColor: AppColors.of(context).subtleFill,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 20.h,
              width: 100.w,
              decoration: BoxDecoration(
                color: AppColors.of(context).card,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 270.h,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Container(
                  width: 160.w,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).card,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140.w,
                        height: 140.w,
                        decoration: BoxDecoration(
                          color: AppColors.of(context).border,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        height: 12.h,
                        width: 100.w,
                        color: AppColors.of(context).border,
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        height: 10.h,
                        width: 60.w,
                        color: AppColors.of(context).border,
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 12.h,
                        width: 80.w,
                        color: AppColors.of(context).border,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 40.h),
        Icon(
          Icons.error_outline,
          size: 64.sp,
          color: AppColors.of(context).textLight,
        ),
        SizedBox(height: 16.h),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.of(context).textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        TextButton(
          onPressed: () {
            context.read<ListingsBloc>().add(const ListingsLoadRequested());
          },
          child: Text(
            "Try Again",
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 100.h),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: EmptyStateWidget(
          icon: Icons.search_off,
          title: "No listings found",
          subtitle: "Check back later for new items!",
        ),
      ),
    );
  }

  Widget _buildListingsContent(BuildContext context, ListingsLoaded state) {
    return Column(
      children: [
        MasonryGridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          crossAxisCount: 2,
          mainAxisSpacing: 12.w,
          crossAxisSpacing: 12.w,
          itemCount: state.listings.length,
          itemBuilder: (context, index) {
            final listing = state.listings[index];
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
        if (state.isLoadingMore)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        if (!state.hasMore && state.listings.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Text(
              "You're all caught up!",
              style: TextStyle(
                color: AppColors.of(context).textLight,
                fontSize: 14.sp,
              ),
            ),
          ),
      ],
    );
  }
}
