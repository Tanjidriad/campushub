import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_loader.dart';
import 'package:book_user_app/features/listings/domain/repositories/listing_repository.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_event.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_state.dart';
import 'package:book_user_app/features/listings/presentation/widgets/staggered_listing_card.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

enum SeeAllType { featured, staffPicks, latest }

class SeeAllListingsPage extends StatelessWidget {
  final SeeAllType type;

  const SeeAllListingsPage({super.key, required this.type});

  ListingsParams _paramsForType() {
    switch (type) {
      case SeeAllType.featured:
        return const ListingsParams(isFeatured: true, limit: 10);
      case SeeAllType.staffPicks:
        return const ListingsParams(
          limit: 10,
          sortBy: 'wishlistCount',
          sortOrder: 'desc',
        );
      case SeeAllType.latest:
        return const ListingsParams(limit: 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ListingsBloc>()
            ..add(ListingsLoadRequested(params: _paramsForType())),
      child: _SeeAllBody(type: type),
    );
  }
}

class _SeeAllBody extends StatefulWidget {
  final SeeAllType type;
  const _SeeAllBody({required this.type});

  @override
  State<_SeeAllBody> createState() => _SeeAllBodyState();
}

class _SeeAllBodyState extends State<_SeeAllBody> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<ListingsBloc>().state;
      if (state is ListingsLoaded && state.hasMore && !state.isLoadingMore) {
        context.read<ListingsBloc>().add(const ListingsLoadMoreRequested());
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _title(AppLocalizations l10n) {
    switch (widget.type) {
      case SeeAllType.featured:
        return l10n.featuredSection;
      case SeeAllType.staffPicks:
        return l10n.staffPicks;
      case SeeAllType.latest:
        return l10n.latestAds;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20.sp,
            color: colors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _title(l10n),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ListingsBloc, ListingsState>(
        builder: (context, state) {
          if (state is ListingsLoading) {
            return const Center(child: AppLoader());
          }

          if (state is ListingsError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.warning_2, size: 48.sp, color: colors.error),
                  SizedBox(height: 12.h),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is ListingsLoaded) {
            final listings = state.listings;

            if (listings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.box_1, size: 48.sp, color: colors.textLight),
                    SizedBox(height: 12.h),
                    Text(
                      l10n.noListingsFound,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.only(top: 8.h),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.w,
                      crossAxisSpacing: 12.w,
                      childCount: listings.length,
                      itemBuilder: (context, index) {
                        final listing = listings[index];
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
                  ),
                  if (state.isLoadingMore)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      sliver: const SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  // Bottom spacing
                  SliverPadding(padding: EdgeInsets.only(bottom: 32.h)),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
