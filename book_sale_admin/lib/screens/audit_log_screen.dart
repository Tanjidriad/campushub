import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/theme/theme.dart';
import '../features/dashboard/data/models/dashboard_models.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final ApiClient _apiClient = ApiClient();
  List<AuditLogModel> _logs = [];
  bool _loading = true;
  String? _error;
  String? _selectedAction;

  static const _actions = [
    null,
    'user_banned',
    'user_unbanned',
    'listing_approved',
    'listing_rejected',
    'listing_deleted',
    'listing_featured',
    'listing_unfeatured',
    'report_reviewed',
  ];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final params = <String, dynamic>{'limit': 50};
      if (_selectedAction != null) params['action'] = _selectedAction;
      final response = await _apiClient.dio.get(
        ApiConstants.auditLogs,
        queryParameters: params,
      );
      final data = response.data['data'] as List? ?? [];
      setState(() {
        _logs = data.map((e) => AuditLogModel.fromJson(e)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadLogs,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildFilterRow()),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 12.h),
                      Text(_error!, style: TextStyle(color: context.textMuted)),
                      SizedBox(height: 12.h),
                      ElevatedButton(
                        onPressed: _loadLogs,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_logs.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 64,
                        color: context.textMuted,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'No audit logs found',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: context.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.all(16.w),
                sliver: SliverList.builder(
                  itemCount: _logs.length,
                  itemBuilder: (ctx, i) => _AuditLogTile(log: _logs[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _exporting = false;

  Future<void> _exportCsv(String type) async {
    setState(() => _exporting = true);
    try {
      final endpoint = type == 'users'
          ? ApiConstants.exportUsers
          : ApiConstants.exportListings;
      await _apiClient.dio.get(endpoint);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$type CSV exported successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export $type: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, size: 28, color: AppColors.primary),
              SizedBox(width: 10.w),
              Text(
                'Audit Log',
                style: AppTextStyles.h3.copyWith(color: context.textPrimary),
              ),
              const Spacer(),
              Text(
                '${_logs.length} entries',
                style:
                    AppTextStyles.labelSmall.copyWith(color: context.textMuted),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _ExportButton(
                  icon: Icons.people_outline,
                  label: 'Export Users',
                  color: AppColors.info,
                  loading: _exporting,
                  onTap: () => _exportCsv('users'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _ExportButton(
                  icon: Icons.book_outlined,
                  label: 'Export Listings',
                  color: AppColors.accent,
                  loading: _exporting,
                  onTap: () => _exportCsv('listings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _actions.map((action) {
            final label = action == null
                ? 'All'
                : action.replaceAll('_', ' ').toUpperCase();
            final isActive = _selectedAction == action;
            return Padding(
              padding: EdgeInsets.only(right: 6.w),
              child: FilterChip(
                label: Text(label, style: TextStyle(fontSize: 11.sp)),
                selected: isActive,
                onSelected: (_) {
                  setState(() => _selectedAction = action);
                  _loadLogs();
                },
                selectedColor: AppColors.primary.withAlpha(40),
                checkmarkColor: AppColors.primary,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _AuditLogTile extends StatelessWidget {
  final AuditLogModel log;
  const _AuditLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final action = log.action ?? '';
    final icon = _iconForAction(action);
    final color = _colorForAction(action);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.md,
        border: Border.all(color: context.cardBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: AppRadius.sm,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.actionLabel,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'By ${log.adminName}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                if (log.targetType != null)
                  Text(
                    '${log.targetType} • ${log.targetId ?? 'N/A'}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: context.textMuted,
                    ),
                  ),
                if (log.details != null && log.details!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      log.details!.entries
                          .map((e) => '${e.key}: ${e.value}')
                          .join(', '),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: context.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            _formatTime(log.createdAt),
            style: AppTextStyles.labelSmall.copyWith(color: context.textMuted),
          ),
        ],
      ),
    );
  }

  IconData _iconForAction(String action) {
    if (action.contains('banned')) return Icons.block_rounded;
    if (action.contains('unbanned')) return Icons.check_circle_outline;
    if (action.contains('approved')) return Icons.check_circle_rounded;
    if (action.contains('rejected')) return Icons.cancel_rounded;
    if (action.contains('deleted')) return Icons.delete_rounded;
    if (action.contains('featured')) return Icons.star_rounded;
    if (action.contains('report')) return Icons.flag_rounded;
    return Icons.history_rounded;
  }

  Color _colorForAction(String action) {
    if (action.contains('banned')) return AppColors.error;
    if (action.contains('approved') || action.contains('unbanned')) {
      return AppColors.success;
    }
    if (action.contains('rejected')) return AppColors.warning;
    if (action.contains('deleted')) return AppColors.error;
    if (action.contains('featured')) return AppColors.accent;
    return AppColors.primary;
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  const _ExportButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withAlpha(20),
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: AppRadius.md,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              else
                Icon(icon, size: 18, color: color),
              SizedBox(width: 8.w),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
