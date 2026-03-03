import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import 'package:intl/intl.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtl;
  List<dynamic> _pending = [];
  List<dynamic> _all = [];
  Map<String, dynamic>? _stats;
  bool _loadingPending = true;
  bool _loadingAll = true;
  String _searchAll = '';

  @override
  void initState() {
    super.initState();
    _tabCtl = TabController(length: 2, vsync: this);
    _loadPending();
    _loadAll();
  }

  @override
  void dispose() {
    _tabCtl.dispose();
    super.dispose();
  }

  Future<void> _loadPending() async {
    setState(() => _loadingPending = true);
    try {
      final response = await ApiClient().dio.get(
        ApiConstants.pendingListings,
        queryParameters: {'limit': 50},
      );
      if (mounted) {
        setState(() {
          _pending = response.data['data'] ?? [];
          _loadingPending = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingPending = false);
    }
  }

  Future<void> _loadAll() async {
    setState(() => _loadingAll = true);
    try {
      final params = <String, dynamic>{'limit': 50};
      if (_searchAll.isNotEmpty) params['search'] = _searchAll;

      final response = await ApiClient().dio.get(
        ApiConstants.listings,
        queryParameters: params,
      );
      if (mounted) {
        setState(() {
          _all = response.data['data'] ?? [];
          _stats = response.data['statistics'];
          _loadingAll = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingAll = false);
    }
  }

  Future<void> _approve(String id) async {
    try {
      await ApiClient().dio.put('${ApiConstants.listings}/$id/approve');
      _loadPending();
      _loadAll();
    } catch (_) {}
  }

  Future<void> _reject(String id) async {
    final reason = await _showReasonDialog();
    if (reason == null || reason.isEmpty) return;
    try {
      await ApiClient().dio.put(
        '${ApiConstants.listings}/$id/reject',
        data: {'reason': reason},
      );
      _loadPending();
      _loadAll();
    } catch (_) {}
  }

  Future<void> _delete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiClient().dio.delete('${ApiConstants.listings}/$id');
      _loadAll();
    } catch (_) {}
  }

  Future<void> _toggleFeature(String id) async {
    try {
      await ApiClient().dio.put('${ApiConstants.listings}/$id/feature');
      _loadAll();
    } catch (_) {}
  }

  Future<String?> _showReasonDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejection Reason'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Why is this listing being rejected?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${(diff.inDays / 7).floor()}w ago';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AppBar
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Listing Management',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.tune, color: AppColors.textMuted),
                ],
              ),
              SizedBox(height: 12.h),
              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TabBar(
                  controller: _tabCtl,
                  indicator: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: AppColors.textPrimary,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inbox_outlined, size: 18),
                          SizedBox(width: 6.w),
                          const Text('Queue'),
                          if (_pending.isNotEmpty) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 1.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${_pending.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.grid_view, size: 18),
                          SizedBox(width: 6.w),
                          const Text('Management'),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${_stats?['total'] ?? 0}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),

        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabCtl,
            children: [_buildQueueTab(), _buildManagementTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildQueueTab() {
    if (_loadingPending) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadPending,
      child: _pending.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 48.sp,
                    color: AppColors.success,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'All caught up!',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            )
          : ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                Row(
                  children: [
                    Icon(Icons.inbox, size: 18, color: AppColors.textSecondary),
                    SizedBox(width: 6.w),
                    Text(
                      '${_pending.length} Pending Review',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 14.sp,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.sort, size: 16, color: AppColors.textMuted),
                    SizedBox(width: 4.w),
                    Text(
                      'Newest',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                ...List.generate(
                  _pending.length,
                  (i) => _buildPendingCard(_pending[i]),
                ),
              ],
            ),
    );
  }

  Widget _buildPendingCard(Map<String, dynamic> listing) {
    final images = listing['images'] as List? ?? [];
    final seller = listing['seller'];
    final sellerName = seller is Map ? seller['name'] ?? '' : '';
    final sellerRole = seller is Map ? seller['role'] ?? 'Student' : 'Student';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seller + Category
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundImage: seller is Map && seller['avatar'] != null
                    ? NetworkImage(seller['avatar'])
                    : null,
                backgroundColor: AppColors.primaryLight,
                child: seller is Map && seller['avatar'] == null
                    ? Text(
                        sellerName.isNotEmpty
                            ? sellerName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sellerName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      '${sellerRole[0].toUpperCase()}${sellerRole.substring(1)} • ${_timeAgo(listing['createdAt'])}',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Text(
                  listing['category'] ?? '',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Title, Price, Description + Image
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing['title'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '৳${listing['price'] ?? 0}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      listing['description'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              if (images.isNotEmpty) ...[
                SizedBox(width: 12.w),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.network(
                    images[0]['url'] ?? '',
                    width: 72.w,
                    height: 72.w,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 72.w,
                      height: 72.w,
                      color: AppColors.background,
                      child: const Icon(
                        Icons.image,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: 12.h),
          Divider(color: AppColors.cardBorder, height: 1),
          SizedBox(height: 8.h),

          // Actions
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _reject(listing['_id']),
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.error,
                  ),
                  label: Text(
                    'Reject',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 24, color: AppColors.cardBorder),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _approve(listing['_id']),
                  icon: const Icon(
                    Icons.check,
                    size: 18,
                    color: AppColors.success,
                  ),
                  label: Text(
                    'Approve',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManagementTab() {
    if (_loadingAll) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Search
          TextField(
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Search title, ID, or user...',
              hintStyle: TextStyle(color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              suffixIcon: const Icon(Icons.tune, color: AppColors.textMuted),
            ),
            onChanged: (val) {
              _searchAll = val;
              _loadAll();
            },
          ),
          SizedBox(height: 16.h),
          ...List.generate(_all.length, (i) => _buildManagedCard(_all[i])),
        ],
      ),
    );
  }

  Widget _buildManagedCard(Map<String, dynamic> listing) {
    final images = listing['images'] as List? ?? [];
    final seller = listing['seller'];
    final sellerName = seller is Map ? seller['name'] ?? '' : '';
    final sellerEmail = seller is Map ? seller['email'] ?? '' : '';
    final isFeatured = listing['isFeatured'] == true;
    final status = listing['status'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status badge + Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: images.isNotEmpty
                        ? Image.network(
                            images[0]['url'] ?? '',
                            width: 72.w,
                            height: 72.w,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imgPlaceholder(),
                          )
                        : _imgPlaceholder(),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: status == 'approved'
                            ? AppColors.success
                            : status == 'rejected'
                            ? AppColors.error
                            : AppColors.warning,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
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
                      listing['title'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '$sellerEmail • ${_timeAgo(listing['createdAt'])}',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '৳${listing['price'] ?? 0}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Featured toggle + Delete
          Row(
            children: [
              Text(
                'Featured',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                height: 24,
                child: Switch(
                  value: isFeatured,
                  onChanged: (_) => _toggleFeature(listing['_id']),
                  activeColor: AppColors.primary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _delete(listing['_id']),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: AppColors.error,
                ),
                label: Text(
                  'Delete',
                  style: TextStyle(color: AppColors.error, fontSize: 13.sp),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
    width: 72.w,
    height: 72.w,
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: const Icon(Icons.image, color: AppColors.textMuted),
  );
}
