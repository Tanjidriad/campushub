import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/constants/app_icons.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:book_user_app/features/profile/presentation/widgets/profile_info_header.dart';
import 'package:book_user_app/features/profile/presentation/widgets/profile_info_row.dart';
import 'package:book_user_app/features/listings/presentation/widgets/staggered_listing_card.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SellerProfilePage extends StatelessWidget {
  // In a real implementation, you would pass the Seller ID and use a BLoC to fetch data.
  // For the UI implementation, we'll accept some placeholder/passed data.
  // The Listing entity currently contains limited seller info (ownerId, ownerName, ownerAvatarUrl).
  final Listing listing;

  const SellerProfilePage({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final bgColor = colors.background;
    final l10n = AppLocalizations.of(context)!;

    final educationValue = [
      listing.educationLevel,
      listing.subject,
      listing.classOrSemester,
    ]
        .where((v) => v != null && v.trim().isNotEmpty)
        .map((v) => v!.trim())
        .join(' • ');

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.of(context).textPrimary,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.sellerProfile,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.of(context).textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_horiz,
              color: AppColors.of(context).textPrimary,
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
            ProfileHeader(avatarUrl: listing.seller?.avatar),

            SizedBox(height: 8.h),

            // Rating, Name aligned to the right perfectly matching the avatar
            ProfileInfoHeader(
              name: listing.seller?.name ?? l10n.unknownSeller,
              username:
                  listing.seller?.username ??
                  'seller_${listing.seller?.name.replaceAll(' ', '').toLowerCase() ?? 'user'}',
              isVerified: listing.seller?.isVerified ?? false,
              rating: listing.seller?.rating ?? 0.0,
              reviewCount: 0,
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
                        l10n.message,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: AppColors.of(context).onPrimary,
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
                        l10n.follow,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.of(context).textPrimary,
                        side: BorderSide(color: colors.border, width: 1.5),
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
                    l10n.aboutSeller,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: AppColors.of(context).textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (listing.seller?.createdAt != null)
                    ProfileInfoRow(
                      label: l10n.memberSince,
                      value: DateFormat(
                        'MMM yyyy',
                      ).format(listing.seller!.createdAt!),
                      iconPath: AppIcons.memberSinceIcon,
                    ),
                  ProfileInfoRow(
                    label: l10n.location,
                    value: listing.location?.name ?? l10n.unknown,
                    iconPath: AppIcons.locationIcon,
                  ),

                  if (listing.description.trim().isNotEmpty)
                    ProfileInfoRow(
                      label: l10n.bio,
                      value: listing.description.trim(),
                      iconPath: AppIcons.descriptionIcon,
                    ),

                  if (educationValue.trim().isNotEmpty)
                    ProfileInfoRow(
                      label: l10n.educationLevel,
                      value: educationValue,
                    ),

                  SizedBox(height: 24.h),

                  // Active Ads Title
                  Text(
                    l10n.activeAdsBy(
                      listing.seller?.name.split(' ').first ??
                          l10n.sellerProfile,
                    ),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: AppColors.of(context).textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Featured listing (hidden when profile was opened by seller id only with no listing)
            if (listing.id.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 40.h),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 24.w,
                  child: GestureDetector(
                    onTap: () => context.pushNamed(
                      'listing_detail',
                      pathParameters: {'id': listing.id},
                    ),
                    child: StaggeredListingCard(listing: listing),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
