import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/api_client.dart';
import '../core/constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _data;
  List<dynamic> _activity = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiClient().dio.get(ApiConstants.dashboard),
        ApiClient().dio.get(ApiConstants.activity),
      ]);
      if (mounted) {
        setState(() {
          _data = results[0].data['data'];
          _activity = results[1].data['data'] ?? [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final users = _data?['users'] ?? {};
    final listings = _data?['listings'] ?? {};
    final reports = _data?['reports'] ?? {};

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Overview of your marketplace',
            style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          ),
          SizedBox(height: 24.h),

          // Stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.6,
            children: [
              _StatCard(
                title: 'Total Users',
                value: '${users['total'] ?? 0}',
                icon: Icons.people,
                color: const Color(0xFF3B82F6),
                subtitle: '+${users['today'] ?? 0} today',
              ),
              _StatCard(
                title: 'Total Listings',
                value: '${listings['total'] ?? 0}',
                icon: Icons.inventory_2,
                color: const Color(0xFF10B981),
                subtitle: '+${listings['today'] ?? 0} today',
              ),
              _StatCard(
                title: 'Pending',
                value: '${listings['pending'] ?? 0}',
                icon: Icons.pending_actions,
                color: const Color(0xFFF59E0B),
                subtitle: 'Awaiting review',
              ),
              _StatCard(
                title: 'Reports',
                value: '${reports['pending'] ?? 0}',
                icon: Icons.flag,
                color: const Color(0xFFEF4444),
                subtitle: 'Pending reports',
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Recent Activity
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          if (_activity.isEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Center(
                  child: Text(
                    'No recent activity',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              ),
            )
          else
            ...List.generate(_activity.length, (i) {
              final a = _activity[i];
              return Card(
                margin: EdgeInsets.only(bottom: 8.h),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _activityColor(
                      a['color'],
                    ).withOpacity(0.15),
                    child: Icon(
                      _activityIcon(a['icon']),
                      color: _activityColor(a['color']),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    a['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    a['subtitle'] ?? '',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Color _activityColor(String? color) {
    switch (color) {
      case 'success':
        return const Color(0xFF10B981);
      case 'warning':
        return const Color(0xFFF59E0B);
      case 'error':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _activityIcon(String? icon) {
    switch (icon) {
      case 'person_add':
        return Icons.person_add;
      case 'check_circle':
        return Icons.check_circle;
      case 'cancel':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      case 'flag':
        return Icons.flag;
      case 'edit':
        return Icons.edit;
      default:
        return Icons.info;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 11.sp),
            ),
          ],
        ),
      ),
    );
  }
}
