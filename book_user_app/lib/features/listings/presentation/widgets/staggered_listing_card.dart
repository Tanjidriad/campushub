import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/listings/presentation/pages/listing_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
  static const _kPriceGreen = Color(0xFF15803D);
  static const _kDarkText = Color(0xFF1F2937);

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
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = listing.primaryImageUrl ?? '';
    final imageHeight = isSmall ? 120.h : 170.h;

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ListingDetailPage(
                heroTag: imageUrl.isEmpty
                    ? 'placeholder_${listing.id}'
                    : imageUrl,
                imageUrl: imageUrl,
                listingId: listing.id,
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFF0F0F5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Image Section ───
            Padding(
              padding: EdgeInsets.all(5.w),
              child: Stack(
                children: [
                  Hero(
                    tag: imageUrl.isEmpty
                        ? 'placeholder_${listing.id}'
                        : imageUrl,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              height: imageHeight,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                height: imageHeight,
                                color: const Color(0xFFF5F5FA),
                                child: Center(
                                  child: Icon(
                                    Iconsax.image,
                                    color: Colors.grey[300],
                                    size: 28.sp,
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                height: imageHeight,
                                color: const Color(0xFFF5F5FA),
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey[300],
                                  size: 28.sp,
                                ),
                              ),
                            )
                          : Container(
                              height: imageHeight,
                              color: const Color(0xFFF5F5FA),
                              child: Icon(
                                Icons.image_outlined,
                                color: Colors.grey[300],
                                size: 28.sp,
                              ),
                            ),
                    ),
                  ),

                  // Wishlist button
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: onWishlistTap,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          listing.isInWishlist ? Iconsax.heart5 : Iconsax.heart,
                          size: 16.sp,
                          color: listing.isInWishlist
                              ? const Color(0xFFEF4444)
                              : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Info Section (matches reference screenshot) ───
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 4.h, 10.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price row: "$ 12,344.00 (Fixed)"
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          listing.priceType == 'free'
                              ? 'FREE'
                              : '\$ ${listing.price?.toStringAsFixed(2) ?? '0.00'}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: _kPriceGreen,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '(${_capitalizeFirst(listing.priceType ?? 'fixed')})',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // Title - bold, dark
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: _kDarkText,
                      height: 1.3,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Location - grey, regular
                  if (listing.location?.name != null ||
                      listing.location?.address != null)
                    Text(
                      listing.location?.name ?? listing.location?.address ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
                      ),
                    ),

                  SizedBox(height: 2.h),

                  // Date - grey, regular
                  Text(
                    _formatDate(listing.createdAt),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[500],
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
}
