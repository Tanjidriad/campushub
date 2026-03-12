import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/theme.dart';

/// Shimmer loading placeholder for cards.
class ShimmerCard extends StatelessWidget {
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const ShimmerCard({super.key, this.height, this.width, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDark
          ? AppColors.cardBorderDark
          : AppColors.cardBorderLight.withAlpha(180),
      highlightColor: context.isDark
          ? AppColors.surfaceDark
          : AppColors.backgroundLight,
      child: Container(
        height: height ?? 100.h,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: borderRadius ?? AppRadius.lg,
        ),
      ),
    );
  }
}

/// Shimmer loading for a list of cards.
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: AppSpacing.pagePadding,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: spacing.h),
      itemBuilder: (_, __) => ShimmerCard(height: itemHeight.h),
    );
  }
}

/// Shimmer loading for a grid of stat cards.
class ShimmerStatsGrid extends StatelessWidget {
  final int count;

  const ShimmerStatsGrid({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.5,
      children: List.generate(count, (_) => const ShimmerCard()),
    );
  }
}

/// Premium empty state with decorative illustration.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Layered decorative circles
            SizedBox(
              width: 120.w,
              height: 120.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(
                            context.isDark ? 0.06 : 0.05,
                          ),
                          AppColors.primary.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                  // Inner circle
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.isDark
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.primaryLight,
                    ),
                    child: Icon(
                      icon,
                      size: 36.sp,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: AppTextStyles.h4.copyWith(color: context.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: 8.h),
              Text(
                subtitle!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 24.h),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: AppRadius.md,
                  boxShadow: AppShadows.primaryGlow(0.2),
                ),
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
                  ),
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A premium stat card with colored left accent border.
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? badge;
  final String? trend;
  final bool trendUp;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.badge,
    this.trend,
    this.trendUp = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: AppRadius.lg,
          border: Border.all(color: context.cardBorder),
          boxShadow: AppShadows.card,
        ),
        child: Stack(
          children: [
            // Colored left accent border
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color, color.withOpacity(0.4)],
                  ),
                ),
              ),
            ),
            // Subtle colored gradient tint in top-right corner
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withOpacity(context.isDark ? 0.08 : 0.06),
                      color.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: color.withAlpha(context.isDark ? 35 : 22),
                          borderRadius: AppRadius.sm,
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const Spacer(),
                      if (badge != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: color.withAlpha(context.isDark ? 35 : 22),
                            borderRadius: AppRadius.full,
                          ),
                          child: Text(
                            badge!,
                            style: AppTextStyles.overline.copyWith(
                              color: color,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: AppTextStyles.caption.copyWith(
                      color: context.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          style: AppTextStyles.statMedium.copyWith(
                            color: context.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (trend != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (trendUp ? AppColors.success : AppColors.error)
                                    .withAlpha(context.isDark ? 35 : 22),
                            borderRadius: AppRadius.full,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                trendUp
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                size: 12,
                                color: trendUp
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                trend!,
                                style: AppTextStyles.overline.copyWith(
                                  color: trendUp
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
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

/// A section header with optional action.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.h4.copyWith(color: context.textPrimary),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTextStyles.caption.copyWith(
                    color: context.textMuted,
                  ),
                ),
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

/// Status badge / chip.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: outlined
            ? Colors.transparent
            : color.withAlpha(context.isDark ? 40 : 26),
        borderRadius: AppRadius.full,
        border: outlined ? Border.all(color: color.withAlpha(80)) : null,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}
