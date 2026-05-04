import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/report.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final String _selectedFilter = 'all';

  // Per-tab cache
  final Map<String, List<Report>> _tabCache = {};
  final Map<String, bool> _tabHasReachedMax = {};
  final Map<String, int> _tabCounts = {
    'pending': 0,
    'reviewed': 0,
    'resolved': 0,
  };

  String get _currentStatus =>
      const ['pending', 'reviewed', 'resolved'][_tabController.index];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      if (_tabCache.containsKey(_currentStatus)) {
        setState(() {}); // rebuild with cached data
      } else {
        _loadReports();
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ReportsBloc>().add(const LoadMoreReportsEvent());
    }
  }

  void _loadReports({bool forceRefresh = false}) {
    final status = _currentStatus;
    if (forceRefresh) _tabCache.remove(status);
    String? targetType;
    if (_selectedFilter == 'user') targetType = 'user';
    if (_selectedFilter == 'listing') targetType = 'listing';
    context.read<ReportsBloc>().add(
      LoadReportsEvent(status: status, targetType: targetType, isRefresh: true),
    );
  }

  void _showDetailsSheet(Report report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ReportDetailsSheet(
        report: report,
        onSave: (status, action, resolution) {
          context.read<ReportsBloc>().add(
            ReviewReportEvent(
              id: report.id,
              newStatus: status,
              actionTaken: action,
              resolution: resolution,
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── BUILD ───────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportsBloc, ReportsState>(
      listener: (context, state) {
        if (state is ReportsLoaded) {
          final status = state.currentStatusFilter ?? _currentStatus;
          _tabCache[status] = state.reports;
          _tabHasReachedMax[status] = state.hasReachedMax;
          _tabCounts[status] = state.reports.length;
          if (state.actionError != null) {
            _showSnack(state.actionError!, isError: true);
          }
        } else if (state is ReportActionSuccess) {
          _showSnack(state.message);
          _tabCache.clear();
          _tabHasReachedMax.clear();
          _tabCounts.updateAll((key, value) => 0);
        } else if (state is ReportsError) {
          _showSnack(state.message, isError: true);
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        );
      },
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppColors.cardLight.withAlpha(30),
                borderRadius: AppRadius.xs,
              ),
              child: Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: AppColors.cardLight,
                size: 18,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.cardLight),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
        margin: EdgeInsets.all(AppSpacing.lg),
        elevation: 8,
        duration: const Duration(seconds: 3),
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
            color: Colors.black.withAlpha(context.isDark ? 12 : 6),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: AppRadius.md,
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: AppRadius.sm,
                  border: Border.all(
                    color: AppColors.primary.withAlpha(
                      context.isDark ? 60 : 35,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(
                        context.isDark ? 20 : 12,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                    ...AppShadows.sm,
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: context.textPrimary,
                unselectedLabelColor: context.textMuted,
                labelStyle: AppTextStyles.labelMedium,
                unselectedLabelStyle: AppTextStyles.labelMedium,
                dividerColor: Colors.transparent,
                indicatorPadding: EdgeInsets.all(3.w),
                tabs: [
                  _buildTab(
                    Icons.pending_actions_rounded,
                    'Pending',
                    _tabCounts['pending'] ?? 0,
                    AppColors.warning,
                  ),
                  _buildTab(
                    Icons.visibility_rounded,
                    'Reviewed',
                    _tabCounts['reviewed'] ?? 0,
                    AppColors.info,
                  ),
                  _buildTab(
                    Icons.check_circle_rounded,
                    'Resolved',
                    _tabCounts['resolved'] ?? 0,
                    AppColors.success,
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

  Tab _buildTab(IconData icon, String label, int count, Color badgeColor) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          SizedBox(width: 4.w),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          if (count > 0) ...[
            SizedBox(width: 4.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: badgeColor.withAlpha(context.isDark ? 40 : 25),
                borderRadius: AppRadius.full,
              ),
              child: Text(
                '$count',
                style: AppTextStyles.overline.copyWith(
                  color: badgeColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── BODY ────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildReportsList('pending'),
        _buildReportsList('reviewed'),
        _buildReportsList('resolved'),
      ],
    );
  }

  Widget _buildReportsList(String tabStatus) {
    final cachedReports = _tabCache[tabStatus];
    final cachedHasMax = _tabHasReachedMax[tabStatus] ?? true;

    // Show shimmer if this tab has no cached data yet
    if (cachedReports == null) {
      return _buildShimmerList();
    }

    List<Report> displayReports = cachedReports;

    // Apply local high_priority filter
    if (_selectedFilter == 'high_priority') {
      displayReports = displayReports
          .where(
            (r) =>
                r.reason.toLowerCase() == 'fraud' ||
                r.reason.toLowerCase() == 'harassment',
          )
          .toList();
    }

    if (displayReports.isEmpty) {
      return EmptyState(
        icon: Icons.flag_outlined,
        title: 'No reports found',
        subtitle: 'No reports matching the current filters.',
        actionLabel: 'Refresh',
        onAction: () => _loadReports(forceRefresh: true),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        controller: tabStatus == _currentStatus ? _scrollController : null,
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        itemCount: displayReports.length + (cachedHasMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= displayReports.length) {
            return Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 350),
            child: SlideAnimation(
              horizontalOffset: 30,
              child: FadeInAnimation(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _buildReportCard(displayReports[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Shimmer.fromColors(
          baseColor: context.isDark
              ? AppColors.cardLight.withAlpha(8)
              : Colors.grey.withAlpha(30),
          highlightColor: context.isDark
              ? AppColors.cardLight.withAlpha(20)
              : Colors.grey.withAlpha(15),
          child: Container(
            height: 140.h,
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: AppRadius.lg,
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── REPORT CARD ─────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Widget _buildReportCard(Report report) {
    final isListing = report.targetType == 'listing';
    final isHighPriority =
        report.reason.toLowerCase() == 'fraud' ||
        report.reason.toLowerCase() == 'harassment';
    final reasonData = _getReasonData(report.reason);

    String title = 'Unknown Target';
    String? imageUrl;
    if (report.target is ListingReportTarget) {
      final t = report.target as ListingReportTarget;
      title = t.title;
      imageUrl = t.imageUrl;
    } else if (report.target is UserReportTarget) {
      final t = report.target as UserReportTarget;
      title = t.name;
      imageUrl = t.avatar;
    }

    return GestureDetector(
      onTap: () => _showDetailsSheet(report),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: AppRadius.lg,
          border: Border.all(
            color: isHighPriority
                ? AppColors.error.withAlpha(context.isDark ? 50 : 30)
                : context.cardBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: (isHighPriority ? AppColors.error : Colors.black)
                  .withAlpha(context.isDark ? 10 : 6),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Priority accent bar
              if (isHighPriority)
                Container(
                  width: 4.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.error, AppColors.error.withAlpha(150)],
                    ),
                  ),
                ),

              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: avatar + info + badges + time
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Target avatar
                          _buildTargetAvatar(imageUrl, isListing, 44),

                          SizedBox(width: 12.w),

                          // Title + reporter + badges
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Badges row
                                Row(
                                  children: [
                                    _buildTypeBadge(isListing),
                                    if (isHighPriority) ...[
                                      SizedBox(width: 6.w),
                                      _buildPriorityBadge(),
                                    ],
                                    const Spacer(),
                                    Text(
                                      timeago.format(report.createdAt),
                                      style: AppTextStyles.caption.copyWith(
                                        color: context.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                // Title
                                Text(
                                  title,
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: context.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                // Reporter
                                Text(
                                  'Reported by ${report.reporterName}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: context.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // Reason pill
                      _buildReasonPill(
                        reasonData['label'] as String,
                        reasonData['icon'] as IconData,
                        reasonData['color'] as Color,
                      ),

                      SizedBox(height: 10.h),

                      // Description
                      Text(
                        report.description ??
                            'This listing contains items that are not allowed on the platform.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: context.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Action row (only for pending)
                      if (report.status == 'pending') ...[
                        SizedBox(height: 14.h),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showDetailsSheet(report),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryDark,
                                      ],
                                    ),
                                    borderRadius: AppRadius.sm,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withAlpha(50),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.gavel_rounded,
                                        size: 16,
                                        color: AppColors.cardLight,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        'Review',
                                        style: AppTextStyles.labelMedium
                                            .copyWith(color: AppColors.cardLight),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () {
                                context.read<ReportsBloc>().add(
                                  ReviewReportEvent(
                                    id: report.id,
                                    newStatus: 'dismissed',
                                    actionTaken: 'none',
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: context.surface,
                                  borderRadius: AppRadius.sm,
                                  border: Border.all(color: context.cardBorder),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: context.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Resolution info (for reviewed/resolved)
                      if (report.status != 'pending' &&
                          report.actionTaken != null) ...[
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getActionColor(
                              report.actionTaken!,
                            ).withAlpha(context.isDark ? 15 : 8),
                            borderRadius: AppRadius.sm,
                            border: Border.all(
                              color: _getActionColor(
                                report.actionTaken!,
                              ).withAlpha(context.isDark ? 35 : 20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getActionIcon(report.actionTaken!),
                                size: 14,
                                color: _getActionColor(report.actionTaken!),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                _getActionLabel(report.actionTaken!),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: _getActionColor(report.actionTaken!),
                                ),
                              ),
                              if (report.reviewedBy != null) ...[
                                const Spacer(),
                                Text(
                                  'by ${report.reviewedBy}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: context.textMuted,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetAvatar(String? imageUrl, bool isListing, double size) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: isListing ? AppRadius.sm : AppRadius.full,
        border: Border.all(color: context.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (ctx, url) => Icon(
                isListing ? Icons.inventory_2_rounded : Icons.person_rounded,
                size: size * 0.45,
                color: context.textMuted,
              ),
              errorWidget: (ctx, url, error) => Icon(
                isListing ? Icons.inventory_2_rounded : Icons.person_rounded,
                size: size * 0.45,
                color: context.textMuted,
              ),
            )
          : Icon(
              isListing ? Icons.inventory_2_rounded : Icons.person_rounded,
              size: size * 0.45,
              color: context.textMuted,
            ),
    );
  }

  Widget _buildTypeBadge(bool isListing) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: (isListing ? AppColors.info : AppColors.accent).withAlpha(
          context.isDark ? 25 : 12,
        ),
        borderRadius: AppRadius.xs,
        border: Border.all(
          color: (isListing ? AppColors.info : AppColors.accent).withAlpha(
            context.isDark ? 50 : 30,
          ),
        ),
      ),
      child: Text(
        isListing ? 'Listing' : 'User',
        style: AppTextStyles.overline.copyWith(
          color: isListing ? AppColors.info : AppColors.accent,
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(context.isDark ? 25 : 12),
        borderRadius: AppRadius.xs,
        border: Border.all(
          color: AppColors.error.withAlpha(context.isDark ? 50 : 30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.w,
            height: 5.w,
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.error.withAlpha(100), blurRadius: 4),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            'Urgent',
            style: AppTextStyles.overline.copyWith(
              color: AppColors.error,
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonPill(String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withAlpha(context.isDark ? 20 : 10),
        borderRadius: AppRadius.xs,
        border: Border.all(color: color.withAlpha(context.isDark ? 45 : 25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          SizedBox(width: 5.w),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── HELPERS ─────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Map<String, dynamic> _getReasonData(String reason) {
    switch (reason.toLowerCase()) {
      case 'fraud':
        return {
          'label': 'Fraud',
          'icon': Icons.payments_rounded,
          'color': AppColors.warning,
        };
      case 'harassment':
        return {
          'label': 'Harassment',
          'icon': Icons.gavel_rounded,
          'color': AppColors.error,
        };
      case 'spam':
        return {
          'label': 'Spam',
          'icon': Icons.block_rounded,
          'color': const Color(0xFFE67E22),
        };
      case 'inappropriate':
        return {
          'label': 'Inappropriate',
          'icon': Icons.visibility_off_rounded,
          'color': AppColors.error,
        };
      case 'prohibited_item':
        return {
          'label': 'Prohibited Item',
          'icon': Icons.dangerous_rounded,
          'color': AppColors.error,
        };
      case 'wrong_category':
        return {
          'label': 'Wrong Category',
          'icon': Icons.category_rounded,
          'color': AppColors.info,
        };
      case 'duplicate':
        return {
          'label': 'Duplicate',
          'icon': Icons.copy_rounded,
          'color': context.textMuted,
        };
      case 'false_information':
        return {
          'label': 'False Information',
          'icon': Icons.info_outline_rounded,
          'color': AppColors.warning,
        };
      default:
        return {
          'label': reason.replaceAll('_', ' '),
          'icon': Icons.warning_rounded,
          'color': AppColors.warning,
        };
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'user_banned':
        return AppColors.error;
      case 'content_removed':
        return AppColors.primary;
      case 'warning':
        return AppColors.warning;
      default:
        return context.textMuted;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'user_banned':
        return Icons.block_rounded;
      case 'content_removed':
        return Icons.delete_rounded;
      case 'warning':
        return Icons.warning_rounded;
      default:
        return Icons.check_rounded;
    }
  }

  String _getActionLabel(String action) {
    switch (action) {
      case 'user_banned':
        return 'User Banned';
      case 'content_removed':
        return 'Content Removed';
      case 'warning':
        return 'Warning Sent';
      case 'none':
        return 'No Action';
      default:
        return 'Dismissed';
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// ─── REPORT DETAILS BOTTOM SHEET ─────────────────────────────
// ═══════════════════════════════════════════════════════════════
class _ReportDetailsSheet extends StatefulWidget {
  final Report report;
  final Function(String status, String action, String? resolution) onSave;

  const _ReportDetailsSheet({required this.report, required this.onSave});

  @override
  State<_ReportDetailsSheet> createState() => _ReportDetailsSheetState();
}

class _ReportDetailsSheetState extends State<_ReportDetailsSheet> {
  late String _status;
  late String _actionTaken;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _status = widget.report.status == 'pending'
        ? 'resolved'
        : widget.report.status;
    _actionTaken = widget.report.actionTaken ?? 'none';
    if (widget.report.resolution != null) {
      _noteController.text = widget.report.resolution!;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isListing = widget.report.targetType == 'listing';

    String title = 'Unknown';
    String subtitle = 'Unknown ID';
    String? imageUrl;

    if (widget.report.target is ListingReportTarget) {
      final t = widget.report.target as ListingReportTarget;
      title = t.title;
      subtitle = 'Listing ID: ${t.id.substring(0, 8)}…';
      imageUrl = t.imageUrl;
    } else if (widget.report.target is UserReportTarget) {
      final t = widget.report.target as UserReportTarget;
      title = t.name;
      subtitle = t.email;
      imageUrl = t.avatar;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // ── Handle ──
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: context.dividerColor,
                  borderRadius: AppRadius.full,
                ),
              ),
            ),
          ),

          // ── Header ──
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(
                      context.isDark ? 25 : 12,
                    ),
                    borderRadius: AppRadius.sm,
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Report Details',
                    style: AppTextStyles.h4.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(
                      context.isDark ? 25 : 12,
                    ),
                    borderRadius: AppRadius.full,
                  ),
                  child: Text(
                    '#${widget.report.id.substring(0, 6)}',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: context.dividerColor, height: 1),

          // ── Scrollable Content ──
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Target Card
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: AppRadius.lg,
                      border: Border.all(color: context.cardBorder),
                    ),
                    child: Row(
                      children: [
                        _buildDetailAvatar(imageUrl, isListing),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                subtitle,
                                style: AppTextStyles.caption.copyWith(
                                  color: context.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withAlpha(
                              context.isDark ? 25 : 12,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.report_rounded,
                            size: 18,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Info rows
                  _buildInfoRow(
                    'Reason',
                    widget.report.reason.replaceAll('_', ' '),
                  ),
                  _buildInfoRow('Reporter', widget.report.reporterName),
                  _buildInfoRow(
                    'Time',
                    timeago.format(widget.report.createdAt),
                  ),
                  if (widget.report.reviewedBy != null)
                    _buildInfoRow('Reviewed by', widget.report.reviewedBy!),

                  SizedBox(height: 20.h),

                  // Description
                  _buildSectionLabel('Description'),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: AppRadius.md,
                      border: Border.all(color: context.cardBorder),
                    ),
                    child: Text(
                      widget.report.description ?? 'No description provided.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Update Status
                  _buildSectionLabel('Update Status'),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: AppRadius.md,
                      border: Border.all(color: context.cardBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _status,
                        dropdownColor: context.cardColor,
                        icon: Icon(
                          Icons.expand_more_rounded,
                          color: context.textMuted,
                        ),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: context.textPrimary,
                        ),
                        items: [
                          _buildDropdownItem(
                            'pending',
                            'Pending Review',
                            AppColors.warning,
                          ),
                          _buildDropdownItem(
                            'reviewed',
                            'Reviewed',
                            AppColors.info,
                          ),
                          _buildDropdownItem(
                            'resolved',
                            'Resolved',
                            AppColors.success,
                          ),
                        ],
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Resolution Action
                  _buildSectionLabel('Resolution Action'),
                  SizedBox(height: 10.h),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 3.2,
                    mainAxisSpacing: 10.h,
                    crossAxisSpacing: 10.w,
                    children: [
                      _buildActionTile(
                        'user_banned',
                        'Ban User',
                        Icons.block_rounded,
                        AppColors.error,
                      ),
                      _buildActionTile(
                        'content_removed',
                        'Remove Post',
                        Icons.delete_rounded,
                        AppColors.primary,
                      ),
                      _buildActionTile(
                        'none',
                        'Dismiss',
                        Icons.cancel_rounded,
                        context.textMuted,
                      ),
                      _buildActionTile(
                        'warning',
                        'Warning',
                        Icons.warning_rounded,
                        AppColors.warning,
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Admin Note
                  _buildSectionLabel('Admin Note'),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter resolution details or internal notes…',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: context.textMuted,
                      ),
                      filled: true,
                      fillColor: context.surface,
                      contentPadding: EdgeInsets.all(14.w),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.md,
                        borderSide: BorderSide(color: context.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.md,
                        borderSide: BorderSide(color: context.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.md,
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Bar ──
          Container(
            padding: EdgeInsets.fromLTRB(
              20.w,
              14.h,
              20.w,
              MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom
                  : 20.h,
            ),
            decoration: BoxDecoration(
              color: context.cardColor,
              border: Border(top: BorderSide(color: context.dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: context.textSecondary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.md,
                        side: BorderSide(color: context.cardBorder),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: context.textMuted,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave(
                        _status,
                        _actionTaken,
                        _noteController.text.isEmpty
                            ? null
                            : _noteController.text,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.cardLight,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 18),
                        SizedBox(width: 6.w),
                        Text(
                          'Save Changes',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.cardLight,
                          ),
                        ),
                      ],
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

  // Detail helpers
  Widget _buildDetailAvatar(String? imageUrl, bool isListing) {
    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: isListing ? AppRadius.md : AppRadius.full,
        border: Border.all(
          color: AppColors.primary.withAlpha(context.isDark ? 40 : 22),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (ctx, url, error) => Icon(
                isListing ? Icons.inventory_2_rounded : Icons.person_rounded,
                color: context.textMuted,
              ),
            )
          : Icon(
              isListing ? Icons.inventory_2_rounded : Icons.person_rounded,
              color: context.textMuted,
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: context.textMuted),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.labelMedium.copyWith(
                color: context.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.overline.copyWith(
        color: context.textMuted,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(
    String value,
    String label,
    Color color,
  ) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 10.w),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String value,
    String title,
    IconData icon,
    Color color,
  ) {
    final isSelected = _actionTaken == value;
    return GestureDetector(
      onTap: () => setState(() => _actionTaken = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withAlpha(context.isDark ? 30 : 15)
              : context.surface,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: isSelected
                ? color.withAlpha(context.isDark ? 80 : 50)
                : context.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? color : context.textMuted),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                title,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? color : context.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

