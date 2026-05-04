import 'package:book_user_app/core/services/search_history_service.dart';
import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';
import 'package:book_user_app/features/listings/presentation/widgets/dashboard_section_container.dart';
import 'package:book_user_app/features/listings/presentation/widgets/modern_featured_card.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class RecommendedForYouSection extends StatefulWidget {
  final List<Listing> listings;

  const RecommendedForYouSection({super.key, required this.listings});

  @override
  State<RecommendedForYouSection> createState() =>
      _RecommendedForYouSectionState();
}

class _RecommendedForYouSectionState extends State<RecommendedForYouSection> {
  late final ScrollController _scrollController;
  String? _lastSearch;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadHint();
  }

  Future<void> _loadHint() async {
    final q = await sl<SearchHistoryService>().getLastQuery();
    if (!mounted) return;
    setState(() => _lastSearch = q);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listings.isEmpty) return const SizedBox.shrink();

    final colors = AppColors.of(context);
    final subtitle = _lastSearch != null && _lastSearch!.isNotEmpty
        ? 'Because you searched for "$_lastSearch"'
        : 'Popular in your campus · Trending this week';

    return DashboardSectionContainer(
      title: 'Recommended for You',
      actionLabel: 'See All',
      onActionTap: () => context.pushNamed(
        'see-all',
        pathParameters: {'type': 'recommended'},
      ),
      compactPadding: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
                height: 1.3,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
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
        ],
      ),
    );
  }
}
