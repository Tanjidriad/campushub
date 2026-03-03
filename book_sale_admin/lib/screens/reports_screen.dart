import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/theme.dart';

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
        return AppColors.warning;
      case 'resolved':
        return AppColors.success;
      case 'dismissed':
        return AppColors.textMuted;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
          child: Text(
            'Reports',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
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
                                color: AppColors.success,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'No reports',
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16.w),
                          itemCount: _reports.length,
                          itemBuilder: (ctx, i) {
                            final report = _reports[i];
                            final status = report['status'] ?? 'pending';
                            final isPending = status == 'pending';

                            return Container(
                              margin: EdgeInsets.only(bottom: 10.h),
                              padding: EdgeInsets.all(14.w),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
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
                                          ).withOpacity(0.1),
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
                                          color: AppColors.textMuted,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    report['reason'] ?? 'No reason given',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Reported by: ${report['reporter']?['name'] ?? 'Unknown'}',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  if (isPending) ...[
                                    SizedBox(height: 12.h),
                                    Divider(
                                      color: AppColors.cardBorder,
                                      height: 1,
                                    ),
                                    SizedBox(height: 8.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () =>
                                              _review(report['_id'], 'dismiss'),
                                          child: Text(
                                            'Dismiss',
                                            style: TextStyle(
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        ElevatedButton(
                                          onPressed: () =>
                                              _review(report['_id'], 'resolve'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.error,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                          ),
                                          child: const Text('Take Action'),
                                        ),
                                      ],
                                    ),
                                  ],
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
