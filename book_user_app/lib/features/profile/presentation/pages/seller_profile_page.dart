import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/constants/app_icons.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:book_user_app/features/profile/presentation/widgets/profile_info_header.dart';
import 'package:book_user_app/features/profile/presentation/widgets/profile_info_row.dart';
import 'package:book_user_app/features/listings/presentation/widgets/staggered_listing_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SellerProfilePage extends StatelessWidget {
  // In a real implementation, you would pass the Seller ID and use a BLoC to fetch data.
  // For the UI implementation, we'll accept some placeholder/passed data.
  // The Listing entity currently contains limited seller info (ownerId, ownerName, ownerAvatarUrl).
  final Listing listing;

  const SellerProfilePage({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? theme.colorScheme.background
        : const Color(0xFFF9F9F9);
    const actionGreenColor = Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.black,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Seller Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_horiz,
              color: isDark ? Colors.white : Colors.black,
              size: 24.sp,
            ),
            onPressed: () {
              // Show options like Report/Block
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cover Photo & Avatar Stack
            ProfileHeader(avatarUrl: listing.seller?.avatar, isDark: isDark),

            SizedBox(height: 8.h),

            // Rating, Name aligned to the right perfectly matching the avatar
            ProfileInfoHeader(
              name: listing.seller?.name ?? 'Unknown Seller',
              username:
                  listing.seller?.username ??
                  'seller_${listing.seller?.name.replaceAll(' ', '').toLowerCase() ?? 'user'}',
              isVerified: listing.seller?.isVerified ?? false,
              rating: listing.seller?.rating ?? 0.0,
              reviewCount: 0,
              isDark: isDark,
            ),

            SizedBox(height: 24.h),

            // ── Connect Actions ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.chat_bubble_outline, size: 18.sp),
                      label: Text(
                        'Message',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.person_add_alt_1, size: 18.sp),
                      label: Text(
                        'Follow',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black,
                        side: BorderSide(
                          color: isDark
                              ? AppPalette.gray700
                              : const Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 35.h),

            // ── Enriched Information Section (Grey Boxes) ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Seller',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ProfileInfoRow(
                    label: 'Member Since',
                    value: 'Jan 2024', // Placeholder
                    isDark: isDark,
                    iconPath: AppIcons.memberSinceIcon,
                  ),
                  ProfileInfoRow(
                    label: 'Location',
                    value: listing.location?.name ?? 'Unknown',
                    isDark: isDark,
                    iconPath: AppIcons.locationIcon,
                  ),
                  ProfileInfoRow(
                    label: 'Response Rate',
                    value: 'Usually replies in 1 hr',
                    valueColor: actionGreenColor,
                    isDark: isDark,
                    iconPath: AppIcons.responseIcon,
                  ),
                  ProfileInfoRow(
                    label: 'Accepts',
                    value: 'Cash, Zelle', // Placeholder
                    isDark: isDark,
                    iconPath: AppIcons.paymentIcon,
                  ),

                  SizedBox(height: 24.h),

                  // Active Ads Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active Ads by ${listing.seller?.name.split(' ').first ?? 'Seller'}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'See All',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Grid of Listings (Placeholder using the single listing passed in)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 40.h),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.w,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 0.58,
                ),
                itemCount: 2, // Just showing a couple of placeholders
                itemBuilder: (context, index) {
                  // Create unique ID AND unique images to avoid Hero tag collision
                  // (StaggeredListingCard uses primaryImageUrl as Hero tag)
                  final uniqueListing = listing.copyWith(
                    id: '${listing.id}_seller_$index',
                    images: listing.images
                        .map(
                          (img) => ListingImage(
                            url: '${img.url}#seller_$index',
                            publicId: '${img.publicId}_seller_$index',
                          ),
                        )
                        .toList(),
                  );
                  return GestureDetector(
                    onTap: () => context.pushNamed(
                      'listing_detail',
                      pathParameters: {'id': listing.id},
                    ),
                    child: StaggeredListingCard(listing: uniqueListing),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
