import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/api_client.dart';
import '../core/theme.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onLogout;
  const SettingsScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 20.h),

        _SettingsTile(
          icon: Icons.school_outlined,
          title: 'Education Config',
          subtitle: 'Manage education levels and book types',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(
                    title: const Text('Education Config'),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  body: const _EducationConfigPage(),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 8.h),
        _SettingsTile(
          icon: Icons.info_outline,
          title: 'App Info',
          subtitle: 'CampusHub Admin v1.0.0',
        ),
        SizedBox(height: 24.h),

        // Logout
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.error.withOpacity(0.3)),
          ),
          child: ListTile(
            leading: Icon(Icons.logout, color: AppColors.error),
            title: Text(
              'Logout',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout?'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ApiClient().clearTokens();
                onLogout();
              }
            },
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
        ),
        trailing: onTap != null
            ? Icon(Icons.chevron_right, color: AppColors.textMuted)
            : null,
        onTap: onTap,
      ),
    );
  }
}

// Inline education config — reuses the screen from education_config_screen.dart
class _EducationConfigPage extends StatelessWidget {
  const _EducationConfigPage();
  @override
  Widget build(BuildContext context) {
    // Lazy import to avoid circular — just navigate to the full screen
    return const Center(child: Text('Navigate to Education Config from here'));
  }
}
