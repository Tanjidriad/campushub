import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_cached_image.dart';
import 'package:book_user_app/core/widgets/press_scale.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_event.dart';
import 'package:book_user_app/features/listings/presentation/pages/listing_detail_page.dart';

import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class ModernFeaturedCard extends StatelessWidget {
  final Listing listing;

  const ModernFeaturedCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final imageUrl = listing.primaryImageUrl ?? '';
    final colors = AppColors.of(context);
    final showTrending = listing.views > 30;

    return PressScale(
      hapticOnTap: false,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailPage(
              heroTag: 'featured_modern_${listing.id}',
              imageUrl: imageUrl,
              listingId: listing.id,
            ),
          ),
        );
      },
      child: Container(
        width: 200.w,
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
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area with Circular Padding
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (showTrending)
                    Positioned(
                      top: 12.h,
                      left: 12.w,
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
                  Padding(
                    padding: EdgeInsets.all(6.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        color: AppColors.of(context).card, // White inner pop
                        alignment: Alignment.center,
                        child: imageUrl.isNotEmpty
                            ? AppCachedImage(
                                imageUrl: imageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorWidget: Icon(
                                  Iconsax.image,
                                  color: AppColors.of(context).textLight,
                                ),
                              )
                            : Icon(
                                Iconsax.image,
                                color: AppColors.of(context).textLight,
                              ),
                      ),
                    ),
                  ),

                  // Heart Icon Overlay
                  Positioned(
                    top: 16.h,
                    right: 16.w,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        context.read<ListingsBloc>().add(
                          ListingWishlistToggled(listingId: listing.id),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppColors.of(
                            context,
                          ).surface.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.of(
                                context,
                              ).textPrimary.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          listing.isInWishlist ? Iconsax.heart5 : Iconsax.heart,
                          size: 16.sp,
                          color: listing.isInWishlist
                              ? AppColors.of(context).success
                              : AppColors.of(context).textLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Text Details Area — compact, no Expanded
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Price + (Fixed)
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: listing.formattedPrice,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: colors.success,
                          ),
                        ),
                        TextSpan(
                          text: l10n.fixedPriceType,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // Title
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Location
                  Text(
                    listing.location?.name ?? l10n.notSpecified,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.of(context).textSecondary,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Context Chips (subject, classOrSemester)
                  if (listing.subject != null || listing.classOrSemester != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: Wrap(
                        spacing: 4.w,
                        runSpacing: 4.h,
                        children: [
                          if (listing.subject != null && listing.subject!.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: AppColors.of(context).primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                listing.subject!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: AppColors.of(context).primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (listing.classOrSemester != null && listing.classOrSemester!.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: AppColors.of(context).primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                listing.classOrSemester!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: AppColors.of(context).primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  // Date (formatted like "May 15, 2025")
                  Text(
                    _formatDate(listing.createdAt),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10.sp,
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

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
