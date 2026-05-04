import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/constants/app_icons.dart';
import 'package:book_user_app/core/widgets/app_cached_image.dart';
import 'package:book_user_app/core/widgets/app_snackbar.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
// ignore_for_file: deprecated_member_use

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
import 'package:book_user_app/features/profile/presentation/widgets/profile_info_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:book_user_app/features/report/domain/entities/report.dart';
import 'package:book_user_app/features/report/presentation/widgets/report_dialog.dart';
import 'package:book_user_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:book_user_app/features/listings/presentation/widgets/staggered_listing_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
        AppSnackBar.showError(
          context,
          AppLocalizations.of(context)!.invalidUserId,
        );
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
        // Add ChatBloc for the BlockUser event
        BlocProvider(create: (context) => ChatBloc()),
      ],
      child: BlocListener<ChatBloc, ChatState>(
        listenWhen: (prev, curr) => curr.isUserBlocked && !prev.isUserBlocked,
        listener: (context, state) {
          if (state.isUserBlocked) {
            AppSnackBar.showSuccess(context, 'User blocked successfully');
            if (Navigator.canPop(context)) {
              context.pop();
            }
          }
        },
        child: _UserProfileView(
          userId: widget.userId,
          selectedTabIndex: _selectedTabIndex,
          onTabChanged: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
        ),
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
    final l10n = AppLocalizations.of(context)!;

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
          final phoneValue = (user.phone != null && user.phone!.trim().isNotEmpty)
              ? user.phone!.trim()
              : l10n.notSet;

          final educationValue = [
            user.educationLevel,
            user.stream,
            user.department,
            user.classOrSemester,
          ]
              .where((v) => v != null && v.trim().isNotEmpty)
              .map((v) => v!.trim())
              .join(' • ');

          final onlineValue = user.isOnline == true
              ? l10n.online
              : (user.lastActive != null)
                  ? '${l10n.offline} • ${DateFormat('MMM d, HH:mm').format(user.lastActive!)}'
                  : l10n.offline;

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
                          color: AppColors.of(context).border,
                          child: user.avatar != null
                              ? AppCachedImage(
                                  imageUrl: user.avatar,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.person, size: 80),
                        ),
                      ),
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showOptionsMenu(context, user.id, user.name),
                        ),
                      ],
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
                                            ?.copyWith(
                                              color: AppColors.of(
                                                context,
                                              ).textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Chat Button
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.goNamed('chat');
                                  },
                                  icon: const Icon(
                                    Icons.chat_bubble_outline,
                                    size: 18,
                                  ),
                                  label: Text(l10n.chat),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              l10n.aboutSeller,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: AppColors.of(context).textPrimary,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            if (user.createdAt != null)
                              ProfileInfoRow(
                                label: l10n.memberSince,
                                value:
                                    DateFormat('MMM yyyy').format(user.createdAt!),
                                iconPath: AppIcons.memberSinceIcon,
                              ),
                            if (user.location != null)
                              ProfileInfoRow(
                                label: l10n.location,
                                value: user.location ?? l10n.notSet,
                                iconPath: AppIcons.locationIcon,
                              ),
                            ProfileInfoRow(
                              label: l10n.email,
                              value: user.email,
                              iconPath: AppIcons.emailIcon,
                            ),
                            ProfileInfoRow(
                              label: l10n.phoneNumber,
                              value: phoneValue,
                            ),
                            if (educationValue.trim().isNotEmpty)
                              ProfileInfoRow(
                                label: l10n.educationLevel,
                                value: educationValue,
                              ),
                            ProfileInfoRow(
                              label: l10n.online,
                              value: onlineValue,
                              valueColor: user.isOnline == true
                                  ? AppColors.of(context).success
                                  : AppColors.of(context).textSecondary,
                            ),
                            if (user.bio != null && user.bio!.trim().isNotEmpty)
                              ProfileInfoRow(
                                label: l10n.bio,
                                value: user.bio!.trim(),
                                iconPath: AppIcons.descriptionIcon,
                              ),
                            SizedBox(height: 16.h),

                            // Stats
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  user.activeListings.toString(),
                                  l10n.active,
                                  theme,
                                ),
                                _buildStatItem(
                                  user.totalSold.toString(),
                                  l10n.sold,
                                  theme,
                                ),
                                _buildStatItem(
                                  user.averageRating.toStringAsFixed(1),
                                  l10n.rating,
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
                                l10n.listings,
                                0,
                                widget.selectedTabIndex == 0,
                                theme,
                              ),
                              _buildTabItem(
                                l10n.reviews,
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
                              return SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Center(
                                    child: Text(l10n.noListingsFound),
                                  ),
                                ),
                              );
                            }
                            return SliverPadding(
                              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
                              sliver: SliverMasonryGrid.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12.w,
                                crossAxisSpacing: 12.w,
                                childCount: listingsState.listings.length,
                                itemBuilder: (context, index) {
                                  final listing = listingsState.listings[index];
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
                                        ListingWishlistToggled(
                                          listingId: listing.id,
                                        ),
                                      );
                                    },
                                  );
                                },
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
              color: isSelected
                  ? theme.colorScheme.primary
                  : AppColors.of(context).textSecondary,
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
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.of(context).textSecondary,
          ),
        ),
      ],
    );
  }

  void _showOptionsMenu(BuildContext context, String userId, String userName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.of(context).surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 12.h),
                  width: 48.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.of(context).border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 8.h),
                child: Row(
                  children: [
                    Text(
                      'More Options',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.of(context).textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.of(context).border),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).warning.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flag_outlined,
                    color: AppColors.of(context).warning,
                    size: 22.sp,
                  ),
                ),
                title: Text(
                  'Report User',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: AppColors.of(context).textLight,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ReportDialog.show(
                    context,
                    targetType: ReportTargetType.user,
                    targetId: userId,
                    targetName: userName,
                  );
                },
              ),
              Divider(height: 1, indent: 72.w, color: AppColors.of(context).subtleFill),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.block_outlined,
                    color: AppColors.of(context).error,
                    size: 22.sp,
                  ),
                ),
                title: Text(
                  'Block User',
                  style: TextStyle(color: AppColors.of(context).error, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showBlockConfirmationDialog(context, userId, userName);
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showBlockConfirmationDialog(BuildContext context, String userId, String userName) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Block User'),
        content: Text(
          'Are you sure you want to block $userName? They will no longer be able to message you, and their active listings won\'t be visible to you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: TextStyle(color: AppColors.of(context).textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.of(context).error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<ChatBloc>().add(BlockUser(userId));
            },
            child: Text('Block', style: TextStyle(color: AppColors.of(context).onPrimary)),
          ),
        ],
      ),
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
