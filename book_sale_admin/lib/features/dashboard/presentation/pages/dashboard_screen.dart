import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _period = 'Today';

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboardEvent());
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _timeAgo(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '';
    try {
      final dt = DateTime.parse(timestamp);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  Color _activityColor(String? color) {
    switch (color) {
      case 'success':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  IconData _activityIcon(String? icon) {
    switch (icon) {
      case 'person_add':
        return Icons.person_add_rounded;
      case 'check_circle':
        return Icons.check_circle_rounded;
      case 'cancel':
        return Icons.cancel_rounded;
      case 'pending':
        return Icons.pending_rounded;
      case 'flag':
        return Icons.flag_rounded;
      case 'edit':
        return Icons.edit_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading || state is DashboardInitial) {
          return _buildShimmerLoading(context);
        }

        if (state is DashboardError) {
          return EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Could not load dashboard',
            subtitle: state.message,
            actionLabel: 'Retry',
            onAction: () =>
                context.read<DashboardBloc>().add(LoadDashboardEvent()),
          );
        }

        if (state is! DashboardLoaded) return const SizedBox.shrink();

        final users = state.stats.users ?? {};
        final listings = state.stats.listings ?? {};
        final reports = state.stats.reports ?? {};
        final charts = state.stats.charts ?? {};
        final activity = state.activity;

        return RefreshIndicator(
          onRefresh: () async =>
              context.read<DashboardBloc>().add(LoadDashboardEvent()),
          color: AppColors.primary,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              return AnimationLimiter(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 30.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      // ─── Hero Greeting Card ────────────────
                      _buildHeroGreeting(context),

                      Padding(
                        padding: AppSpacing.pagePadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─── Overview Header ───────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Overview',
                                  style: AppTextStyles.h2.copyWith(
                                    color: context.textPrimary,
                                  ),
                                ),
                                _buildPeriodSelector(context),
                              ],
                            ),
                            SizedBox(height: AppSpacing.lg),

                            // ─── Stats Grid ────────────────────
                            _buildStatsGrid(
                              context,
                              users,
                              listings,
                              reports,
                              isWide,
                            ),
                            SizedBox(height: AppSpacing.xxl),

                            // ─── Chart + Activity ──────────────
                            if (isWide)
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: _buildChartCard(
                                        context,
                                        users,
                                        charts,
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.lg),
                                    Expanded(
                                      flex: 2,
                                      child: _buildActivitySection(
                                        context,
                                        activity,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else ...[
                              _buildChartCard(context, users, charts),
                              SizedBox(height: AppSpacing.xxl),
                              _buildActivitySection(context, activity),
                            ],
                            SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── HERO GREETING ────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Widget _buildHeroGreeting(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is Authenticated ? authState.user : null;
        return Container(
          margin: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: context.isDark
                  ? [
                      AppColors.primaryDark.withOpacity(0.4),
                      AppColors.primaryDeep.withOpacity(0.2),
                    ]
                  : [
                      AppColors.primary.withOpacity(0.08),
                      AppColors.primaryLight.withOpacity(0.5),
                    ],
            ),
            borderRadius: AppRadius.xl,
            border: Border.all(
              color: AppColors.primary.withOpacity(
                context.isDark ? 0.15 : 0.12,
              ),
            ),
          ),
          child: Row(
            children: [
              // Avatar with gradient ring
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.cardColor,
                    border: Border.all(color: context.cardColor, width: 2.5),
                  ),
                  child: ClipOval(
                    child: user?.avatar != null && user!.avatar!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: user.avatar!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (_, __, ___) => Icon(
                              Icons.person_rounded,
                              color: context.textSecondary,
                              size: 28,
                            ),
                          )
                        : Icon(
                            Icons.person_rounded,
                            color: context.textSecondary,
                            size: 28,
                          ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),

              // Greeting text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greeting()} 👋',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      user?.name ?? 'Admin',
                      style: AppTextStyles.h3.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Date chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.white.withOpacity(0.7),
                  borderRadius: AppRadius.full,
                  border: Border.all(
                    color: context.isDark
                        ? Colors.white.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  _formatDate(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: context.isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate() {
    final now = DateTime.now();
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[now.weekday - 1]}, ${months[now.month]} ${now.day}';
  }

  // ═══════════════════════════════════════════════════════════
  // ─── SHIMMER LOADING ──────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Widget _buildShimmerLoading(BuildContext context) {
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        ShimmerCard(height: 90.h),
        SizedBox(height: AppSpacing.lg),
        const ShimmerStatsGrid(),
        SizedBox(height: AppSpacing.lg),
        ShimmerCard(height: 200.h),
        SizedBox(height: AppSpacing.lg),
        ShimmerCard(height: 300.h),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── PERIOD SELECTOR ──────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Widget _buildPeriodSelector(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDark
            ? AppColors.surfaceDark
            : AppColors.backgroundLight,
        borderRadius: AppRadius.full,
        border: Border.all(color: context.cardBorder),
      ),
      padding: EdgeInsets.all(3.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Today', 'Week', 'Month'].map((p) {
          final isActive = _period == p;
          return GestureDetector(
            onTap: () => setState(() => _period = p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(colors: AppColors.primaryGradient)
                    : null,
                color: isActive ? null : Colors.transparent,
                borderRadius: AppRadius.full,
                boxShadow: isActive ? AppShadows.primaryGlow(0.2) : null,
              ),
              child: Text(
                p,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isActive ? Colors.white : context.textMuted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── STATS GRID ───────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Widget _buildStatsGrid(
    BuildContext context,
    Map users,
    Map listings,
    Map reports,
    bool isWide,
  ) {
    final crossCount = isWide ? 4 : 2;
    return GridView.count(
      crossAxisCount: crossCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: isWide ? 1.6 : 1.45,
      children: [
        StatCard(
          title: 'Total Users',
          value: '${users['total'] ?? 0}',
          icon: Icons.people_rounded,
          color: AppColors.info,
          trend: '+${users['today'] ?? 0}',
          trendUp: true,
        ),
        StatCard(
          title: 'New Today',
          value: '${users['today'] ?? 0}',
          icon: Icons.person_add_rounded,
          color: AppColors.success,
        ),
        StatCard(
          title: 'Pending',
          value: '${listings['pending'] ?? 0}',
          icon: Icons.inventory_2_rounded,
          color: AppColors.warning,
          badge: (listings['pending'] ?? 0) > 0 ? 'REVIEW' : null,
        ),
        StatCard(
          title: 'Reports',
          value: '${reports['pending'] ?? 0}',
          icon: Icons.warning_amber_rounded,
          color: AppColors.error,
          badge: (reports['pending'] ?? 0) > 0 ? 'URGENT' : null,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── CHART CARD ───────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Widget _buildChartCard(BuildContext context, Map users, Map charts) {
    final chartData = charts['usersByMonth'] as List? ?? [];

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.lg,
        border: Border.all(color: context.cardBorder),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Growth',
                    style: AppTextStyles.h4.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Last 6 months',
                    style: AppTextStyles.caption.copyWith(
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.successLight.withAlpha(
                    context.isDark ? 40 : 255,
                  ),
                  borderRadius: AppRadius.full,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      size: 14,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '+${users['thisMonth'] ?? 0}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          if (chartData.isNotEmpty)
            SizedBox(height: 160.h, child: _buildFlChart(context, chartData))
          else
            SizedBox(
              height: 160.h,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.show_chart_rounded,
                      size: 32,
                      color: context.textMuted.withOpacity(0.5),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'No chart data available',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFlChart(BuildContext context, List<dynamic> chartData) {
    final values = chartData.map((d) => (d['count'] ?? 0).toDouble()).toList();
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final spots = <FlSpot>[];
    for (int i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxVal > 0 ? maxVal / 4 : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: context.dividerColor,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= chartData.length) {
                  return const SizedBox();
                }
                final monthNum = chartData[idx]['_id'] ?? 0;
                final label =
                    (monthNum is int && monthNum >= 1 && monthNum <= 12)
                    ? months[monthNum]
                    : '$monthNum';
                return Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    label,
                    style: AppTextStyles.overline.copyWith(
                      color: context.textMuted,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            gradient: const LinearGradient(colors: AppColors.primaryGradient),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, __, ___, ____) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.primary,
                strokeWidth: 2.5,
                strokeColor: context.cardColor,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withAlpha(context.isDark ? 50 : 70),
                  AppColors.primary.withAlpha(0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => context.isDark
                ? AppColors.surfaceDark
                : AppColors.textPrimaryLight,
            tooltipRoundedRadius: 8,
            getTooltipItems: (spots) => spots.map((s) {
              return LineTooltipItem(
                '${s.y.toInt()} users',
                AppTextStyles.labelSmall.copyWith(
                  color: context.isDark
                      ? AppColors.textPrimaryDark
                      : Colors.white,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── ACTIVITY SECTION ─────────────────────────────────────
  // ═══════════════════════════════════════════════════════════
  Widget _buildActivitySection(
    BuildContext context,
    List<ActivityItem> activity,
  ) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.lg,
        border: Border.all(color: context.cardBorder),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(
                        context.isDark ? 0.15 : 0.1,
                      ),
                      AppColors.primary.withOpacity(
                        context.isDark ? 0.06 : 0.03,
                      ),
                    ],
                  ),
                  borderRadius: AppRadius.sm,
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    '${activity.length} items',
                    style: AppTextStyles.overline.copyWith(
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(
                    context.isDark ? 0.12 : 0.08,
                  ),
                  borderRadius: AppRadius.full,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Live',
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          if (activity.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.isDark
                            ? AppColors.surfaceDark
                            : AppColors.backgroundLight,
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        size: 32,
                        color: context.textMuted.withOpacity(0.6),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'No recent activity',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(
              activity.length > 8 ? 8 : activity.length,
              (i) => _buildActivityItem(
                context,
                activity[i],
                isLast: i == (activity.length > 8 ? 7 : activity.length - 1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    ActivityItem a, {
    bool isLast = false,
  }) {
    final color = _activityColor(a.color);
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10.h),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withOpacity(0.03)
            : AppColors.backgroundLight.withOpacity(0.6),
        borderRadius: AppRadius.md,
        border: Border.all(color: context.cardBorder.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // Colored left accent strip
          Container(
            width: 3.5,
            height: 56.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color, color.withOpacity(0.3)],
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Icon badge
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(context.isDark ? 0.15 : 0.1),
            ),
            child: Icon(_activityIcon(a.icon), color: color, size: 15),
          ),
          SizedBox(width: 10.w),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.title ?? '',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: context.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    a.subtitle ?? '',
                    style: AppTextStyles.caption.copyWith(
                      color: context.textMuted,
                      fontSize: 11.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Time badge
          Container(
            margin: EdgeInsets.only(right: 12.w),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: context.isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.04),
              borderRadius: AppRadius.full,
            ),
            child: Text(
              _timeAgo(a.timestamp),
              style: AppTextStyles.overline.copyWith(
                color: context.textMuted,
                fontSize: 9.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
