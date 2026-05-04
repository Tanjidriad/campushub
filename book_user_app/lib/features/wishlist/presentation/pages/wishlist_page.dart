import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_snackbar.dart';
import 'package:book_user_app/core/widgets/app_loader.dart';
import 'package:book_user_app/core/widgets/empty_state_widget.dart';
import 'package:book_user_app/core/widgets/fade_slide_in.dart';
import 'package:book_user_app/features/listings/presentation/widgets/staggered_listing_card.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../injection_container/injection_container.dart';
import '../bloc/wishlist_bloc.dart';
import '../bloc/wishlist_event.dart';
import '../bloc/wishlist_state.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WishlistBloc>()..add(LoadWishlist()),
      child: const _WishlistPageBody(),
    );
  }
}

class _WishlistPageBody extends StatelessWidget {
  const _WishlistPageBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        title: Text(l10n.myWishlist),
        backgroundColor: AppColors.of(context).background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.of(context).textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.of(context).textPrimary),
      ),
      body: BlocConsumer<WishlistBloc, WishlistState>(
        listener: (context, state) {
          if (state is WishlistOperationSuccess) {
            AppSnackBar.showSuccess(context, state.message);
          } else if (state is WishlistError) {
            AppSnackBar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is WishlistLoading) {
            return const AppLoaderFullPage();
          } else if (state is WishlistLoaded) {
            if (state.wishlist.isEmpty) {
              return _buildEmptyState(context);
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<WishlistBloc>().add(LoadWishlist());
              },
              child: MasonryGridView.count(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                crossAxisCount: 2,
                mainAxisSpacing: 12.w,
                crossAxisSpacing: 12.w,
                itemCount: state.wishlist.length,
                itemBuilder: (context, index) {
                  final listing = state.wishlist[index];
                  return FadeSlideIn(
                    index: index,
                    child: StaggeredListingCard(
                      listing: listing,
                      isSmall: index.isOdd,
                      onWishlistTap: () {
                        context.read<WishlistBloc>().add(
                          RemoveFromWishlist(listing.id),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }
          return _buildEmptyState(context);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: EmptyStateWidget(
        icon: Iconsax.heart,
        title: l10n.wishlistEmpty,
        subtitle: l10n.wishlistEmptySubtitle,
        buttonText: l10n.exploreListings,
        onButtonPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
