// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/core/widgets/section_header.dart';
import 'package:book_user_app/features/listings/presentation/widgets/modern_featured_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeaturedListingsSection extends StatefulWidget {
  final List<Listing> listings;

  const FeaturedListingsSection({super.key, required this.listings});

  @override
  State<FeaturedListingsSection> createState() =>
      _FeaturedListingsSectionState();
}

class _FeaturedListingsSectionState extends State<FeaturedListingsSection> {
  late final ScrollController _scrollController;
  Timer? _autoScrollTimer;
  int _currentIndex = 0;
  static const _autoScrollDuration = Duration(seconds: 4);
  static const _scrollAnimDuration = Duration(milliseconds: 600);

  double get _itemWidth => 180.w + 16.w; // card width + right padding

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(_autoScrollDuration, (_) {
      if (!mounted || !_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;

      // If we're near the end, smoothly scroll back to start
      if (currentScroll >= maxScroll - 10) {
        _currentIndex = 0;
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      } else {
        _currentIndex++;
        final targetOffset = (_currentIndex * _itemWidth).clamp(0.0, maxScroll);
        _scrollController.animateTo(
          targetOffset,
          duration: _scrollAnimDuration,
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _pauseAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  void _resumeAutoScroll() {
    _pauseAutoScroll();
    _startAutoScroll();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const SectionHeader(title: 'Featured Ads', actionText: 'See All'),
        SizedBox(height: 24.h), // Increased spacing from 8.h to 16.h
        // Auto-scrolling carousel
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification) {
              // User started scrolling — pause auto-scroll
              if (notification.dragDetails != null) {
                _pauseAutoScroll();
              }
            } else if (notification is ScrollEndNotification) {
              // User stopped scrolling — resume after delay
              _resumeAutoScroll();
              // Update current index based on scroll position
              _currentIndex = (_scrollController.offset / _itemWidth).round();
            }
            return false;
          },
          child: SizedBox(
            height: 250.h,
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: widget.listings.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: ModernFeaturedCard(listing: widget.listings[index]),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
