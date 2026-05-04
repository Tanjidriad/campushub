import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/press_scale.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/listings/presentation/pages/listing_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

/// Pinterest-style staggered card for the Latest Ads grid.
/// Alternating image heights give the masonry look.
class StaggeredListingCard extends StatelessWidget {
  final Listing listing;
  final bool isSmall;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onTap;

  // Colors matching the reference
  Color _kPriceGreen(BuildContext context) => AppColors.of(context).success;

  const StaggeredListingCard({
    super.key,
    required this.listing,
    this.isSmall = false,
    this.onWishlistTap,
    this.onTap,
  });

  String _capitalizeFirst(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _conditionLabel(String condition) {
    switch (condition.toLowerCase()) {
      case 'like-new':
      case 'like_new':
        return 'Like New';
      case 'new':
        return 'New';
      case 'fair':
        return 'Fair';
      case 'poor':
        return 'Used';
      case 'good':
        return 'Good';
      default:
        return _capitalizeFirst(condition.replaceAll('-', ' '));
    }
  }

  String get _heroTag => 'staggered_listing_${listing.id}_$hashCode';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final imageUrl = listing.primaryImageUrl ?? '';
    final imageHeight = isSmall ? 100.h : 130.h;
    final imageCount = listing.images.length;
    final showTrending = listing.views > 30;

    void openDetail() {
      if (onTap != null) {
        onTap!();
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailPage(
              heroTag: _heroTag,
              imageUrl: imageUrl,
              listingId: listing.id,
            ),
          ),
        );
      }
    }

    return PressScale(
      onTap: openDetail,
      child: Container(
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
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Image Section ───
            Padding(
              padding: EdgeInsets.all(6.w),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: imageUrl.isNotEmpty
                        ? Stack(
                            clipBehavior: Clip.hardEdge,
                            children: [
                              CachedNetworkImage(
                                imageUrl: imageUrl,
                                height: imageHeight,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  height: imageHeight,
                                  color: colors.card,
                                  child: Center(
                                    child: Icon(
                                      Iconsax.image,
                                      color: colors.border,
                                      size: 28.sp,
                                    ),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  height: imageHeight,
                                  color: colors.card,
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: colors.border,
                                    size: 28.sp,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                height: 44.h,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(
                                          colors.isDark ? 0.55 : 0.35,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            height: imageHeight,
                            color: colors.card,
                            child: Icon(
                              Icons.image_outlined,
                              color: colors.border,
                              size: 28.sp,
                            ),
                          ),
                  ),

                  if (showTrending)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.warning.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'Trending',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  if (!_isGenericCondition(listing.condition))
                    Positioned(
                      top: showTrending ? 36.h : 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          _conditionLabel(listing.condition),
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  if (imageCount > 1)
                    Positioned(
                      bottom: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '1/$imageCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  if (listing.seller?.avatar != null &&
                      listing.seller!.avatar!.isNotEmpty)
                    Positioned(
                      bottom: 8.h,
                      left: 8.w,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.card, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 14.r,
                          backgroundColor: colors.border,
                          backgroundImage: CachedNetworkImageProvider(
                            listing.seller!.avatar!,
                          ),
                        ),
                      ),
                    ),

                  // Wishlist button
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: _WishlistPulseButton(
                      isInWishlist: listing.isInWishlist,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onWishlistTap?.call();
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ─── Info Section ───
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 4.h, 10.w, 12.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          listing.priceType == 'free'
                              ? l10n.free
                              : '\$ ${listing.price?.toStringAsFixed(2) ?? '0.00'}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: _kPriceGreen(context),
                            letterSpacing: -0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '(${_capitalizeFirst(listing.priceType)})',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                      height: 1.3,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  if (listing.location?.name != null ||
                      listing.location?.address != null)
                    Text(
                      listing.location?.name ?? listing.location?.address ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                      ),
                    ),

                  SizedBox(height: 2.h),

                  if (listing.subject != null || listing.classOrSemester != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: Wrap(
                        spacing: 4.w,
                        runSpacing: 4.h,
                        children: [
                          if (listing.subject != null &&
                              listing.subject!.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                listing.subject!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: colors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (listing.classOrSemester != null &&
                              listing.classOrSemester!.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                listing.classOrSemester!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: colors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  Text(
                    _formatDate(listing.createdAt),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: colors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isGenericCondition(String c) {
    return c.toLowerCase() == 'good' || c.isEmpty;
  }
}

class _WishlistPulseButton extends StatefulWidget {
  const _WishlistPulseButton({
    required this.isInWishlist,
    required this.onTap,
  });

  final bool isInWishlist;
  final VoidCallback onTap;

  @override
  State<_WishlistPulseButton> createState() => _WishlistPulseButtonState();
}

class _WishlistPulseButtonState extends State<_WishlistPulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.22), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.22, end: 1.0), weight: 65),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0);
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: colors.surface.withOpacity(0.92),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            widget.isInWishlist ? Iconsax.heart5 : Iconsax.heart,
            size: 16.sp,
            color: widget.isInWishlist ? colors.error : colors.textLight,
          ),
        ),
      ),
    );
  }
}
