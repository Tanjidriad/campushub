import 'package:book_user_app/core/services/recently_viewed_service.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_state.dart';
import 'package:book_user_app/features/listings/presentation/widgets/dashboard_section_container.dart';
import 'package:book_user_app/features/listings/presentation/widgets/modern_featured_card.dart';
import 'package:book_user_app/injection_container/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Horizontal carousel of locally persisted recently opened listings.
class RecentlyViewedSection extends StatefulWidget {
  const RecentlyViewedSection({super.key});

  @override
  State<RecentlyViewedSection> createState() => _RecentlyViewedSectionState();
}

class _RecentlyViewedSectionState extends State<RecentlyViewedSection> {
  List<RecentlyViewedSnapshot> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    RecentlyViewedService.revision.addListener(_onRecentlyViewedChanged);
    _load();
  }

  @override
  void dispose() {
    RecentlyViewedService.revision.removeListener(_onRecentlyViewedChanged);
    super.dispose();
  }

  void _onRecentlyViewedChanged() {
    _load();
  }

  Future<void> _load() async {
    final list = await sl<RecentlyViewedService>().getItems();
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListingsBloc, ListingsState>(
      listenWhen: (prev, curr) =>
          curr is ListingsLoaded &&
          (prev is ListingsLoading || prev is ListingsInitial),
      listener: (_, __) => _load(),
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading || _items.isEmpty) return const SizedBox.shrink();

    final stubs = _items.map((e) => e.toListingStub()).toList();

    return DashboardSectionContainer(
      title: 'Recently viewed',
      compactPadding: true,
      child: SizedBox(
        height: 250.h,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          itemCount: stubs.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: ModernFeaturedCard(listing: stubs[index]),
            );
          },
        ),
      ),
    );
  }
}
