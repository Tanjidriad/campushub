import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_event.dart';
import 'package:book_user_app/features/listings/presentation/pages/listing_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class StaffPicksSection extends StatelessWidget {
  final List<Listing> listings;

  const StaffPicksSection({super.key, required this.listings});

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          // Section Header — matches reference "Cars" header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Staff Picks',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                'View All',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // List of Staff Picks Cards
          ...listings.take(5).map((listing) => StaffPickCard(listing: listing)),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }
}

class StaffPickCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onWishlistTap;

  const StaffPickCard({required this.listing, this.onWishlistTap, super.key});

  String _formatDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  String _capitalizeFirst(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final imageUrl = listing.primaryImageUrl ?? '';

    return GestureDetector(
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
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7FB),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFF0F0F5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 120.w,
                      height: 100.h,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 120.w,
                        height: 100.h,
                        color: const Color(0xFFF5F5FA),
                        child: Icon(
                          Iconsax.image,
                          color: Colors.grey[300],
                          size: 24.sp,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 120.w,
                        height: 100.h,
                        color: const Color(0xFFF5F5FA),
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey[300],
                          size: 24.sp,
                        ),
                      ),
                    )
                  : Container(
                      width: 120.w,
                      height: 100.h,
                      color: const Color(0xFFF5F5FA),
                      child: Icon(
                        Icons.image_outlined,
                        color: Colors.grey[300],
                        size: 24.sp,
                      ),
                    ),
            ),

            SizedBox(width: 12.w),

            // Right: Info + Detail button
            Expanded(
              child: SizedBox(
                height: 100.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price row
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                listing.priceType == 'free'
                                    ? 'FREE'
                                    : '\$ ${listing.price?.toStringAsFixed(2) ?? '0.00'}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF15803D),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '(${_capitalizeFirst(listing.priceType ?? 'fixed')})',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[500],
                              ),
                            ),
                            const Spacer(),
                            // Wishlist heart (circular, like staggered card)
                            GestureDetector(
                              onTap:
                                  onWishlistTap ??
                                  () => context.read<ListingsBloc>().add(
                                    ListingWishlistToggled(
                                      listingId: listing.id,
                                    ),
                                  ),
                              child: Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
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
                                  listing.isInWishlist
                                      ? Iconsax.heart5
                                      : Iconsax.heart,
                                  size: 16.sp,
                                  color: listing.isInWishlist
                                      ? const Color(0xFFEF4444)
                                      : Colors.grey[400],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        // Title
                        Text(
                          listing.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        // Location
                        if (listing.location?.name != null ||
                            listing.location?.address != null)
                          Text(
                            listing.location?.name ??
                                listing.location?.address ??
                                '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[400],
                            ),
                          ),
                      ],
                    ),

                    // Bottom: Date + Detail button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _formatDate(listing.createdAt),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[400],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            'Detail',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
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
