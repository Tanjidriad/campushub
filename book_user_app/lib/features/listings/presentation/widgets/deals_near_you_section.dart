import 'package:book_user_app/core/constants/api_constants.dart';
import 'package:book_user_app/core/network/api_client.dart';
import 'package:book_user_app/features/listings/data/models/listing_model.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/listings/presentation/pages/listing_detail_page.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';

/// Self-contained "Deals Near You" section.
/// Handles location permission, API call, and rendering — no BLoC needed.
class DealsNearYouSection extends StatefulWidget {
  const DealsNearYouSection({super.key});

  @override
  State<DealsNearYouSection> createState() => _DealsNearYouSectionState();
}

class _DealsNearYouSectionState extends State<DealsNearYouSection> {
  List<_NearbyListing> _nearbyListings = [];
  bool _loading = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _fetchNearbyListings();
  }

  Future<void> _fetchNearbyListings() async {
    try {
      // Step 1: Check & request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted)
          setState(() {
            _permissionDenied = true;
            _loading = false;
          });
        return;
      }

      // Step 2: Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      // Step 3: Call /listings/nearby
      final apiClient = sl<ApiClient>();
      final response = await apiClient.get(
        '${ApiConstants.listing}/nearby',
        queryParameters: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'maxDistance': 10000, // 10km
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
          results.add(
            _NearbyListing(listing: listing, distanceMiles: distance),
          );
        }

        if (mounted)
          setState(() {
            _nearbyListings = results;
            _loading = false;
          });
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything while loading, denied, or empty
    if (_loading || _permissionDenied || _nearbyListings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Iconsax.location,
                  size: 16.sp,
                  color: const Color(0xFFEF4444),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Deals Near You',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.gps,
                      size: 12.sp,
                      color: const Color(0xFF6B7280),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '10 km',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),

        // Horizontal scroll
        SizedBox(
          height: 195.h,
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
                child: _NearbyCard(
                  listing: item.listing,
                  distanceMiles: item.distanceMiles,
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

class _NearbyListing {
  final Listing listing;
  final double? distanceMiles;

  _NearbyListing({required this.listing, this.distanceMiles});
}

class _NearbyCard extends StatelessWidget {
  final Listing listing;
  final double? distanceMiles;

  const _NearbyCard({required this.listing, this.distanceMiles});

  String get _distanceLabel {
    if (distanceMiles == null) return '';
    // Convert miles to km (1 mile ≈ 1.60934 km)
    final km = distanceMiles! * 1.60934;
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = listing.primaryImageUrl ?? '';

    return GestureDetector(
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
      child: Container(
        width: 145.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFF0F0F5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with distance badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(14.r),
                  ),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 145.w,
                          height: 110.h,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 145.w,
                            height: 110.h,
                            color: const Color(0xFFF5F5FA),
                            child: Icon(
                              Iconsax.image,
                              color: Colors.grey[300],
                              size: 24.sp,
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 145.w,
                            height: 110.h,
                            color: const Color(0xFFF5F5FA),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey[300],
                              size: 24.sp,
                            ),
                          ),
                        )
                      : Container(
                          width: 145.w,
                          height: 110.h,
                          color: const Color(0xFFF5F5FA),
                          child: Icon(
                            Icons.image_outlined,
                            color: Colors.grey[300],
                            size: 24.sp,
                          ),
                        ),
                ),

                // Distance Badge
                if (_distanceLabel.isNotEmpty)
                  Positioned(
                    top: 6.h,
                    right: 6.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.location,
                            size: 10.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            _distanceLabel,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Info
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    listing.priceType == 'free'
                        ? 'FREE'
                        : '৳ ${listing.price?.toStringAsFixed(0) ?? '0'}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF15803D),
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
