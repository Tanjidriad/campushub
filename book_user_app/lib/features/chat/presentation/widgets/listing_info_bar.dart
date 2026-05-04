import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:book_user_app/l10n/app_localizations.dart';

class ListingInfoBar extends StatelessWidget {
  final String listingId;
  final String title;
  final String? imageUrl;
  final double? price;
  final String? sellerId;
  final bool isSold;
  final String? currentUserId;
  final VoidCallback? onViewListing;
  final VoidCallback? onMarkAsSold;
  final VoidCallback? onMakeOffer;

  const ListingInfoBar({
    super.key,
    required this.listingId,
    required this.title,
    this.imageUrl,
    this.price,
    this.sellerId,
    this.isSold = false,
    this.currentUserId,
    this.onViewListing,
    this.onMarkAsSold,
    this.onMakeOffer,
  });

  /// Check if current user is the seller
  bool get isSeller =>
      currentUserId != null && sellerId != null && currentUserId == sellerId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface.withOpacity(0.95),
        border: Border(bottom: BorderSide(color: AppColors.of(context).border)),
      ),
      child: Row(
        children: [
          // Listing Image
          GestureDetector(
            onTap: onViewListing,
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppColors.of(context).border,
                borderRadius: BorderRadius.circular(8.r),
                image: imageUrl != null && imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                border: Border.all(color: AppColors.of(context).subtleFill),
              ),
              child: imageUrl == null || imageUrl!.isEmpty
                  ? Icon(Icons.image, color: AppColors.of(context).textLight)
                  : null,
            ),
          ),
          SizedBox(width: 12.w),

          // Title & Price
          Expanded(
            child: GestureDetector(
              onTap: onViewListing,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    price != null
                        ? '\$${price!.toStringAsFixed(2)}'
                        : 'Contact for price',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).accent,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // View Listing Button
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            color: AppColors.of(context).textSecondary,
            onPressed: onViewListing,
            tooltip: 'View Listing',
          ),

          // Action Button - show only when we know the seller, and react to sold state
          if (sellerId == null || sellerId!.isEmpty)
            const SizedBox.shrink()
          else if (isSold)
            // SOLD: disabled button for both seller and buyer
            ElevatedButton.icon(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.of(context).border,
                disabledBackgroundColor:
                    AppColors.of(context).border.withOpacity(0.25),
                disabledForegroundColor: AppColors.of(context).textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                elevation: 0,
              ),
              icon: Icon(
                Icons.check_circle_outline,
                size: 16.sp,
                color: AppColors.of(context).textSecondary,
              ),
              label: Text(
                l10n.sold,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).textSecondary,
                ),
              ),
            )
          else if (isSeller)
            // SELLER: Mark as Sold
            ElevatedButton.icon(
              onPressed: onMarkAsSold,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.of(context).success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                elevation: 0,
              ),
              icon: Icon(
                Icons.check_circle_outline,
                size: 16.sp,
                color: AppColors.of(context).onPrimary,
              ),
              label: Text(
                l10n.markSold,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).onPrimary,
                ),
              ),
            )
          else
            // BUYER: Make an Offer
            ElevatedButton.icon(
              onPressed: onMakeOffer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.of(context).accent, // Blue for offer
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                elevation: 0,
              ),
              icon: Icon(
                Icons.local_offer_outlined,
                size: 16.sp,
                color: AppColors.of(context).onPrimary,
              ),
              label: Text(
                l10n.makeAnOffer,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
