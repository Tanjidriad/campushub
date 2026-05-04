import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/press_scale.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_event.dart';
import 'package:book_user_app/features/listings/presentation/pages/listing_detail_page.dart';
import 'package:book_user_app/features/listings/presentation/widgets/dashboard_section_container.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class StaffPicksSection extends StatelessWidget {
  final List<Listing> listings;

  const StaffPicksSection({super.key, required this.listings});

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    final hero = listings.first;
    final rest = listings.skip(1).take(4).toList();

    return DashboardSectionContainer(
      title: l10n.staffPicks,
      actionLabel: l10n.viewAll,
      onActionTap: () => context.pushNamed(
        'see-all',
        pathParameters: {'type': 'staffPicks'},
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StaffPickHeroCard(listing: hero),
            SizedBox(height: 14.h),
            Text(
              'More staff picks',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.of(context).textSecondary,
                letterSpacing: 0.1,
              ),
            ),
            SizedBox(height: 10.h),
            ...rest.asMap().entries.map(
              (e) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: StaffPickCompactCard(
                  listing: e.value,
                  rank: e.key + 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width hero for the #1 staff pick.
class _StaffPickHeroCard extends StatelessWidget {
  final Listing listing;

  const _StaffPickHeroCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final imageUrl = listing.primaryImageUrl ?? '';
    final colors = AppColors.of(context);

    return PressScale(
      hapticOnTap: false,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailPage(
              heroTag: 'staff_pick_hero_${listing.id}',
              imageUrl: imageUrl,
              listingId: listing.id,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.subtleFill,
          borderRadius: BorderRadius.circular(22.r),
          border: colors.isDark
              ? Border.all(color: colors.border, width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 200.h,
                  width: double.infinity,
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: colors.card,
                            child: Center(
                              child: Icon(
                                Iconsax.image,
                                color: colors.border,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: colors.card,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: colors.border,
                            ),
                          ),
                        )
                      : Container(
                          color: colors.card,
                          child: Icon(
                            Icons.image_outlined,
                            color: colors.border,
                          ),
                        ),
                ),
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '#1 Pick',
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: GestureDetector(
                    onTap: () => context.read<ListingsBloc>().add(
                          ListingWishlistToggled(listingId: listing.id),
                        ),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: colors.surface.withOpacity(0.92),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        listing.isInWishlist ? Iconsax.heart5 : Iconsax.heart,
                        size: 18.sp,
                        color: listing.isInWishlist
                            ? colors.error
                            : colors.textLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Editor\'s note',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: colors.accent,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'A standout listing hand-picked for value on campus.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: colors.textSecondary,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    listing.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        listing.priceType == 'free'
                            ? l10n.free
                            : '\$ ${listing.price?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: colors.success,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          l10n.detail,
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StaffPickCompactCard extends StatelessWidget {
  final Listing listing;
  /// Rank badge (#2, #3, …). Use `0` to hide (e.g. wishlist reuse).
  final int rank;
  final VoidCallback? onWishlistTap;

  const StaffPickCompactCard({
    required this.listing,
    this.rank = 0,
    this.onWishlistTap,
    super.key,
  });

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _capitalizeFirst(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final imageUrl = listing.primaryImageUrl ?? '';
    final colors = AppColors.of(context);

    return PressScale(
      hapticOnTap: false,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailPage(
              heroTag: 'staff_pick_${listing.id}',
              imageUrl: imageUrl,
              listingId: listing.id,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: colors.subtleFill,
          borderRadius: BorderRadius.circular(16.r),
          border: colors.isDark
              ? Border.all(color: colors.border, width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 110.w,
                          height: 96.h,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 110.w,
                            height: 96.h,
                            color: colors.card,
                            child: Icon(
                              Iconsax.image,
                              color: colors.border,
                              size: 24.sp,
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 110.w,
                            height: 96.h,
                            color: colors.card,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: colors.border,
                              size: 24.sp,
                            ),
                          ),
                        )
                      : Container(
                          width: 110.w,
                          height: 96.h,
                          color: colors.card,
                          child: Icon(
                            Icons.image_outlined,
                            color: colors.border,
                            size: 24.sp,
                          ),
                        ),
                ),
                if (rank > 0)
                  Positioned(
                    top: -6.h,
                    left: -4.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.accent,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '#$rank',
                        style: TextStyle(
                          color: colors.onPrimary,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 96.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  listing.priceType == 'free'
                                      ? l10n.free
                                      : '\$ ${listing.price?.toStringAsFixed(2) ?? '0.00'}',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w800,
                                    color: colors.success,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                ' (${_capitalizeFirst(listing.priceType)})',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: onWishlistTap ??
                              () => context.read<ListingsBloc>().add(
                                    ListingWishlistToggled(
                                      listingId: listing.id,
                                    ),
                                  ),
                          child: Icon(
                            listing.isInWishlist
                                ? Iconsax.heart5
                                : Iconsax.heart,
                            size: 18.sp,
                            color: listing.isInWishlist
                                ? colors.error
                                : colors.textLight,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      _formatDate(listing.createdAt),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: colors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alias for compact pick row (wishlist and other screens).
typedef StaffPickCard = StaffPickCompactCard;
