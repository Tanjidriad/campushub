import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/listing.dart';
import '../bloc/listings_bloc.dart';
import '../bloc/listings_event.dart';
import '../bloc/listings_state.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtl;
  String _searchAll = '';
  final _searchController = TextEditingController();

  String _selectedQueueFilter = 'All';
  final List<String> _queueFilters = [
    'All',
    'Textbooks',
    'Housing',
    'Services',
  ];

  String _selectedMgmtFilter = 'All';
  final List<String> _mgmtFilters = [
    'All',
    'Housing',
    'Textbooks',
    'Events',
    'Featured',
  ];

  @override
  void initState() {
    super.initState();
    _tabCtl = TabController(length: 2, vsync: this);
    context.read<ListingsBloc>().add(const FetchPendingListingsEvent());
    _tabCtl.addListener(() {
      if (_tabCtl.indexIsChanging) {
        if (_tabCtl.index == 0) {
          context.read<ListingsBloc>().add(const FetchPendingListingsEvent());
        } else {
          _fetchManagement();
        }
      }
    });
  }

  void _fetchManagement() {
    bool? isFeatured;
    String? cat;
    if (_selectedMgmtFilter == 'Featured') {
      isFeatured = true;
    } else if (_selectedMgmtFilter != 'All') {
      cat = _selectedMgmtFilter;
    }
    context.read<ListingsBloc>().add(
      FetchAllListingsEvent(
        search: _searchAll,
        category: cat,
        isFeatured: isFeatured,
      ),
    );
  }

  @override
  void dispose() {
    _tabCtl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _approve(String id) {
    context.read<ListingsBloc>().add(ApproveListingEvent(id));
  }

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;
    final color = isError ? AppColors.error : AppColors.success;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: AppRadius.xs,
              ),
              child: Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 18,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
        margin: EdgeInsets.all(AppSpacing.lg),
        elevation: 6,
      ),
    );
  }

  Future<void> _reject(String id) async {
    final reason = await _showRejectionBottomSheet();
    if (reason == null || reason.isEmpty) return;
    if (mounted) {
      context.read<ListingsBloc>().add(RejectListingEvent(id, reason));
    }
  }

  Future<void> _delete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: AppRadius.sm,
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: AppColors.error,
                size: 22,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Text(
              'Delete Listing',
              style: AppTextStyles.h4.copyWith(color: context.textPrimary),
            ),
          ],
        ),
        content: Text(
          'This action cannot be undone. The listing will be permanently removed.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: context.textSecondary,
          ),
        ),
        actionsPadding: EdgeInsets.all(AppSpacing.lg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMedium.copyWith(
                color: context.textMuted,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (mounted) context.read<ListingsBloc>().add(DeleteListingEvent(id));
  }

  Future<void> _toggleFeature(String id) async {
    context.read<ListingsBloc>().add(ToggleFeatureListingEvent(id));
  }

  Future<String?> _showRejectionBottomSheet() async {
    final controller = TextEditingController();
    String? predefinedReason;

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: ctx.cardColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 12.h),
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: ctx.dividerColor,
                          borderRadius: AppRadius.full,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),

                    // Header with icon
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: AppRadius.md,
                          ),
                          child: const Icon(
                            Icons.block_rounded,
                            color: AppColors.error,
                            size: 22,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reject Listing',
                                style: AppTextStyles.h4.copyWith(
                                  color: ctx.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'This will be shared with the user',
                                style: AppTextStyles.caption.copyWith(
                                  color: ctx.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: ctx.textMuted),
                          onPressed: () => Navigator.pop(ctx),
                          style: IconButton.styleFrom(
                            backgroundColor: ctx.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.sm,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xl),

                    // Quick Reasons
                    Text(
                      'QUICK REASONS',
                      style: AppTextStyles.overline.copyWith(
                        color: ctx.textMuted,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children:
                          [
                            'Spam',
                            'Prohibited Item',
                            'Misleading Info',
                            'Duplicate',
                          ].map((reason) {
                            final isSelected = predefinedReason == reason;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setModalState(() {
                                      if (isSelected) {
                                        predefinedReason = null;
                                        controller.text = '';
                                      } else {
                                        predefinedReason = reason;
                                        controller.text = reason;
                                      }
                                    });
                                  },
                                  borderRadius: AppRadius.sm,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 10.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.error.withAlpha(20)
                                          : ctx.surface,
                                      borderRadius: AppRadius.sm,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.error.withAlpha(100)
                                            : ctx.cardBorder,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isSelected) ...[
                                          Icon(
                                            Icons.check_circle,
                                            size: 16.sp,
                                            color: AppColors.error,
                                          ),
                                          SizedBox(width: 6.w),
                                        ],
                                        Text(
                                          reason,
                                          style: AppTextStyles.labelMedium
                                              .copyWith(
                                                color: isSelected
                                                    ? AppColors.error
                                                    : ctx.textPrimary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    SizedBox(height: AppSpacing.lg),

                    // Text Field
                    TextField(
                      controller: controller,
                      maxLines: 3,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: ctx.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add specific details (required)...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: ctx.textMuted,
                        ),
                        filled: true,
                        fillColor: ctx.surface,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.md,
                          borderSide: BorderSide(color: ctx.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.md,
                          borderSide: BorderSide(color: ctx.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.md,
                          borderSide: const BorderSide(
                            color: AppColors.error,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (controller.text.trim().isEmpty) return;
                          Navigator.pop(ctx, controller.text.trim());
                        },
                        icon: const Icon(Icons.block_rounded, size: 20),
                        label: Text(
                          'Confirm Rejection',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.md,
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${(diff.inDays / 7).floor()}w ago';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListingsBloc, ListingsState>(
      listener: (context, state) {
        if (!mounted) return;
        if (state is ListingActionSuccess) {
          _showToast(state.message);
          if (!mounted) return;
          if (_tabCtl.index == 0) {
            context.read<ListingsBloc>().add(const FetchPendingListingsEvent());
          } else {
            _fetchManagement();
          }
        } else if (state is ListingsError) {
          _showToast(state.message, isError: true);
        }
      },
      child: Column(
        children: [
          // ── Header ──
          _buildHeader(),

          // ── Content ──
          Expanded(
            child: TabBarView(
              controller: _tabCtl,
              children: [_buildQueueTab(), _buildManagementTab()],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── HEADER ──────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(bottom: BorderSide(color: context.cardBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: AppRadius.md,
              ),
              child: TabBar(
                controller: _tabCtl,
                indicator: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: AppRadius.sm,
                  boxShadow: AppShadows.sm,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: context.textPrimary,
                unselectedLabelColor: context.textMuted,
                labelStyle: AppTextStyles.labelMedium,
                unselectedLabelStyle: AppTextStyles.labelMedium,
                dividerColor: Colors.transparent,
                indicatorPadding: EdgeInsets.all(3.w),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('Approval'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.grid_view_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('Management'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── FILTER CHIP ─────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int? count,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.full,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  )
                : null,
            color: isSelected ? null : context.cardColor,
            borderRadius: AppRadius.full,
            border: Border.all(
              color: isSelected ? Colors.transparent : context.cardBorder,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(40),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? Colors.white : context.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
              if (count != null) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withAlpha(40)
                        : context.surface,
                    borderRadius: AppRadius.full,
                  ),
                  child: Text(
                    '$count',
                    style: AppTextStyles.overline.copyWith(
                      color: isSelected ? Colors.white : context.textMuted,
                      fontSize: 9.sp,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── APPROVAL QUEUE TAB ──────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Widget _buildQueueTab() {
    return BlocBuilder<ListingsBloc, ListingsState>(
      builder: (context, state) {
        List<Listing> pending = [];
        bool isLoading = true;

        if (state is ListingsLoaded) {
          pending = state.pendingListings;
          isLoading = false;
        } else if (state is ListingsInitial || state is ListingsError) {
          isLoading = false;
        }

        // Local filter
        List<Listing> displayed = pending;
        if (_selectedQueueFilter != 'All') {
          displayed = pending.where((listing) {
            final cat = listing.category?.toLowerCase() ?? '';
            if (_selectedQueueFilter == 'Housing' && cat.contains('hous')) {
              return true;
            }
            if (_selectedQueueFilter == 'Textbooks' && cat.contains('book')) {
              return true;
            }
            if (_selectedQueueFilter == 'Services' && cat.contains('servic')) {
              return true;
            }
            return cat == _selectedQueueFilter.toLowerCase();
          }).toList();
        }

        return Column(
          children: [
            // Filter Chips
            Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: _queueFilters.map((filter) {
                    final isSelected = filter == _selectedQueueFilter;
                    int count = 0;
                    if (filter == 'All') {
                      count = pending.length;
                    } else {
                      count = pending.where((l) {
                        final cat = l.category?.toLowerCase() ?? '';
                        if (filter == 'Housing' && cat.contains('hous')) {
                          return true;
                        }
                        if (filter == 'Textbooks' && cat.contains('book')) {
                          return true;
                        }
                        if (filter == 'Services' && cat.contains('servic')) {
                          return true;
                        }
                        return cat == filter.toLowerCase();
                      }).length;
                    }
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: _buildFilterChip(
                        label: filter,
                        isSelected: isSelected,
                        count: count,
                        onTap: () =>
                            setState(() => _selectedQueueFilter = filter),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // List Content
            Expanded(
              child: isLoading
                  ? Padding(
                      padding: AppSpacing.pagePadding,
                      child: const ShimmerList(
                        itemCount: 4,
                        itemHeight: 180,
                        spacing: 16,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        context.read<ListingsBloc>().add(
                          const FetchPendingListingsEvent(),
                        );
                      },
                      color: AppColors.primary,
                      child: displayed.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(height: 80.h),
                                EmptyState(
                                  icon: Icons.check_circle_outline_rounded,
                                  title: 'All caught up!',
                                  subtitle:
                                      'No pending listings to review right now.',
                                  actionLabel: 'Refresh',
                                  onAction: () => context
                                      .read<ListingsBloc>()
                                      .add(const FetchPendingListingsEvent()),
                                ),
                              ],
                            )
                          : AnimationLimiter(
                              child: ListView.builder(
                                padding: EdgeInsets.fromLTRB(
                                  20.w,
                                  4.h,
                                  20.w,
                                  20.h,
                                ),
                                itemCount: displayed.length,
                                itemBuilder: (context, index) {
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 400),
                                    child: SlideAnimation(
                                      verticalOffset: 30,
                                      child: FadeInAnimation(
                                        child: _buildPendingCard(
                                          displayed[index],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── PENDING CARD ────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Widget _buildPendingCard(Listing listing) {
    final images = listing.images ?? [];
    final seller = listing.seller;
    final sellerName = seller?.name ?? 'Unknown User';
    final sellerRole = seller?.role ?? 'student';

    final category = listing.category ?? 'Uncategorized';
    final catColor = _getCategoryColor(category);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.lg,
        border: Border.all(color: context.cardBorder),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Seller Header ──
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Row(
              children: [
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withAlpha(40),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 18.r,
                    backgroundImage: seller?.avatar != null
                        ? CachedNetworkImageProvider(seller!.avatar!)
                        : null,
                    backgroundColor: AppColors.primaryLight,
                    child: seller?.avatar == null
                        ? Text(
                            sellerName.isNotEmpty
                                ? sellerName[0].toUpperCase()
                                : '?',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sellerName,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        '${sellerRole[0].toUpperCase()}${sellerRole.substring(1)} · ${_timeAgo(listing.createdAt)}',
                        style: AppTextStyles.caption.copyWith(
                          color: context.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Category Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: catColor.withAlpha(context.isDark ? 30 : 18),
                    borderRadius: AppRadius.xs,
                    border: Border.all(
                      color: catColor.withAlpha(context.isDark ? 60 : 40),
                    ),
                  ),
                  child: Text(
                    category,
                    style: AppTextStyles.overline.copyWith(
                      color: catColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Content Row ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title ?? '',
                        style: AppTextStyles.h4.copyWith(
                          color: context.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: AppRadius.xs,
                        ),
                        child: Text(
                          '৳${listing.price ?? 0}',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        listing.description ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),

                // Image
                ClipRRect(
                  borderRadius: AppRadius.md,
                  child: images.isNotEmpty && images[0].url != null
                      ? CachedNetworkImage(
                          imageUrl: images[0].url!,
                          width: 80.w,
                          height: 80.w,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _imgShimmer(),
                          errorWidget: (_, __, ___) =>
                              _imgPlaceholder(catColor, category),
                        )
                      : _imgPlaceholder(catColor, category),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // ── Action Buttons ──
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: context.cardBorder)),
            ),
            child: Row(
              children: [
                // Reject Button
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _reject(listing.id),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: AppColors.error.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16.sp,
                                color: AppColors.error,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Reject',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Container(width: 1, height: 48.h, color: context.cardBorder),

                // Approve Button
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _approve(listing.id),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(16.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: AppColors.success.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 16.sp,
                                color: AppColors.success,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Approve',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.success,
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
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── MANAGEMENT TAB ──────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Widget _buildManagementTab() {
    return BlocBuilder<ListingsBloc, ListingsState>(
      builder: (context, state) {
        List<Listing> all = [];
        bool isLoading = true;

        if (state is ListingsLoaded) {
          all = state.activeListings;
          isLoading = false;
        } else if (state is ListingsInitial || state is ListingsError) {
          isLoading = false;
        }

        return Column(
          children: [
            // ── Search + Filters ──
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: AppRadius.md,
                  border: Border.all(color: context.cardBorder),
                  boxShadow: AppShadows.sm,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 14.w),
                      child: Icon(
                        Icons.search_rounded,
                        color: context.textMuted,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: context.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search listings...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: context.textMuted,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onSubmitted: (val) {
                          _searchAll = val;
                          _fetchManagement();
                        },
                      ),
                    ),
                    if (_searchAll.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: context.textMuted,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _searchAll = '';
                          _fetchManagement();
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Filter Chips
            Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: _mgmtFilters.map((filter) {
                    final isSelected = filter == _selectedMgmtFilter;
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: _buildFilterChip(
                        label: filter,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _selectedMgmtFilter = filter);
                          _fetchManagement();
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // List
            Expanded(
              child: isLoading
                  ? Padding(
                      padding: AppSpacing.pagePadding,
                      child: const ShimmerList(
                        itemCount: 5,
                        itemHeight: 120,
                        spacing: 16,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => _fetchManagement(),
                      color: AppColors.primary,
                      child: all.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(height: 80.h),
                                EmptyState(
                                  icon: Icons.inventory_2_outlined,
                                  title: 'No listings found',
                                  subtitle:
                                      'Try adjusting your filters or search query.',
                                  actionLabel: 'Clear Filters',
                                  onAction: () {
                                    setState(() => _selectedMgmtFilter = 'All');
                                    _searchAll = '';
                                    _searchController.clear();
                                    _fetchManagement();
                                  },
                                ),
                              ],
                            )
                          : AnimationLimiter(
                              child: ListView.builder(
                                padding: EdgeInsets.fromLTRB(
                                  20.w,
                                  4.h,
                                  20.w,
                                  20.h,
                                ),
                                itemCount: all.length,
                                itemBuilder: (context, index) {
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 350),
                                    child: SlideAnimation(
                                      verticalOffset: 24,
                                      child: FadeInAnimation(
                                        child: _buildManagedCard(all[index]),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── MANAGED CARD ────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Widget _buildManagedCard(Listing listing) {
    final images = listing.images ?? [];
    final seller = listing.seller;
    final sellerEmail = seller?.email ?? '@unknown';
    final isFeatured = listing.isFeatured == true;
    final status = listing.status ?? 'active';
    final isReported = listing.reportCount != null && listing.reportCount! > 0;

    // Status visual mapping
    Color statusColor = AppColors.success;
    String statusText = 'ACTIVE';
    IconData statusIcon = Icons.check_circle;
    if (status == 'rejected' || isReported) {
      statusColor = isReported ? AppColors.warning : AppColors.error;
      statusText = isReported ? 'REPORTED' : 'REJECTED';
      statusIcon = isReported
          ? Icons.warning_amber_rounded
          : Icons.cancel_rounded;
    } else if (status == 'pending') {
      statusColor = AppColors.warning;
      statusText = 'PENDING';
      statusIcon = Icons.schedule_rounded;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.lg,
        border: Border.all(
          color: isReported
              ? AppColors.warning.withAlpha(80)
              : context.cardBorder,
          width: isReported ? 1.5 : 1,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with Status Badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.md,
                      child: images.isNotEmpty && images[0].url != null
                          ? CachedNetworkImage(
                              imageUrl: images[0].url!,
                              width: 76.w,
                              height: 76.w,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => _imgShimmer(size: 76),
                              errorWidget: (_, __, ___) =>
                                  _imgPlaceholder(null, null, size: 76),
                            )
                          : _imgPlaceholder(null, null, size: 76),
                    ),
                    // Status Badge
                    Positioned(
                      top: -6.h,
                      left: -6.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: AppRadius.xs,
                          border: Border.all(
                            color: context.cardColor,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withAlpha(60),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 10, color: Colors.white),
                            SizedBox(width: 3.w),
                            Text(
                              statusText,
                              style: AppTextStyles.overline.copyWith(
                                color: Colors.white,
                                fontSize: 8.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Reported backdrop overlay
                    if (isReported)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(80),
                            borderRadius: AppRadius.md,
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 14.w),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title ?? '',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: context.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          if (isReported)
                            Container(
                              margin: EdgeInsets.only(right: 6.w),
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withAlpha(25),
                                borderRadius: AppRadius.xs,
                                border: Border.all(
                                  color: AppColors.warning.withAlpha(60),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.flag_rounded,
                                    size: 10,
                                    color: AppColors.warning,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    '${listing.reportCount} Reports',
                                    style: AppTextStyles.overline.copyWith(
                                      color: AppColors.warning,
                                      fontSize: 9.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: Text(
                              '$sellerEmail · ${_timeAgo(listing.createdAt)}',
                              style: AppTextStyles.caption.copyWith(
                                color: context.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '৳${listing.price ?? 0}',
                        style: AppTextStyles.statSmall.copyWith(
                          color: isReported
                              ? context.textMuted
                              : AppColors.primary,
                          decoration: isReported
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Action Row ──
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: context.surface,
              border: Border(top: BorderSide(color: context.cardBorder)),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                // Featured Toggle
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isFeatured
                        ? AppColors.primary.withAlpha(15)
                        : Colors.transparent,
                    borderRadius: AppRadius.sm,
                    border: Border.all(
                      color: isFeatured
                          ? AppColors.primary.withAlpha(40)
                          : context.cardBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFeatured
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 16,
                        color: isFeatured
                            ? AppColors.primary
                            : context.textMuted,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Featured',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isFeatured
                              ? AppColors.primary
                              : context.textMuted,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      SizedBox(
                        height: 20.h,
                        width: 36.w,
                        child: Switch(
                          value: isFeatured,
                          onChanged: isReported
                              ? null
                              : (_) => _toggleFeature(listing.id),
                          activeThumbColor: AppColors.primary,
                          activeTrackColor: AppColors.primary.withAlpha(80),
                          inactiveThumbColor: context.textMuted,
                          inactiveTrackColor: context.cardBorder,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Delete Button
                if (isReported)
                  ElevatedButton.icon(
                    onPressed: () => _delete(listing.id),
                    icon: const Icon(Icons.gavel_rounded, size: 16),
                    label: Text(
                      'Ban & Delete',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
                      elevation: 0,
                    ),
                  )
                else
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _delete(listing.id),
                      borderRadius: AppRadius.sm,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(12),
                          borderRadius: AppRadius.sm,
                          border: Border.all(
                            color: AppColors.error.withAlpha(30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: AppColors.error,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Delete',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── HELPERS ─────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Color _getCategoryColor(String category) {
    final lCat = category.toLowerCase();
    if (lCat.contains('book')) return AppColors.info;
    if (lCat.contains('hous')) return AppColors.success;
    if (lCat.contains('service')) return const Color(0xFF8B5CF6);
    if (lCat.contains('event')) return AppColors.warning;
    return AppColors.primary;
  }

  Widget _imgPlaceholder(Color? color, String? category, {double size = 80}) {
    final c = color ?? AppColors.primary;
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.withAlpha(20), c.withAlpha(8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.md,
        border: Border.all(color: c.withAlpha(30)),
      ),
      child: Icon(
        category != null && category.toLowerCase().contains('service')
            ? Icons.school_rounded
            : Icons.image_outlined,
        color: c.withAlpha(100),
        size: (size * 0.4).sp,
      ),
    );
  }

  Widget _imgShimmer({double size = 80}) {
    return ShimmerCard(
      width: size.w,
      height: size.w,
      borderRadius: AppRadius.md,
    );
  }
}
