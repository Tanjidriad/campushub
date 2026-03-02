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
import 'package:book_user_app/features/listings/presentation/widgets/staff_picks_section.dart';
import 'package:book_user_app/features/listings/presentation/widgets/sort_filter_bar.dart';
import 'package:book_user_app/features/listings/presentation/widgets/deals_near_you_section.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:book_user_app/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:book_user_app/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:book_user_app/core/services/socket_service.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<ListingsBloc>()..add(const ListingsLoadRequested()),
        ),
        BlocProvider.value(value: sl<CategoriesBloc>()),
        BlocProvider(
          create: (context) => sl<NotificationsBloc>()
            ..add(const LoadNotifications())
            ..add(LoadUnreadCount())
            ..add(StartNotificationListening()),
        ),
      ],
      child: ZoomDrawer(
        controller: _drawerController,
        menuScreen: const DrawerMenuScreen(),
        mainScreen: _HomePageContent(drawerController: _drawerController),
        borderRadius: 24.r,
        showShadow: true,
        angle: -8,
        menuBackgroundColor: AppPalette.primary,
        slideWidth: MediaQuery.of(context).size.width * 0.65,
        openCurve: Curves.easeInOutCubic,
        closeCurve: Curves.easeInOutCubic,
        duration: const Duration(milliseconds: 400),
        reverseDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  final ZoomDrawerController drawerController;
  const _HomePageContent({required this.drawerController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: Stack(
        children: [
          // Main content: pinned header + scrollable body
          Column(
            children: [
              // Pinned Header (stays visible on scroll)
              SimpleHomeHeader(
                onMenuTap: () => drawerController.toggle?.call(),
              ),

              // Pinned Search Bar (stays visible on scroll)
              const CleanSearchBar(),

              // Scrollable Content below
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<ListingsBloc>().add(
                      const ListingsRefreshRequested(),
                    );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: 12.h), // Search → Category title
                        // Category Title
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              Text(
                                "Category",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.h), // Title → Grid (tight)
                        // Category Grid
                        Padding(
                          padding: EdgeInsets.only(left: 12.w),
                          child: const CategorySelector(),
                        ),
                        SizedBox(height: 16.h),

                        // Education Level Filter Bar
                        const EducationFilterBar(),
                        SizedBox(height: 16.h),

                        // ─── Featured Ads Section ───
                        BlocBuilder<ListingsBloc, ListingsState>(
                          buildWhen: (previous, current) =>
                              current is ListingsLoading ||
                              current is ListingsLoaded ||
                              current is ListingsInitial,
                          builder: (context, state) {
                            if (state is ListingsLoading ||
                                state is ListingsInitial) {
                              return _buildFeaturedShimmer();
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

                        // ─── Staff Picks Section (moved up) ───
                        BlocBuilder<ListingsBloc, ListingsState>(
                          buildWhen: (previous, current) =>
                              current is ListingsLoading ||
                              current is ListingsLoaded ||
                              current is ListingsInitial,
                          builder: (context, state) {
                            if (state is ListingsLoading ||
                                state is ListingsInitial) {
                              return _buildStaffPicksShimmer();
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

                        // ─── Deals Near You Section ───
                        const DealsNearYouSection(),

                        // ─── Latest Ads Section (Masonry Grid) ───
                        // Listings Title
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Latest Ads",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                "See all",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Sort & Filter Bar
                        const SortFilterBar(),
                        SizedBox(height: 16.h),

                        // Listings with BLoC
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: BlocBuilder<ListingsBloc, ListingsState>(
                            builder: (context, state) {
                              if (state is ListingsLoading) {
                                return _buildLoadingState();
                              }

                              if (state is ListingsError) {
                                return _buildErrorState(context, state.message);
                              }

                              if (state is ListingsLoaded) {
                                if (state.listings.isEmpty) {
                                  return _buildEmptyState();
                                }
                                return _buildListingsContent(context, state);
                              }

                              // Initial state - show loading
                              return _buildLoadingState();
                            },
                          ),
                        ),

                        SizedBox(height: 100.h), // Space for bottom nav
                      ],
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

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
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
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 12.h,
                        width: 120.w,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 12.h,
                        width: 80.w,
                        color: Colors.grey[300],
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

  Widget _buildFeaturedShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 20.h,
              width: 140.w,
              decoration: BoxDecoration(
                color: Colors.white,
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
                    color: Colors.white,
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
                            color: Colors.grey[300],
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
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 6.h),
                            Container(
                              height: 11.h,
                              width: 130.w,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 4.h),
                            Container(
                              height: 10.h,
                              width: 100.w,
                              color: Colors.grey[300],
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

  Widget _buildStaffPicksShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 20.h,
              width: 100.w,
              decoration: BoxDecoration(
                color: Colors.white,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140.w,
                        height: 140.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        height: 12.h,
                        width: 100.w,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        height: 10.h,
                        width: 60.w,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 12.h,
                        width: 80.w,
                        color: Colors.grey[300],
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
        Icon(Icons.error_outline, size: 64.sp, color: Colors.grey[400]),
        SizedBox(height: 16.h),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
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

  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 40.h),
        Icon(Icons.search_off, size: 64.sp, color: Colors.grey[400]),
        SizedBox(height: 16.h),
        Text(
          "No listings found",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Check back later for new items!",
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
        ),
        SizedBox(height: 100.h),
      ],
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
            return StaggeredListingCard(
              listing: listing,
              isSmall: index.isOdd,
              onWishlistTap: () {
                context.read<ListingsBloc>().add(
                  ListingWishlistToggled(listingId: listing.id),
                );
              },
            );
          },
        ),
        if (state.isLoadingMore)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        if (state.hasMore && !state.isLoadingMore)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  context.read<ListingsBloc>().add(
                    const ListingsLoadMoreRequested(),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(
                    'Load More',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (!state.hasMore && state.listings.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Text(
              "You're all caught up!",
              style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
            ),
          ),
      ],
    );
  }
}
