import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<dynamic> _users = [];
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String _search = '';
  String? _roleFilter;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final params = <String, dynamic>{'limit': 50};
      if (_search.isNotEmpty) params['search'] = _search;
      if (_roleFilter != null) params['role'] = _roleFilter;
      if (_statusFilter != null) params['status'] = _statusFilter;

      final response = await ApiClient().dio.get(
        ApiConstants.users,
        queryParameters: params,
      );

      if (mounted) {
        setState(() {
          _users = response.data['data'] ?? [];
          _stats = response.data['statistics'];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleBan(String userId) async {
    try {
      await ApiClient().dio.put('${ApiConstants.users}/$userId/ban');
      _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
          child: Column(
            children: [
              // Search
              TextField(
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Search name or email...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textMuted,
                  ),
                  suffixIcon: const Icon(
                    Icons.tune,
                    color: AppColors.textMuted,
                  ),
                ),
                onChanged: (val) {
                  _search = val;
                  _load();
                },
              ),
              SizedBox(height: 12.h),

              // Filter chips
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
                      _load();
                    },
                  ),
                  SizedBox(width: 8.w),
                  _DropdownChip(
                    label: 'Role',
                    value: _roleFilter,
                    items: const ['student', 'admin', 'superadmin'],
                    onChanged: (val) {
                      setState(() => _roleFilter = val);
                      _load();
                    },
                  ),
                  SizedBox(width: 8.w),
                  _DropdownChip(
                    label: 'Status',
                    value: _statusFilter,
                    items: const ['active', 'banned'],
                    onChanged: (val) {
                      setState(() => _statusFilter = val);
                      _load();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Stat boxes
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              _MiniStat(
                '${_stats?['total'] ?? 0}',
                'TOTAL',
                Icons.people,
                AppColors.info,
              ),
              SizedBox(width: 8.w),
              _MiniStat(
                '${_stats?['active'] ?? 0}',
                'ACTIVE',
                Icons.check_circle,
                AppColors.success,
              ),
              SizedBox(width: 8.w),
              _MiniStat(
                '${_stats?['banned'] ?? 0}',
                'BANNED',
                Icons.block,
                AppColors.error,
              ),
              SizedBox(width: 8.w),
              _MiniStat(
                '${_stats?['admins'] ?? 0}',
                'ADMINS',
                Icons.admin_panel_settings,
                AppColors.warning,
              ),
            ],
          ),
        ),

        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Text(
                'USERS',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                '${_users.length} Total',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),

        // Users list
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _users.length,
                    itemBuilder: (ctx, i) {
                      final user = _users[i];
                      final isBlocked = user['isBlocked'] == true;
                      final isOnline = user['isOnline'] == true;
                      final role = user['role'] ?? 'student';

                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 24.r,
                                  backgroundImage: user['avatar'] != null
                                      ? NetworkImage(user['avatar'])
                                      : null,
                                  backgroundColor: AppColors.primaryLight,
                                  child: user['avatar'] == null
                                      ? Text(
                                          (user['name'] ?? 'U')[0]
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
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
                                          : AppColors.textMuted,
                                      border: Border.all(
                                        color: AppColors.surface,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['name'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    user['email'] ?? '',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12.sp,
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

                            // Menu
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: AppColors.textMuted,
                              ),
                              onSelected: (action) {
                                if (action == 'ban') _toggleBan(user['_id']);
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'ban',
                                  child: Row(
                                    children: [
                                      Icon(
                                        isBlocked
                                            ? Icons.lock_open
                                            : Icons.block,
                                        size: 18,
                                        color: isBlocked
                                            ? AppColors.success
                                            : AppColors.error,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(isBlocked ? 'Unban' : 'Ban'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

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
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textPrimary,
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value != null
                  ? value![0].toUpperCase() + value!.substring(1)
                  : label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppColors.textMuted,
            ),
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
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.15)),
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
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withOpacity(0.3)),
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
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
