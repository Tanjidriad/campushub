import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/api_client.dart';
import '../core/constants.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<dynamic> _reports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final response = await ApiClient().dio.get(
        ApiConstants.reports,
        queryParameters: {'limit': 50},
      );
      if (mounted) {
        setState(() {
          _reports = response.data['data'] ?? [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _review(String id, String action) async {
    try {
      await ApiClient().dio.put(
        '${ApiConstants.reports}/$id',
        data: {'action': action},
      );
      _load();
    } catch (_) {}
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'resolved':
        return const Color(0xFF10B981);
      case 'dismissed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            'Reports',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _reports.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 48.sp,
                                color: Colors.green,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'No reports',
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: _reports.length,
                          itemBuilder: (ctx, i) {
                            final report = _reports[i];
                            final status = report['status'] ?? 'pending';
                            final isPending = status == 'pending';

                            return Card(
                              margin: EdgeInsets.only(bottom: 8.h),
                              child: Padding(
                                padding: EdgeInsets.all(12.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 3.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _statusColor(
                                              status,
                                            ).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              6.r,
                                            ),
                                          ),
                                          child: Text(
                                            status.toUpperCase(),
                                            style: TextStyle(
                                              color: _statusColor(status),
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          report['targetType'] ?? '',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      report['reason'] ?? 'No reason given',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Reported by: ${report['reporter']?['name'] ?? 'Unknown'}',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    if (isPending) ...[
                                      SizedBox(height: 12.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () => _review(
                                              report['_id'],
                                              'dismiss',
                                            ),
                                            child: const Text('Dismiss'),
                                          ),
                                          SizedBox(width: 8.w),
                                          ElevatedButton(
                                            onPressed: () => _review(
                                              report['_id'],
                                              'resolve',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFFEF4444,
                                              ),
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('Take Action'),
                                          ),
                                        ],
                                      ),
                                    ],
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
