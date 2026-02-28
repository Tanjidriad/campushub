import 'dart:ui';
import 'package:book_user_app/core/constants/app_icons.dart';
import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:book_user_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_event.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_state.dart';
import 'package:book_user_app/features/listings/presentation/widgets/custom_bottom_nav.dart';
import 'package:book_user_app/features/reviews/presentation/bloc/reviews_bloc.dart';
import 'package:book_user_app/features/reviews/presentation/bloc/reviews_event.dart';
import 'package:book_user_app/features/reviews/presentation/widgets/reviews_list.dart';
import 'package:book_user_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:book_user_app/features/profile/presentation/widgets/profile_info_header.dart';
import 'package:book_user_app/features/profile/presentation/widgets/profile_info_row.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:book_user_app/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedTabIndex =
      0; // 0: Profile, 1: My Listings, 2: Favorites, 3: Sold, 4: Reviews

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<ListingsBloc>()),
        BlocProvider(create: (context) => sl<ReviewsBloc>()),
      ],
      child: _ProfileView(
        selectedTabIndex: _selectedTabIndex,
        onTabChanged: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
      ),
    );
  }
}

class _ProfileView extends StatefulWidget {
  final int selectedTabIndex;
  final Function(int) onTabChanged;

  const _ProfileView({
    required this.selectedTabIndex,
    required this.onTabChanged,
  });

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  @override
  void initState() {
    super.initState();
    _loadDataForTab(widget.selectedTabIndex);
  }

  @override
  void didUpdateWidget(covariant _ProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTabIndex != oldWidget.selectedTabIndex) {
      _loadDataForTab(widget.selectedTabIndex);
    }
  }

  void _loadDataForTab(int tabIndex) {
    if (tabIndex == 1) {
      context.read<ListingsBloc>().add(const MyListingsLoadRequested());
    } else if (tabIndex == 2) {
      context.read<ListingsBloc>().add(const WishlistLoadRequested());
    } else if (tabIndex == 3) {
      context.read<ListingsBloc>().add(
        const MyListingsLoadRequested(status: 'sold'),
      );
    } else if (tabIndex == 4) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<ReviewsBloc>().add(
          ReviewsLoadRequested(sellerId: authState.user.id),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? theme.colorScheme.background : Colors.white;
    const tabActiveColor = Color(0xFFE53935);
    const actionGreenColor = Color(0xFF4CAF50);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return Scaffold(
          backgroundColor: isDark
              ? theme.colorScheme.background
              : const Color(0xFFF9F9F9),
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'Profile',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.edit_note_outlined,
                  color: isDark ? Colors.white : Colors.black,
                  size: 28.sp,
                ),
                onPressed: () {
                  if (user != null) {
                    context.pushNamed('edit_profile', extra: user);
                  }
                },
              ),
              SizedBox(width: 8.w),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  // ── Tabs Header ──
                  Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: bgColor,
                      border: Border(
                        bottom: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                    ),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      children: [
                        _buildTabItem('Profile', 0, tabActiveColor),
                        _buildTabItem('My Listings', 1, tabActiveColor),
                        _buildTabItem('Favorites', 2, tabActiveColor),
                        _buildTabItem('Sold', 3, tabActiveColor),
                        _buildTabItem('Reviews', 4, tabActiveColor),
                      ],
                    ),
                  ),

                  // ── Tab Content Area ──
                  Expanded(
                    child: _buildTabContent(
                      user,
                      theme,
                      isDark,
                      actionGreenColor,
                    ),
                  ),
                ],
              ),

              // ── Custom Bottom Nav ──
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomBottomNav(),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab Header Item ──
  Widget _buildTabItem(String label, int index, Color activeColor) {
    final isSelected = widget.selectedTabIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => widget.onTabChanged(index),
      child: Container(
        margin: EdgeInsets.only(right: 24.w),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? activeColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? activeColor
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab View Content Presenter ──
  Widget _buildTabContent(
    user,
    ThemeData theme,
    bool isDark,
    Color actionGreenColor,
  ) {
    if (widget.selectedTabIndex == 0) {
      return _buildProfileTab(user, theme, isDark, actionGreenColor);
    } else if (widget.selectedTabIndex == 4) {
      return ListView(
        padding: EdgeInsets.only(top: 16.h, bottom: 100.h),
        children: const [ReviewsList()],
      );
    } else {
      return _buildListingsGrid(theme, isDark);
    }
  }

  // ── Tab 0: Profile Details (Hybrid: Exact Screenshot structure + Premium Circular Avatar aligned right) ──
  Widget _buildProfileTab(
    user,
    ThemeData theme,
    bool isDark,
    Color actionGreenColor,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Cover Photo & Avatar Stack
          ProfileHeader(avatarUrl: user?.avatar, isDark: isDark),

          SizedBox(height: 8.h),

          // Rating, Name aligned to the right perfectly matching the avatar
          ProfileInfoHeader(
            name: user?.name ?? 'Guest User',
            username: user?.username,
            isVerified: user?.isVerified == true,
            rating: user?.averageRating ?? 0.0,
            reviewCount:
                0, // ProfilePage currently displays rating value directly in the review spot "X Reviews"
            isDark: isDark,
          ),
          SizedBox(height: 35.h),
          // ── Enriched Information Section (Grey Boxes) ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About Seller',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                ProfileInfoRow(
                  label: 'Member Since',
                  value: user?.createdAt != null
                      ? DateFormat('MMM yyyy').format(user!.createdAt!)
                      : 'Unknown',
                  isDark: isDark,
                  iconPath: AppIcons.memberSinceIcon,
                ),
                ProfileInfoRow(
                  label: 'Location',
                  value: user?.location ?? 'Not Set',
                  isDark: isDark,
                  iconPath: AppIcons.locationIcon,
                ),
                ProfileInfoRow(
                  label: 'Email',
                  value: user?.email ?? 'Not Set',
                  isDark: isDark,
                  iconPath: AppIcons.emailIcon,
                ),
                ProfileInfoRow(
                  label: 'Response Rate',
                  value: 'Usually replies in 1 hr',
                  valueColor: actionGreenColor,
                  isDark: isDark,
                  iconPath: AppIcons.responseIcon,
                ),
                ProfileInfoRow(
                  label: 'Meeting Spot',
                  value: 'Main Library',
                  isDark: isDark,
                  iconPath: AppIcons.meetingSpotIcon,
                ),
                ProfileInfoRow(
                  label: 'Accepts',
                  value: 'Cash, Zelle, CashApp',
                  isDark: isDark,
                  iconPath: AppIcons.paymentIcon,
                ),

                SizedBox(height: 24.h),
                // Utilities Section
                Text(
                  'Account Options',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                ProfileInfoRow(
                  label: 'Blocked Users',
                  value: 'Click Here',
                  valueColor: Colors.redAccent,
                  isDark: isDark,
                  iconPath: AppIcons.blockIcon,
                ),
              ],
            ),
          ),

          SizedBox(height: 100.h), // Space for bottom nav
        ],
      ),
    );
  }

  // ── Tabs 1,2,3: Listings Grid ──
  Widget _buildListingsGrid(ThemeData theme, bool isDark) {
    return BlocBuilder<ListingsBloc, ListingsState>(
      builder: (context, listingsState) {
        if (listingsState is ListingsLoading) {
          return const AppLoaderFullPage();
        } else if (listingsState is ListingsError) {
          return Center(child: Text(listingsState.message));
        }

        List<Listing> listings = [];
        if (listingsState is MyListingsLoaded) {
          listings = listingsState.listings;
        } else if (listingsState is WishlistLoaded) {
          listings = listingsState.listings;
        }

        if (listings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 48.sp,
                  color: AppPalette.gray300,
                ),
                SizedBox(height: 12.h),
                Text(
                  "No items found.",
                  style: TextStyle(color: Colors.grey, fontSize: 15.sp),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.w,
            crossAxisSpacing: 12.w,
            childAspectRatio: 0.72,
          ),
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final listing = listings[index];
            return GestureDetector(
              onTap: () => context.pushNamed(
                'listing_detail',
                pathParameters: {'id': listing.id},
                extra: listing,
              ),
              child: _buildListingCard(listing, theme, isDark),
            );
          },
        );
      },
    );
  }

  Widget _buildListingCard(Listing listing, ThemeData theme, bool isDark) {
    final statusColor = listing.status == 'approved'
        ? Colors.white
        : theme.colorScheme.secondary;
    final statusLabel = listing.status == 'approved'
        ? 'Available'
        : listing.status;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppPalette.gray900 : Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image area with overlays
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                listing.images.isNotEmpty
                    ? Image.network(
                        listing.images.first.url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppPalette.gray200,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: AppPalette.gray400,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: AppPalette.gray200,
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: AppPalette.gray400,
                          ),
                        ),
                      ),

                // Status badge
                Positioned(
                  top: 8.w,
                  left: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      statusLabel.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details area
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      listing.formattedPrice,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    Text(
                      listing.timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
