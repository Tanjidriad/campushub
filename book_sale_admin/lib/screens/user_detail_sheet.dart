import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/theme.dart';
import '../features/users/domain/entities/user_entity.dart';

/// Premium user detail bottom sheet with glassmorphic header and role management.
class UserDetailSheet extends StatelessWidget {
  final AdminUserEntity user;
  final VoidCallback onBanToggle;
  final ValueChanged<String>? onRoleChange;

  const UserDetailSheet({
    super.key,
    required this.user,
    required this.onBanToggle,
    this.onRoleChange,
  });

  static void show(
    BuildContext context, {
    required AdminUserEntity user,
    required VoidCallback onBanToggle,
    ValueChanged<String>? onRoleChange,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserDetailSheet(
        user: user,
        onBanToggle: onBanToggle,
        onRoleChange: onRoleChange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: ListView(
          controller: controller,
          padding: EdgeInsets.zero,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 4.h),
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.cardBorder.withOpacity(0.3),
                      context.cardBorder,
                      context.cardBorder.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: AppRadius.full,
                ),
              ),
            ),

            // Avatar + header
            _buildHeader(context),

            Divider(height: 1, color: context.cardBorder),
            SizedBox(height: 16.h),

            // Info cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    context,
                    Icons.email_outlined,
                    'Email',
                    user.email,
                  ),
                  SizedBox(height: 12.h),
                  _buildInfoRow(
                    context,
                    Icons.shield_outlined,
                    'Role',
                    user.role[0].toUpperCase() + user.role.substring(1),
                    trailing: onRoleChange != null
                        ? _RoleDropdown(
                            currentRole: user.role,
                            onChanged: (r) {
                              onRoleChange!(r);
                              Navigator.pop(context);
                            },
                          )
                        : null,
                  ),
                  SizedBox(height: 12.h),
                  _buildInfoRow(
                    context,
                    user.isBlocked
                        ? Icons.block_rounded
                        : Icons.verified_user_outlined,
                    'Status',
                    user.isBlocked
                        ? 'Banned'
                        : user.isOnline
                        ? 'Online'
                        : 'Offline',
                    valueColor: user.isBlocked
                        ? AppColors.error
                        : user.isOnline
                        ? AppColors.success
                        : context.textMuted,
                  ),
                  SizedBox(height: 24.h),

                  // Actions
                  _buildActionButton(
                    context,
                    icon: user.isBlocked
                        ? Icons.lock_open_rounded
                        : Icons.block_rounded,
                    label: user.isBlocked ? 'Unban User' : 'Ban User',
                    color: user.isBlocked ? AppColors.success : AppColors.error,
                    onTap: () {
                      onBanToggle();
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.isDark
              ? [AppColors.primaryDark.withOpacity(0.15), AppColors.surfaceDark]
              : [AppColors.primary.withOpacity(0.04), AppColors.surfaceLight],
        ),
      ),
      child: Row(
        children: [
          // Avatar with gradient border
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: 36.r,
              backgroundImage: user.avatar != null
                  ? NetworkImage(user.avatar!)
                  : null,
              backgroundColor: context.background,
              child: user.avatar == null
                  ? Text(
                      user.name[0].toUpperCase(),
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTextStyles.h3.copyWith(color: context.textPrimary),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: user.isBlocked
                            ? AppColors.error
                            : user.isOnline
                            ? AppColors.success
                            : context.textMuted,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      user.isBlocked
                          ? 'Banned'
                          : user.isOnline
                          ? 'Online now'
                          : 'Offline',
                      style: AppTextStyles.caption.copyWith(
                        color: context.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    Widget? trailing,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.md,
        border: Border.all(color: context.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: AppRadius.sm,
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: context.textMuted,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: valueColor ?? context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: color.withAlpha(context.isDark ? 22 : 15),
            borderRadius: AppRadius.md,
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              SizedBox(width: 8.w),
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  final String currentRole;
  final ValueChanged<String> onChanged;

  const _RoleDropdown({required this.currentRole, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(15),
          borderRadius: AppRadius.sm,
          border: Border.all(color: AppColors.primary.withAlpha(40)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_outlined, size: 14, color: AppColors.primary),
            SizedBox(width: 4.w),
            Text(
              'Change',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
      itemBuilder: (_) => ['student', 'admin', 'superadmin']
          .where((r) => r != currentRole)
          .map(
            (r) => PopupMenuItem(
              value: r,
              child: Text(r[0].toUpperCase() + r.substring(1)),
            ),
          )
          .toList(),
    );
  }
}
