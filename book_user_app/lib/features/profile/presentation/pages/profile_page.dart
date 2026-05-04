import 'dart:async';
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
import 'package:book_user_app/features/listings/presentation/widgets/staggered_listing_card.dart';
import 'package:book_user_app/features/reviews/presentation/bloc/reviews_bloc.dart';
import 'package:book_user_app/features/reviews/presentation/bloc/reviews_event.dart';
import 'package:book_user_app/features/reviews/presentation/widgets/reviews_list.dart';
import 'package:book_user_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:book_user_app/features/profile/presentation/widgets/profile_info_header.dart';
import 'package:book_user_app/features/profile/presentation/widgets/profile_info_row.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:book_user_app/core/services/listing_status_notifier.dart';
import 'package:book_user_app/core/widgets/app_loader.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  final int initialTabIndex;

  const ProfilePage({super.key, this.initialTabIndex = 0});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 0: Profile, 1: My Listings, 2: Favorites, 3: Sold, 4: Reviews
  late int _selectedTabIndex;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
  }

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
  StreamSubscription<String>? _listingStatusSub;

  @override
  void initState() {
    super.initState();
    _loadDataForTab(widget.selectedTabIndex);

    // Listen for listing status changes (e.g. sold via offer acceptance)
    _listingStatusSub = ListingStatusNotifier.instance.onStatusChanged.listen((_) {
      debugPrint('🟢 ListingStatusNotifier: listing sold, refreshing tab ${widget.selectedTabIndex}');
      _loadDataForTab(widget.selectedTabIndex);
    });
  }

  @override
  void didUpdateWidget(covariant _ProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTabIndex != oldWidget.selectedTabIndex) {
      _loadDataForTab(widget.selectedTabIndex);
    }
  }

  void _loadDataForTab(int tabIndex) {
    if (!mounted) return;
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
  void dispose() {
    _listingStatusSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final isDark = colors.isDark;
    final bgColor = colors.background;
    final tabActiveColor = AppColors.of(context).error;
    final actionGreenColor = AppColors.of(context).success;
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              l10n.myProfile,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.of(context).textPrimary,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.edit_note_outlined,
                  color: AppColors.of(context).textPrimary,
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
                              ? AppColors.of(context).onPrimary.withOpacity(0.1)
                              : AppColors.of(context).border,
                          width: 1,
                        ),
                      ),
                    ),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      children: [
                        _buildTabItem(l10n.myProfile, 0, tabActiveColor),
                        _buildTabItem(l10n.myListings, 1, tabActiveColor),
                        _buildTabItem(l10n.wishlist, 2, tabActiveColor),
                        _buildTabItem(l10n.sold, 3, tabActiveColor),
                        _buildTabItem(l10n.reviews, 4, tabActiveColor),
                      ],
                    ),
                  ),

                  // ── Tab Content Area ──
                  Expanded(
                    child: _buildTabContent(
                      user,
                      theme,
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
                  : (AppColors.of(context).textSecondary),
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
    Color actionGreenColor,
  ) {
    if (widget.selectedTabIndex == 0) {
      return _buildProfileTab(user, theme, actionGreenColor);
    } else if (widget.selectedTabIndex == 4) {
      return ListView(
        padding: EdgeInsets.only(top: 16.h, bottom: 100.h),
        children: const [ReviewsList()],
      );
    } else {
      return _buildListingsGrid();
    }
  }

  // ── Tab 0: Profile Details (Hybrid: Exact Screenshot structure + Premium Circular Avatar aligned right) ──
  Widget _buildProfileTab(
    user,
    ThemeData theme,
    Color actionGreenColor,
  ) {
    final l10n = AppLocalizations.of(context)!;

    final phoneValue = (user?.phone != null && user!.phone!.trim().isNotEmpty)
        ? user.phone!.trim()
        : l10n.notSet;

    final educationValue = [
      user?.educationLevel,
      user?.stream,
      user?.department,
      user?.classOrSemester,
    ]
        .where((v) => v != null && v.trim().isNotEmpty)
        .map((v) => v!.trim())
        .join(' • ');

    final onlineValue = user?.isOnline == true
        ? l10n.online
        : (user?.lastActive != null)
            ? '${l10n.offline} • ${DateFormat('MMM d, HH:mm').format(user!.lastActive!)}'
            : l10n.offline;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Cover Photo & Avatar Stack
          ProfileHeader(avatarUrl: user?.avatar),

          SizedBox(height: 8.h),

          // Rating, Name aligned to the right perfectly matching the avatar
          ProfileInfoHeader(
            name: user?.name ?? l10n.guestUser,
            username: user?.username,
            isVerified: user?.isVerified == true,
            rating: user?.averageRating ?? 0.0,
            reviewCount:
                0, // ProfilePage currently displays rating value directly in the review spot "X Reviews"
          ),
          SizedBox(height: 35.h),
          // ── Enriched Information Section (Grey Boxes) ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aboutSeller,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: AppColors.of(context).textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                ProfileInfoRow(
                  label: l10n.memberSince,
                  value: user?.createdAt != null
                      ? DateFormat('MMM yyyy').format(user!.createdAt!)
                      : l10n.unknown,
                  iconPath: AppIcons.memberSinceIcon,
                ),
                ProfileInfoRow(
                  label: l10n.location,
                  value: user?.location ?? l10n.notSet,
                  iconPath: AppIcons.locationIcon,
                ),
                ProfileInfoRow(
                  label: l10n.email,
                  value: user?.email ?? l10n.notSet,
                  iconPath: AppIcons.emailIcon,
                ),

                ProfileInfoRow(
                  label: l10n.phoneNumber,
                  value: phoneValue,
                ),

                ProfileInfoRow(
                  label: l10n.educationLevel,
                  value: educationValue.trim().isNotEmpty
                      ? educationValue
                      : l10n.notSet,
                ),

                ProfileInfoRow(
                  label: l10n.online,
                  value: onlineValue,
                  valueColor:
                      (user?.isOnline == true) ? AppColors.of(context).success : null,
                ),

                if (user?.bio != null && user!.bio!.trim().isNotEmpty)
                  ProfileInfoRow(
                    label: l10n.bio,
                    value: user!.bio!.trim(),
                    iconPath: AppIcons.descriptionIcon,
                  ),

                SizedBox(height: 24.h),
                // Utilities Section
                Text(
                  l10n.account,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: AppColors.of(context).textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                ProfileInfoRow(
                  label: l10n.blockedUsers,
                  value: l10n.clickHere,
                  valueColor: AppColors.of(context).error,
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
  Widget _buildListingsGrid() {
    final l10n = AppLocalizations.of(context)!;
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
                  color: AppColors.of(context).border,
                ),
                SizedBox(height: 12.h),
                Text(
                  l10n.noItemsFound,
                  style: TextStyle(
                    color: AppColors.of(context).textSecondary,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
          );
        }

        return MasonryGridView.count(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
          crossAxisCount: 2,
          mainAxisSpacing: 12.w,
          crossAxisSpacing: 12.w,
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final listing = listings[index];
            return StaggeredListingCard(
              listing: listing,
              isSmall: index.isOdd,
              onTap: () => context.pushNamed(
                'listing_detail',
                pathParameters: {'id': listing.id},
                extra: listing,
              ),
              onWishlistTap: () {
                context.read<ListingsBloc>().add(
                  ListingWishlistToggled(listingId: listing.id),
                );
              },
            );
          },
        );
      },
    );
  }
}
