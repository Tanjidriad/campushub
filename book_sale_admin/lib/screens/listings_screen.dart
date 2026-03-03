import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/api_client.dart';
import '../core/constants.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  List<dynamic> _listings = [];
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _statusFilter = 'pending';
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final params = <String, dynamic>{'limit': 50};
      if (_statusFilter != null) params['status'] = _statusFilter;

      final response = await ApiClient().dio.get(
        ApiConstants.listings,
        queryParameters: params,
      );

      if (mounted) {
        setState(() {
          _listings = response.data['data'] ?? [];
          _stats = response.data['statistics'];
          _selected.clear();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _approve(String id) async {
    try {
      await ApiClient().dio.put('${ApiConstants.listings}/$id/approve');
      _load();
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
      _load();
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
      _load();
    } catch (_) {}
  }

  Future<void> _toggleFeature(String id) async {
    try {
      await ApiClient().dio.put('${ApiConstants.listings}/$id/feature');
      _load();
    } catch (_) {}
  }

  Future<void> _bulkApprove() async {
    if (_selected.isEmpty) return;
    try {
      await ApiClient().dio.post(
        '/admin/listings/bulk-approve',
        data: {'listingIds': _selected.toList()},
      );
      _load();
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
                'Listings',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _statusChip(
                      'Pending (${_stats?['pending'] ?? 0})',
                      'pending',
                      const Color(0xFFF59E0B),
                    ),
                    SizedBox(width: 8.w),
                    _statusChip(
                      'Approved (${_stats?['approved'] ?? 0})',
                      'approved',
                      const Color(0xFF10B981),
                    ),
                    SizedBox(width: 8.w),
                    _statusChip(
                      'Rejected (${_stats?['rejected'] ?? 0})',
                      'rejected',
                      const Color(0xFFEF4444),
                    ),
                    SizedBox(width: 8.w),
                    _statusChip(
                      'All (${_stats?['total'] ?? 0})',
                      null,
                      const Color(0xFF6366F1),
                    ),
                  ],
                ),
              ),
              if (_selected.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Text(
                      '${_selected.length} selected',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 13.sp,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _bulkApprove,
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Approve All'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Listings list
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _listings.isEmpty
                      ? Center(
                          child: Text(
                            'No listings found',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: _listings.length,
                          itemBuilder: (ctx, i) {
                            final listing = _listings[i];
                            final id = listing['_id'] as String;
                            final isSelected = _selected.contains(id);
                            final isFeatured = listing['isFeatured'] == true;
                            final status = listing['status'] ?? '';
                            final images = listing['images'] as List? ?? [];

                            return Card(
                              margin: EdgeInsets.only(bottom: 8.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                side: BorderSide(
                                  color: isSelected
                                      ? const Color(0xFF6366F1)
                                      : const Color(0xFF334155),
                                ),
                              ),
                              child: InkWell(
                                onLongPress: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selected.remove(id);
                                    } else {
                                      _selected.add(id);
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(12.r),
                                child: Padding(
                                  padding: EdgeInsets.all(12.w),
                                  child: Row(
                                    children: [
                                      // Thumbnail
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        child: images.isNotEmpty
                                            ? Image.network(
                                                images[0]['url'] ?? '',
                                                width: 56.w,
                                                height: 56.w,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    _placeholder(),
                                              )
                                            : _placeholder(),
                                      ),
                                      SizedBox(width: 12.w),

                                      // Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                if (isFeatured)
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                      right: 6.w,
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 6.w,
                                                          vertical: 2.h,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amber
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4.r,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '⭐',
                                                      style: TextStyle(
                                                        fontSize: 10.sp,
                                                      ),
                                                    ),
                                                  ),
                                                Expanded(
                                                  child: Text(
                                                    listing['title'] ?? '',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              '${listing['category'] ?? ''} • ৳${listing['price'] ?? 0}',
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Actions
                                      if (status == 'pending')
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.check_circle,
                                                color: Color(0xFF10B981),
                                              ),
                                              onPressed: () => _approve(id),
                                              tooltip: 'Approve',
                                              iconSize: 24,
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                            SizedBox(width: 8.w),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.cancel,
                                                color: Color(0xFFEF4444),
                                              ),
                                              onPressed: () => _reject(id),
                                              tooltip: 'Reject',
                                              iconSize: 24,
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ],
                                        )
                                      else
                                        PopupMenuButton<String>(
                                          icon: const Icon(
                                            Icons.more_vert,
                                            color: Colors.grey,
                                          ),
                                          onSelected: (action) {
                                            switch (action) {
                                              case 'feature':
                                                _toggleFeature(id);
                                                break;
                                              case 'delete':
                                                _delete(id);
                                                break;
                                            }
                                          },
                                          itemBuilder: (_) => [
                                            PopupMenuItem(
                                              value: 'feature',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    isFeatured
                                                        ? Icons.star_border
                                                        : Icons.star,
                                                    size: 18,
                                                    color: Colors.amber,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    isFeatured
                                                        ? 'Unfeature'
                                                        : 'Feature',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.delete,
                                                    size: 18,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text('Delete'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
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

  Widget _placeholder() => Container(
    width: 56.w,
    height: 56.w,
    color: const Color(0xFF334155),
    child: const Icon(Icons.image, color: Colors.grey),
  );

  Widget _statusChip(String label, String? status, Color color) {
    final isActive = _statusFilter == status;
    return GestureDetector(
      onTap: () {
        setState(() => _statusFilter = status);
        _load();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: isActive ? color : const Color(0xFF334155)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? color : Colors.grey[400],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }
}
