// ignore_for_file: deprecated_member_use

import 'package:book_user_app/features/auth/domain/entities/user.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/listings/domain/repositories/listing_repository.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_event.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_state.dart';
import 'package:book_user_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:book_user_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:book_user_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:book_user_app/features/reviews/presentation/bloc/reviews_bloc.dart';
import 'package:book_user_app/features/reviews/presentation/bloc/reviews_event.dart';
import 'package:book_user_app/features/reviews/presentation/widgets/reviews_list.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:book_user_app/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  int _selectedTabIndex = 0; // 0: Listings, 1: Reviews

  @override
  void initState() {
    super.initState();
    // Validate userId
    if (widget.userId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid user ID')));
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<ProfileBloc>()..add(UserProfileLoadRequested(widget.userId)),
        ),
        BlocProvider(
          create: (context) => sl<ListingsBloc>()
            ..add(
              ListingsLoadRequested(
                params: ListingsParams(sellerId: widget.userId),
              ),
            ),
        ),
        BlocProvider(create: (context) => sl<ReviewsBloc>()),
      ],
      child: _UserProfileView(
        userId: widget.userId,
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

class _UserProfileView extends StatefulWidget {
  final String userId;
  final int selectedTabIndex;
  final Function(int) onTabChanged;

  const _UserProfileView({
    required this.userId,
    required this.selectedTabIndex,
    required this.onTabChanged,
  });

  @override
  State<_UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<_UserProfileView> {
  @override
  void didUpdateWidget(covariant _UserProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTabIndex != oldWidget.selectedTabIndex) {
      if (widget.selectedTabIndex == 0) {
        // Reload listings? Usually not needed if already loaded, but we can if pull-to-refresh
      } else if (widget.selectedTabIndex == 1) {
        context.read<ReviewsBloc>().add(
          ReviewsLoadRequested(sellerId: widget.userId),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(body: Center(child: AppLoader()));
        } else if (state is ProfileError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text('Error: ${state.message}')),
          );
        } else if (state is ProfileLoaded) {
          final user = state.user;
          return Scaffold(
            backgroundColor: theme.colorScheme.background,
            body: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 200.h,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          color: isDark ? Colors.grey[900] : Colors.grey[200],
                          child: user.avatar != null
                              ? Image.network(user.avatar!, fit: BoxFit.cover)
                              : const Icon(Icons.person, size: 80),
                        ),
                      ),
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        '@${user.username ?? ""}',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                // Chat Button Placeholder
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Navigate to chat
                                    // We need to create a conversation or go to existing
                                    // For now show snackbar
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Chat not implemented yet",
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.chat_bubble_outline,
                                    size: 18,
                                  ),
                                  label: const Text("Chat"),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            if (user.bio != null) ...[
                              Text(
                                user.bio!,
                                style: theme.textTheme.bodyMedium,
                              ),
                              SizedBox(height: 16.h),
                            ],

                            // Stats
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  user.activeListings.toString(),
                                  "Active",
                                  theme,
                                ),
                                _buildStatItem(
                                  user.totalSold.toString(),
                                  "Sold",
                                  theme,
                                ),
                                _buildStatItem(
                                  user.averageRating.toStringAsFixed(1),
                                  "Rating",
                                  theme,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tabs
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        minHeight: 50.h,
                        maxHeight: 50.h,
                        child: Container(
                          color: theme.colorScheme.background,
                          child: Row(
                            children: [
                              _buildTabItem(
                                "Listings",
                                0,
                                widget.selectedTabIndex == 0,
                                theme,
                              ),
                              _buildTabItem(
                                "Reviews",
                                1,
                                widget.selectedTabIndex == 1,
                                theme,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Content
                    if (widget.selectedTabIndex == 0)
                      BlocBuilder<ListingsBloc, ListingsState>(
                        builder: (context, listingsState) {
                          if (listingsState is ListingsLoading) {
                            return const SliverFillRemaining(
                              child: Center(child: AppLoader()),
                            );
                          } else if (listingsState is ListingsError) {
                            return SliverToBoxAdapter(
                              child: Text(listingsState.message),
                            );
                          } else if (listingsState is ListingsLoaded) {
                            if (listingsState.listings.isEmpty) {
                              return const SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Center(
                                    child: Text("No listings found."),
                                  ),
                                ),
                              );
                            }
                            return SliverPadding(
                              padding: EdgeInsets.all(16.w),
                              sliver: SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 16.w,
                                      crossAxisSpacing: 16.w,
                                      childAspectRatio: 0.75,
                                    ),
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final listing = listingsState.listings[index];
                                  return GestureDetector(
                                    onTap: () => context.pushNamed(
                                      'listing_detail',
                                      pathParameters: {'id': listing.id},
                                      extra: listing,
                                    ),
                                    child: _buildListingItem(listing, theme),
                                  );
                                }, childCount: listingsState.listings.length),
                              ),
                            );
                          }
                          return const SliverToBoxAdapter(
                            child: SizedBox.shrink(),
                          );
                        },
                      )
                    else
                      const SliverToBoxAdapter(child: ReviewsList()),
                  ],
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTabItem(
    String label,
    int index,
    bool isSelected,
    ThemeData theme,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () => widget.onTabChanged(index),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? theme.colorScheme.primary : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildListingItem(Listing listing, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: Colors.grey[200],
              image: listing.images.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(listing.images.first.url),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: listing.images.isEmpty
                ? const Center(child: Icon(Icons.image, color: Colors.grey))
                : null,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          listing.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '\$${(listing.price ?? 0).toStringAsFixed(0)}',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
