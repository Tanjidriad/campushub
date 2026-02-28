import 'package:book_user_app/features/listings/presentation/pages/listing_detail_page.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

class ListingCard extends StatelessWidget {
  final Listing? listing;
  final String? title;
  final String? price;
  final String? imageUrl;
  final String? sellerName;
  final String? timeAgo;
  final List<Color>? sellerAvatarGradient;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onTap;

  const ListingCard({
    super.key,
    this.listing,
    this.title,
    this.price,
    this.imageUrl,
    this.sellerName,
    this.timeAgo,
    this.sellerAvatarGradient,
    this.onWishlistTap,
    this.onTap,
  });

  factory ListingCard.fromListing({
    required Listing listing,
    VoidCallback? onWishlistTap,
    VoidCallback? onTap,
  }) {
    return ListingCard(
      listing: listing,
      onWishlistTap: onWishlistTap,
      onTap: onTap,
    );
  }

  String get _title => listing?.title ?? title ?? '';
  String get _price => listing?.formattedPrice ?? price ?? '';
  String get _imageUrl => listing?.primaryImageUrl ?? imageUrl ?? '';
  String get _sellerName =>
      listing?.seller?.username ?? listing?.seller?.name ?? sellerName ?? '';
  String get _timeAgo => listing?.timeAgo ?? timeAgo ?? '';
  String get _description => listing?.description ?? '';

  List<Color> get _avatarGradient =>
      sellerAvatarGradient ?? [AppPalette.primary, AppPalette.accent];

  bool get _isInWishlist => listing?.isInWishlist ?? false;

  String get _listingId => listing?.id ?? '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListingDetailPage(
                heroTag: _imageUrl.isEmpty
                    ? 'placeholder_$_listingId'
                    : _imageUrl,
                imageUrl: _imageUrl,
                listingId: _listingId,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark ? AppPalette.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark
                ? AppPalette.primary.withOpacity(0.1)
                : Color(0xFFF7F7FB),
          ),
          boxShadow: isDark
              ? []
              : [
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
            // ── Image Section ──
            Hero(
              tag: _imageUrl.isEmpty ? 'placeholder_$_listingId' : _imageUrl,
              child: Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppPalette.gray100,
                ),
                clipBehavior: Clip.antiAlias,
                child: _imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: _imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppPalette.gray300,
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.image_not_supported_outlined,
                          color: AppPalette.gray300,
                          size: 32.sp,
                        ),
                      )
                    : Icon(
                        Icons.image_outlined,
                        color: AppPalette.gray300,
                        size: 32.sp,
                      ),
              ),
            ),

            SizedBox(width: 16.w),

            // ── Details Section ──
            Expanded(
              child: SizedBox(
                height: 96.w, // Match image height exactly for alignment
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top part: Title + Fav Icon + Desc + Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                  height: 1.2,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: onWishlistTap,
                              child: Icon(
                                _isInWishlist ? Iconsax.heart5 : Iconsax.heart,
                                size: 20.sp,
                                color: _isInWishlist
                                    ? AppPalette.error
                                    : AppPalette.gray400,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _price,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.secondary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),

                    // Bottom part: Seller + Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Seller Info
                        Expanded(
                          child: Row(
                            children: [
                              _buildSellerAvatar(),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  _sellerName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Time Pill
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppPalette.primary.withOpacity(0.1)
                                : AppPalette.gray100,
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          child: Text(
                            _timeAgo.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppPalette.gray300
                                  : AppPalette.gray500,
                              letterSpacing: 0.5,
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

  Widget _buildSellerAvatar() {
    final avatar = listing?.seller?.avatar;
    if (avatar != null && avatar.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatar,
          width: 20.w,
          height: 20.w,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildGradientAvatar(),
          errorWidget: (context, url, error) => _buildGradientAvatar(),
        ),
      );
    }
    return _buildGradientAvatar();
  }

  Widget _buildGradientAvatar() {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: _avatarGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(Icons.person, color: Colors.white, size: 10.sp),
    );
  }
}
