// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:ui';

import 'package:book_user_app/core/constants/api_constants.dart';
import 'package:book_user_app/core/network/api_client.dart';
import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_cached_image.dart';
import 'package:book_user_app/features/listings/data/models/listing_model.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/listings/presentation/pages/listing_detail_page.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HighlightsBannerSection extends StatefulWidget {
  const HighlightsBannerSection({super.key});

  @override
  State<HighlightsBannerSection> createState() =>
      _HighlightsBannerSectionState();
}

class _HighlightsBannerSectionState extends State<HighlightsBannerSection> {
  List<Listing> _highlights = [];
  bool _loading = true;
  int _currentPage = 0;

  late final PageController _pageController;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadHighlights();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadHighlights() async {
    try {
      final apiClient = sl<ApiClient>();
      final response = await apiClient.get(
        '${ApiConstants.listing}/highlights',
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'] as List;
        final listings = data
            .map((e) => ListingModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (mounted) {
          setState(() {
            _highlights = listings.take(8).toList();
            _loading = false;
          });
          _startAutoScroll();
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startAutoScroll() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _highlights.isEmpty) return;
      final next = (_currentPage + 1) % _highlights.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildShimmer();
    if (_highlights.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 250.h,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _highlights.length,
            itemBuilder: (context, index) {
              return _BannerCard(listing: _highlights[index]);
            },
          ),
        ),
        SizedBox(height: 10.h),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_highlights.length, (i) {
            final active = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: active ? 16.w : 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.of(context).primary
                    : AppColors.of(context).border,
                borderRadius: BorderRadius.circular(3.r),
              ),
            );
          }),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 250.h,
        decoration: BoxDecoration(
          color: AppColors.of(context).border,
          borderRadius: BorderRadius.circular(26.r),
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final Listing listing;
  const _BannerCard({required this.listing});

  Color _accentColor(bool isPriceDrop) {
    return isPriceDrop ? const Color(0xFFE86A5B) : const Color(0xFF2F7CF6);
  }

  @override
  Widget build(BuildContext context) {
    final isPriceDrop = listing.highlightType == 'price_drop';
    final imageUrl = listing.primaryImageUrl ?? '';
    final dropPercent =
        (isPriceDrop &&
            listing.previousPrice != null &&
            listing.price != null &&
            listing.previousPrice! > 0)
        ? (((listing.previousPrice! - listing.price!) /
                      listing.previousPrice!) *
                  100)
              .round()
        : 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailPage(
              heroTag: 'highlight_${listing.id}',
              imageUrl: imageUrl,
              listingId: listing.id,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 210.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _accentColor(isPriceDrop).withOpacity(0.95),
                    _accentColor(isPriceDrop).withOpacity(0.72),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _accentColor(isPriceDrop).withOpacity(0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl.isNotEmpty) ...[
                    // Blurred backdrop fills any dead space from non-standard aspect ratios
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: AppCachedImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Dark tint over blur
                    Container(color: Colors.black.withOpacity(0.45)),
                    // Main image — contained so it's never awkwardly cropped
                    Padding(
                      padding: EdgeInsets.only(bottom: 60.h),
                      child: AppCachedImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ] else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _accentColor(isPriceDrop),
                            _accentColor(isPriceDrop).withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  // Subtle bottom gradient to blend into the white card
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.35),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16.h,
                    left: 16.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPriceDrop
                                ? Icons.local_fire_department_rounded
                                : Icons.auto_awesome_rounded,
                            size: 14.sp,
                            color: _accentColor(isPriceDrop),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            isPriceDrop
                                ? (dropPercent > 0
                                      ? '$dropPercent% OFF'
                                      : 'Price Drop')
                                : 'New Arrival',
                            style: TextStyle(
                              color: const Color(0xFF111827),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 14.w,
              right: 14.w,
              bottom: 20.h,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22.r),
                      color: Colors.white.withOpacity(0.78),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isPriceDrop
                                ? 'Save more on this listing'
                                : 'Freshly posted for you',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF6B7280),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            listing.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF111827),
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              height: 1.08,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 4.h,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (isPriceDrop && listing.previousPrice != null)
                                Text(
                                  '${listing.currency} ${listing.previousPrice!.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: const Color(0xFF9CA3AF),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                listing.priceType == 'free'
                                    ? 'Free'
                                    : listing.price != null
                                    ? '${listing.currency} ${listing.price!.toStringAsFixed(0)}'
                                    : 'Negotiable',
                                style: TextStyle(
                                  color: _accentColor(isPriceDrop),
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: _accentColor(isPriceDrop),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
