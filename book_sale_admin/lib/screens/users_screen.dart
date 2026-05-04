// ignore_for_file: unnecessary_underscores
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/theme.dart';
import '../core/utils/csv_export.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/users/domain/entities/user_entity.dart';
import '../features/users/presentation/bloc/users_bloc.dart';
import '../features/users/presentation/bloc/users_event.dart';
import '../features/users/presentation/bloc/users_state.dart';
import 'user_detail_sheet.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _search = '';
  String? _roleFilter;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    context.read<UsersBloc>().add(
      LoadUsersEvent(
        search: _search.isNotEmpty ? _search : null,
        role: _roleFilter,
        status: _statusFilter,
      ),
    );
  }

  void _toggleBan(String userId) {
    context.read<UsersBloc>().add(ToggleBanEvent(userId: userId));
  }

  void _exportCsv(List<AdminUserEntity> users) {
    final csv = generateCsv(
      headers: ['Name', 'Email', 'Role', 'Status', 'Online'],
      rows: users
          .map(
            (u) => [
              u.name,
              u.email,
              u.role,
              u.isBlocked ? 'Banned' : 'Active',
              u.isOnline ? 'Yes' : 'No',
            ],
          )
          .toList(),
    );
    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${users.length} users copied as CSV'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
      ),
    );
  }

  Color _avatarColor(String name) {
    final colors = [
      AppColors.primary,
      AppColors.info,
      AppColors.success,
      AppColors.warning,
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
      const Color(0xFFFF5722),
    ];
    final hash = name.codeUnits.fold<int>(0, (sum, c) => sum + c);
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final canChangeRoles =
        authState is Authenticated && authState.user.role == 'superadmin';

    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, state) {
        final isLoading = state is UsersLoading;
        final users = state is UsersLoaded ? state.users : <AdminUserEntity>[];
        final stats = state is UsersLoaded ? state.stats : null;

        return Column(
          children: [
            // ── Search & Filters ──
            Container(
              color: context.surface,
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
              child: Column(
                children: [
                  TextField(
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search name or email...',
                      hintStyle: TextStyle(color: context.textMuted),
                      prefixIcon: Icon(Icons.search, color: context.textMuted),
                      suffixIcon: Icon(Icons.tune, color: context.textMuted),
                    ),
                    onChanged: (val) {
                      _search = val;
                      _loadUsers();
                    },
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      _ActiveChip(
                        label: 'All Users',
                        isActive: _roleFilter == null && _statusFilter == null,
                        onTap: () {
                          setState(() {
                            _roleFilter = null;
                            _statusFilter = null;
                          });
                          _loadUsers();
                        },
                      ),
                      SizedBox(width: 8.w),
                      _DropdownChip(
                        label: 'Role',
                        value: _roleFilter,
                        items: const ['student', 'admin', 'superadmin'],
                        onChanged: (val) {
                          setState(() => _roleFilter = val);
                          _loadUsers();
                        },
                      ),
                      SizedBox(width: 8.w),
                      _DropdownChip(
                        label: 'Status',
                        value: _statusFilter,
                        items: const ['active', 'banned'],
                        onChanged: (val) {
                          setState(() => _statusFilter = val);
                          _loadUsers();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Stat boxes ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  _MiniStat(
                    '${stats?.total ?? 0}',
                    'TOTAL',
                    Icons.people,
                    AppColors.info,
                  ),
                  SizedBox(width: 8.w),
                  _MiniStat(
                    '${stats?.active ?? 0}',
                    'ACTIVE',
                    Icons.check_circle,
                    AppColors.success,
                  ),
                  SizedBox(width: 8.w),
                  _MiniStat(
                    '${stats?.banned ?? 0}',
                    'BANNED',
                    Icons.block,
                    AppColors.error,
                  ),
                  SizedBox(width: 8.w),
                  _MiniStat(
                    '${stats?.admins ?? 0}',
                    'ADMINS',
                    Icons.admin_panel_settings,
                    AppColors.warning,
                  ),
                ],
              ),
            ),

            // ── Header ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  SizedBox(width: 8.w),
                  const Spacer(),
                  Text(
                    '${users.length} Total',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (users.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.file_download_outlined, size: 20),
                      color: AppColors.primary,
                      tooltip: 'Export CSV',
                      onPressed: () => _exportCsv(users),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8.h),

            // ── Users list ──
            Expanded(
              child: isLoading
                  ? _buildShimmerList()
                  : RefreshIndicator(
                      onRefresh: () async => _loadUsers(),
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: users.length,
                        itemBuilder: (ctx, i) {
                          final user = users[i];
                          final isBlocked = user.isBlocked;
                          final isOnline = user.isOnline;
                          final role = user.role;

                          return GestureDetector(
                            onTap: () => UserDetailSheet.show(
                              context,
                              user: user,
                              onBanToggle: () => _toggleBan(user.id),
                              onRoleChange: canChangeRoles
                                  ? (role) => context.read<UsersBloc>().add(
                                      ChangeRoleEvent(
                                        userId: user.id,
                                        newRole: role,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 8.h),
                              padding: EdgeInsets.all(14.w),
                              decoration: BoxDecoration(
                                color: context.cardColor,
                                borderRadius: AppRadius.md,
                                border: Border.all(color: context.cardBorder),
                                boxShadow: AppShadows.sm,
                              ),
                              child: Row(
                                children: [
                                  // Avatar with gradient initials
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 24.r,
                                        backgroundImage: user.avatar != null
                                            ? NetworkImage(user.avatar!)
                                            : null,
                                        backgroundColor: _avatarColor(
                                          user.name,
                                        ),
                                        child: user.avatar == null
                                            ? Text(
                                                (user.name)[0].toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16.sp,
                                                ),
                                              )
                                            : null,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isBlocked
                                                ? AppColors.error
                                                : isOnline
                                                ? AppColors.success
                                                : context.textMuted,
                                            border: Border.all(
                                              color: context.cardColor,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 12.w),

                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name,
                                          style: AppTextStyles.labelLarge
                                              .copyWith(
                                                color: context.textPrimary,
                                              ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          user.email,
                                          style: AppTextStyles.caption.copyWith(
                                            color: context.textMuted,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 6.h),
                                        Row(
                                          children: [
                                            _RoleBadge(role),
                                            SizedBox(width: 6.w),
                                            _StatusBadge(
                                              isBlocked
                                                  ? 'Banned'
                                                  : isOnline
                                                  ? 'Online'
                                                  : 'Offline',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Arrow
                                  Container(
                                    padding: EdgeInsets.all(6.w),
                                    decoration: BoxDecoration(
                                      color: context.isDark
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : AppColors.backgroundLight,
                                      borderRadius: AppRadius.sm,
                                    ),
                                    child: Icon(
                                      Icons.chevron_right,
                                      color: context.textMuted,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: context.isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: context.isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 8,
        itemBuilder: (_, __) => Container(
          margin: EdgeInsets.only(bottom: 8.h),
          height: 80.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.md,
          ),
        ),
      ),
    );
  }
}

// ─── Private Widgets ────────────────────────────────────────

class _ActiveChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ActiveChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : context.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? AppColors.primary : context.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : context.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }
}

class _DropdownChip extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownChip({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      onSelected: onChanged,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: context.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value != null
                  ? value![0].toUpperCase() + value!.substring(1)
                  : label,
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.keyboard_arrow_down, size: 18, color: context.textMuted),
          ],
        ),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(value: null, child: Text('All $label')),
        ...items.map(
          (item) => PopupMenuItem(
            value: item,
            child: Text(item[0].toUpperCase() + item.substring(1)),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _MiniStat(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: AppRadius.md,
          border: Border.all(color: color.withAlpha(38)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.overline.copyWith(color: context.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge(this.role);

  @override
  Widget build(BuildContext context) {
    final color = role == 'admin' || role == 'superadmin'
        ? AppColors.success
        : AppColors.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Text(
        role[0].toUpperCase() + role.substring(1),
        style: TextStyle(
          color: color,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: context.cardBorder),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: context.textSecondary,
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
