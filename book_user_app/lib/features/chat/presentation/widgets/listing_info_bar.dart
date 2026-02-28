import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ListingInfoBar extends StatelessWidget {
  final String listingId;
  final String title;
  final String? imageUrl;
  final double? price;
  final String? sellerId;
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
    debugPrint(
      '🏷️ ListingInfoBar → currentUserId: $currentUserId, sellerId: $sellerId, isSeller: $isSeller',
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
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
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.r),
                image: imageUrl != null && imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                border: Border.all(color: Colors.grey[100]!),
              ),
              child: imageUrl == null || imageUrl!.isEmpty
                  ? Icon(Icons.image, color: Colors.grey[400])
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
                      color: const Color(0xFF007AFF),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // View Listing Button
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            color: Colors.grey[500],
            onPressed: onViewListing,
            tooltip: 'View Listing',
          ),

          // Action Button - Different for Seller vs Buyer
          if (isSeller)
            // SELLER: Mark as Sold
            ElevatedButton.icon(
              onPressed: onMarkAsSold,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34C759), // Green for sold
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                elevation: 0,
              ),
              icon: Icon(
                Icons.check_circle_outline,
                size: 16.sp,
                color: Colors.white,
              ),
              label: Text(
                'Mark Sold',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          else
            // BUYER: Make an Offer
            ElevatedButton.icon(
              onPressed: onMakeOffer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF), // Blue for offer
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                elevation: 0,
              ),
              icon: Icon(
                Icons.local_offer_outlined,
                size: 16.sp,
                color: Colors.white,
              ),
              label: Text(
                'Make Offer',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
