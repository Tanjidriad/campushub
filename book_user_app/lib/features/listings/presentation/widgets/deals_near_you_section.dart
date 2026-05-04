import 'package:book_user_app/core/constants/api_constants.dart';
import 'package:book_user_app/core/network/api_client.dart';
import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/fade_slide_in.dart';
import 'package:book_user_app/core/widgets/press_scale.dart';
import 'package:book_user_app/features/listings/data/models/listing_model.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_event.dart';
import 'package:book_user_app/features/listings/presentation/pages/deals_map_page.dart';
import 'package:book_user_app/features/listings/presentation/pages/listing_detail_page.dart';
import 'package:book_user_app/features/listings/presentation/widgets/dashboard_section_container.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

/// "Deals Near You" — location, nearby API, horizontal carousel aligned with premium listing cards.
class DealsNearYouSection extends StatefulWidget {
  const DealsNearYouSection({super.key});

  @override
  State<DealsNearYouSection> createState() => _DealsNearYouSectionState();
}

class _DealsNearYouSectionState extends State<DealsNearYouSection> {
  List<_NearbyListing> _nearbyListings = [];
  bool _loading = true;
  bool _permissionDenied = false;
  bool _permissionDeniedForever = false;
  double? _currentLat;
  double? _currentLng;

  @override
  void initState() {
    super.initState();
    _fetchNearbyListings();
  }

  Future<void> _fetchNearbyListings() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _permissionDenied = false;
      _permissionDeniedForever = false;
    });

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _permissionDenied = true;
            _loading = false;
          });
        }
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _permissionDenied = true;
            _permissionDeniedForever = true;
            _loading = false;
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _currentLat = position.latitude;
      _currentLng = position.longitude;

      final apiClient = sl<ApiClient>();
      final response = await apiClient.get(
        '${ApiConstants.listing}/nearby',
        queryParameters: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'maxDistance': 10000,
          'limit': 10,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final listingsJson = response.data['data'] as List<dynamic>;
        final results = <_NearbyListing>[];

        for (final json in listingsJson) {
          final map = json as Map<String, dynamic>;
          final listing = ListingModel.fromJson(map);
          final distance = (map['distance'] as num?)?.toDouble();

          if (map['location'] != null &&
              map['location']['coordinates'] != null) {
            final coords = map['location']['coordinates'] as List<dynamic>;
            if (coords.length >= 2) {
              final loc = ListingLocation(
                latitude: (coords[1] as num).toDouble(),
                longitude: (coords[0] as num).toDouble(),
              );
              final updatedListing = listing.copyWith(location: loc);
              results.add(
                _NearbyListing(listing: updatedListing, distanceMiles: distance),
              );
              continue;
            }
          }
          results.add(_NearbyListing(listing: listing, distanceMiles: distance));
        }

        if (mounted) {
          setState(() {
            _nearbyListings = results;
            _loading = false;
          });
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching nearby deals: $e');
      debugPrint('$stackTrace');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openMap(BuildContext context) {
    if (_currentLat == null || _currentLng == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DealsMapPage(
          listings: _nearbyListings.map((e) => e.listing).toList(),
          initialLat: _currentLat!,
          initialLng: _currentLng!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);

    if (_loading) {
      return DashboardSectionContainer(
        title: l10n.dealsNearYou,
        child: const _DealsNearYouShimmerRow(),
      );
    }

    if (_permissionDenied) {
      return DashboardSectionContainer(
        title: l10n.dealsNearYou,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: _InlineStatusCard(
            icon: Iconsax.location_slash,
            iconColor: colors.warning,
            title: l10n.dealsNearYouLocationOff,
            subtitle: l10n.dealsNearYouLocationHint,
            actions: [
              TextButton(
                onPressed: _fetchNearbyListings,
                child: Text(l10n.retry),
              ),
              if (_permissionDeniedForever)
                TextButton(
                  onPressed: () => Geolocator.openAppSettings(),
                  child: Text(l10n.dealsNearYouOpenSettings),
                ),
            ],
          ),
        ),
      );
    }

    if (_nearbyListings.isEmpty || _currentLat == null) {
      return DashboardSectionContainer(
        title: l10n.dealsNearYou,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: _InlineStatusCard(
            icon: Iconsax.map_1,
            iconColor: colors.textLight,
            title: l10n.dealsNearYouEmpty,
            subtitle: null,
            actions: const [],
          ),
        ),
      );
    }

    return DashboardSectionContainer(
      title: l10n.dealsNearYou,
      actionLabel: l10n.dealsNearYouMap,
      onActionTap: () => _openMap(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.routing,
                    size: 13.sp,
                    color: colors.primary,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    l10n.dealsNearYouRadiusKm,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 248.h,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: _nearbyListings.length,
              itemBuilder: (context, index) {
                final item = _nearbyListings[index];
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: FadeSlideIn(
                      index: index,
                      child: _NearbyCard(
                        listing: item.listing,
                        distanceMiles: item.distanceMiles,
                        onWishlistTap: () {
                          context.read<ListingsBloc>().add(
                            ListingWishlistToggled(listingId: item.listing.id),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyListing {
  final Listing listing;
  final double? distanceMiles;

  _NearbyListing({required this.listing, this.distanceMiles});
}

class _DealsNearYouShimmerRow extends StatelessWidget {
  const _DealsNearYouShimmerRow();

  @override
  Widget build(BuildContext context) {
    final base = AppColors.of(context).border;
    final highlight = AppColors.of(context).subtleFill;

    return SizedBox(
      height: 248.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Shimmer.fromColors(
              baseColor: base,
              highlightColor: highlight,
              child: Container(
                width: 158.w,
                decoration: BoxDecoration(
                  color: AppColors.of(context).card,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InlineStatusCard extends StatelessWidget {
  const _InlineStatusCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.actions,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: colors.subtleFill,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, size: 22.sp, color: iconColor),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: colors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (actions.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Wrap(spacing: 4.w, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}

class _NearbyCard extends StatelessWidget {
  final Listing listing;
  final double? distanceMiles;
  final VoidCallback onWishlistTap;

  const _NearbyCard({
    required this.listing,
    this.distanceMiles,
    required this.onWishlistTap,
  });

  String _meetupLabel(Listing listing) {
    return listing.location?.name ??
        listing.location?.address ??
        listing.district ??
        (listing.meetupPreferences == 'campus'
            ? 'Campus'
            : listing.meetupPreferences == 'public'
                ? 'Public meetup'
                : 'Flexible');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);
    final imageUrl = listing.primaryImageUrl ?? '';
    final sellerName =
        listing.seller?.username ?? listing.seller?.name ?? l10n.notSpecified;
    final sellerRating = listing.seller?.rating;
    final successGreen = colors.success;
    final distLabel = distanceMiles != null
        ? l10n.dealsNearYouDistMiles(distanceMiles!.toStringAsFixed(
            distanceMiles! >= 10 ? 0 : 1,
          ))
        : null;

    return PressScale(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailPage(
              heroTag: 'nearby_${listing.id}',
              imageUrl: imageUrl,
              listingId: listing.id,
            ),
          ),
        );
      },
      child: SizedBox(
        width: 158.w,
        child: Container(
          padding: EdgeInsets.fromLTRB(6.w, 6.h, 6.w, 5.h),
          decoration: BoxDecoration(
            color: colors.subtleFill,
            borderRadius: BorderRadius.circular(16.r),
            border: colors.isDark
                ? Border.all(color: colors.border, width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Stack(
                      children: [
                        ColoredBox(
                          color: colors.card,
                          child: imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  width: double.infinity,
                                  height: 124.h,
                                  fit: BoxFit.cover,
                                  placeholder: (_, _) => SizedBox(
                                    height: 124.h,
                                    child: Center(
                                      child: Icon(
                                        Iconsax.image,
                                        color: colors.border,
                                        size: 28.sp,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (_, _, _) => SizedBox(
                                    height: 124.h,
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: colors.border,
                                      size: 28.sp,
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  height: 124.h,
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: colors.border,
                                    size: 28.sp,
                                  ),
                                ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 40.h,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(
                                    alpha: colors.isDark ? 0.55 : 0.35,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (distLabel != null)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.location,
                              size: 11.sp,
                              color: colors.primary,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              distLabel,
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: onWishlistTap,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: 0.94),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colors.textPrimary.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          listing.isInWishlist ? Iconsax.heart5 : Iconsax.heart,
                          size: 15.sp,
                          color: listing.isInWishlist
                              ? colors.error
                              : colors.textLight,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8.w,
                    bottom: 8.h,
                    right: 8.w,
                    child: Text(
                      _meetupLabel(listing),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(4.w, 6.h, 4.w, 2.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: successGreen,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '(${_priceTypeShort(listing.priceType, l10n)})',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w400,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        if (listing.seller?.avatar != null &&
                            listing.seller!.avatar!.isNotEmpty)
                          CircleAvatar(
                            radius: 10.r,
                            backgroundColor: colors.border,
                            backgroundImage: CachedNetworkImageProvider(
                              listing.seller!.avatar!,
                            ),
                          )
                        else
                          CircleAvatar(
                            radius: 10.r,
                            backgroundColor: colors.border,
                            child: Icon(
                              Icons.person,
                              size: 12.sp,
                              color: colors.textSecondary,
                            ),
                          ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            sellerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                        Icon(
                          Iconsax.star1,
                          size: 12.sp,
                          color: colors.warning,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          sellerRating != null
                              ? sellerRating.toStringAsFixed(1)
                              : '—',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
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
      ),
    );
  }

  String _priceTypeShort(String priceType, AppLocalizations l10n) {
    switch (priceType.toLowerCase()) {
      case 'negotiable':
        return 'Neg.';
      case 'free':
        return l10n.free;
      default:
        return 'Fixed';
    }
  }
}
