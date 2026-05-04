import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.04), // Ultra-subtle low-spread drop shadow
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: colors.border.withOpacity(0.5), // Tiny border-like ultra-sharp shadow
            blurRadius: 1,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActionItem(
            context: context,
            icon: Iconsax.add_square,
            label: "Sell",
            onTap: () => context.pushNamed('create-listing'),
            isPrimary: true,
          ),
          _buildActionItem(
            context: context,
            icon: Iconsax.messages_2,
            label: "Chats",
            onTap: () => context.pushNamed('conversations'),
          ),
          _buildActionItem(
            context: context,
            icon: Iconsax.ticket_discount,
            label: "Offers",
            onTap: () => context.pushNamed('offers'),
          ),
          _buildActionItem(
            context: context,
            icon: Iconsax.heart,
            label: "Saved",
            onTap: () => context.pushNamed('wishlist'), // Assuming 'wishlist' is the saved route
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final colors = AppColors.of(context);

    // If it's the primary action (Sell), the icon background is prominent
    final iconBgColor = isPrimary ? colors.primary : colors.subtleFill;
    final iconColor = isPrimary ? colors.onPrimary : colors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 12.sp,
              fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
