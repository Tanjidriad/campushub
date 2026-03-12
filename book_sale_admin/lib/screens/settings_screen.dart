import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/theme.dart';
import '../core/theme/theme_bloc.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../injection_container.dart' as di;
import 'audit_log_screen.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const SettingsScreen({super.key, required this.onLogout});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiClient _api = di.sl<ApiClient>();
  bool _healthLoading = false;
  String? _healthStatus;
  bool _exportingUsers = false;
  bool _exportingListings = false;

  Future<void> _checkHealth() async {
    setState(() {
      _healthLoading = true;
      _healthStatus = null;
    });
    try {
      final res = await _api.dio.get(
        '${ApiConstants.baseUrl}/health',
        options: Options(headers: {'Accept': 'application/json'}),
      );
      if (res.statusCode == 200) {
        final data = res.data;
        final uptime = data['uptime'] ?? 0;
        final hours = (uptime / 3600).floor();
        final mins = ((uptime % 3600) / 60).floor();
        setState(() => _healthStatus = 'Online · ${hours}h ${mins}m uptime');
      }
    } catch (_) {
      setState(() => _healthStatus = 'Unreachable');
    } finally {
      setState(() => _healthLoading = false);
    }
  }

  Future<void> _exportCSV(String type) async {
    final isUsers = type == 'users';
    setState(() {
      if (isUsers) {
        _exportingUsers = true;
      } else {
        _exportingListings = true;
      }
    });

    try {
      final endpoint = isUsers
          ? ApiConstants.exportUsers
          : ApiConstants.exportListings;

      final res = await _api.dio.get(
        endpoint,
        options: Options(responseType: ResponseType.bytes),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${type}_export.csv');
      await file.writeAsBytes(res.data);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: '${isUsers ? 'Users' : 'Listings'} Export');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${isUsers ? 'Users' : 'Listings'} exported successfully',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
          ),
        );
      }
    } finally {
      setState(() {
        if (isUsers) {
          _exportingUsers = false;
        } else {
          _exportingListings = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.h3.copyWith(color: context.textPrimary),
        ),
        backgroundColor: context.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // ── APPEARANCE ──
          _SectionHeader(title: 'APPEARANCE'),
          SizedBox(height: 8.h),
          _SettingsCard(
            children: [
              _ToggleTile(
                icon: isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                iconColor: AppColors.warning,
                title: 'Dark Mode',
                subtitle: isDark ? 'Dark theme enabled' : 'Light theme enabled',
                value: isDark,
                onChanged: (_) =>
                    context.read<ThemeBloc>().add(ToggleThemeEvent()),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // ── DATA MANAGEMENT ──
          _SectionHeader(title: 'DATA MANAGEMENT'),
          SizedBox(height: 8.h),
          _SettingsCard(
            children: [
              _ActionTile(
                icon: Icons.people_outline_rounded,
                iconColor: AppColors.info,
                title: 'Export Users',
                subtitle: 'Download all users as CSV',
                isLoading: _exportingUsers,
                onTap: () => _exportCSV('users'),
              ),
              Divider(height: 1, color: context.cardBorder),
              _ActionTile(
                icon: Icons.inventory_2_outlined,
                iconColor: AppColors.success,
                title: 'Export Listings',
                subtitle: 'Download all listings as CSV',
                isLoading: _exportingListings,
                onTap: () => _exportCSV('listings'),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // ── ADMIN TOOLS ──
          _SectionHeader(title: 'ADMIN TOOLS'),
          SizedBox(height: 8.h),
          _SettingsCard(
            children: [
              _ActionTile(
                icon: Icons.history_rounded,
                iconColor: AppColors.warning,
                title: 'Audit Log',
                subtitle: 'Review admin activity history',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AuditLogScreen()),
                ),
              ),
              Divider(height: 1, color: context.cardBorder),
              _ActionTile(
                icon: Icons.school_outlined,
                iconColor: AppColors.primary,
                title: 'Education Config',
                subtitle: 'Manage education levels & book types',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Use the Categories tab to manage education config',
                      ),
                      backgroundColor: AppColors.info,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
                    ),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // ── APP INFO ──
          _SectionHeader(title: 'APP INFO'),
          SizedBox(height: 8.h),
          _SettingsCard(
            children: [
              _InfoTile(
                icon: Icons.info_outline_rounded,
                iconColor: context.textMuted,
                title: 'Version',
                trailing: Text(
                  'v1.0.0',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: context.textMuted,
                  ),
                ),
              ),
              Divider(height: 1, color: context.cardBorder),
              _InfoTile(
                icon: Icons.dns_outlined,
                iconColor: _healthStatus == null
                    ? context.textMuted
                    : _healthStatus!.startsWith('Online')
                    ? AppColors.success
                    : AppColors.error,
                title: 'API Server',
                trailing: _healthLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : _healthStatus != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _healthStatus!.startsWith('Online')
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            _healthStatus!,
                            style: AppTextStyles.caption.copyWith(
                              color: _healthStatus!.startsWith('Online')
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      )
                    : TextButton(
                        onPressed: _checkHealth,
                        child: Text(
                          'Check',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // ── ACCOUNT ──
          _SectionHeader(title: 'ACCOUNT'),
          SizedBox(height: 8.h),
          Material(
            color: AppColors.error.withAlpha(12),
            borderRadius: AppRadius.md,
            child: InkWell(
              onTap: () async {
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
                            Icons.logout_rounded,
                            color: AppColors.error,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Text(
                          'Sign Out',
                          style: AppTextStyles.h4.copyWith(
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'Are you sure you want to sign out of CampusHub Admin?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: context.textMuted),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.sm,
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) widget.onLogout();
              },
              borderRadius: AppRadius.md,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 20,
                      color: AppColors.error,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Sign Out',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 20.h),
          Center(
            child: Text(
              'CampusHub Admin · Made with ❤️',
              style: AppTextStyles.caption.copyWith(color: context.textMuted),
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ─── SETTINGS WIDGETS ────────────────────────────────────
// ═══════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.overline.copyWith(color: context.textMuted),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.md,
        border: Border.all(color: context.cardBorder),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(20),
          borderRadius: AppRadius.sm,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: context.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(color: context.textMuted),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLoading;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(20),
          borderRadius: AppRadius.sm,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: context.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(color: context.textMuted),
      ),
      trailing: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: iconColor,
              ),
            )
          : Icon(
              Icons.chevron_right_rounded,
              color: context.textMuted,
              size: 20,
            ),
      onTap: isLoading ? null : onTap,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget trailing;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(20),
          borderRadius: AppRadius.sm,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: context.textPrimary,
        ),
      ),
      trailing: trailing,
    );
  }
}
