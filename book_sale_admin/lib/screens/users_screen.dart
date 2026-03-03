import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/api_client.dart';
import '../core/constants.dart';

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
        // Header
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Users',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12.h),
              // Search
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                onChanged: (val) {
                  _search = val;
                  _load();
                },
              ),
              SizedBox(height: 12.h),
              // Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All (${_stats?['total'] ?? 0})',
                      selected: _statusFilter == null,
                      onTap: () {
                        setState(() => _statusFilter = null);
                        _load();
                      },
                    ),
                    SizedBox(width: 8.w),
                    _FilterChip(
                      label: 'Active',
                      selected: _statusFilter == 'active',
                      onTap: () {
                        setState(() => _statusFilter = 'active');
                        _load();
                      },
                    ),
                    SizedBox(width: 8.w),
                    _FilterChip(
                      label: 'Banned (${_stats?['banned'] ?? 0})',
                      selected: _statusFilter == 'banned',
                      onTap: () {
                        setState(() => _statusFilter = 'banned');
                        _load();
                      },
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

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
                      return Card(
                        margin: EdgeInsets.only(bottom: 8.h),
                        child: ListTile(
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                backgroundImage: user['avatar'] != null
                                    ? NetworkImage(user['avatar'])
                                    : null,
                                child: user['avatar'] == null
                                    ? Text(
                                        (user['name'] ?? 'U')[0].toUpperCase(),
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
                                        ? Colors.red
                                        : isOnline
                                        ? Colors.green
                                        : Colors.grey,
                                    border: Border.all(
                                      color: const Color(0xFF1E293B),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            user['name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            user['email'] ?? '',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.grey,
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
                                      isBlocked ? Icons.lock_open : Icons.block,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(isBlocked ? 'Unban' : 'Ban'),
                                  ],
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
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF6366F1);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? c.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? c : const Color(0xFF334155)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? c : Colors.grey[400],
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }
}
