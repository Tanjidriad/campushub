// ignore_for_file: unnecessary_underscores
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/theme/theme.dart';
import '../features/listings/data/models/listing_model.dart';

/// Premium listing detail screen with image carousel and seller info.
class ListingDetailScreen extends StatefulWidget {
  final String listingId;
  final VoidCallback? onAction;

  const ListingDetailScreen({
    super.key,
    required this.listingId,
    this.onAction,
  });

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final ApiClient _api = ApiClient();
  ListingModel? _listing;
  bool _loading = true;
  String? _error;
  int _currentImage = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _api.dio.get(
        '${ApiConstants.listings}/${widget.listingId}',
      );
      if (res.data['success'] == true) {
        setState(() {
          _listing = ListingModel.fromJson(res.data['data']);
          _loading = false;
        });
      }
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
      appBar: AppBar(
        title: Text(
          'Listing Detail',
          style: AppTextStyles.h4.copyWith(color: context.textPrimary),
        ),
        backgroundColor: context.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: context.textPrimary),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(_error!, style: TextStyle(color: AppColors.error)),
            )
          : _listing == null
          ? const Center(child: Text('Not found'))
          : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l = _listing!;
    final images = l.images ?? [];
    final statusColor = _statusColor(l.status ?? '');

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image carousel
          if (images.isNotEmpty) ...[
            ClipRRect(
              borderRadius: AppRadius.lg,
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: PageView.builder(
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _currentImage = i),
                  itemBuilder: (_, i) => Image.network(
                    images[i].url ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: context.cardColor,
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: context.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (images.length > 1)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      width: i == _currentImage ? 20.w : 6.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: i == _currentImage
                            ? AppColors.primary
                            : context.cardBorder,
                        borderRadius: AppRadius.full,
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 20.h),
          ],

          // Title + Status
          Row(
            children: [
              Expanded(
                child: Text(
                  l.title ?? 'Untitled',
                  style: AppTextStyles.h2.copyWith(color: context.textPrimary),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: AppRadius.sm,
                  border: Border.all(color: statusColor.withAlpha(60)),
                ),
                child: Text(
                  (l.status ?? 'unknown').toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Price
          if (l.price != null)
            Text(
              '৳${l.price}',
              style: AppTextStyles.h3.copyWith(color: AppColors.success),
            ),
          SizedBox(height: 16.h),

          // Info grid
          _InfoCard(
            children: [
              _InfoItem(
                icon: Icons.category_outlined,
                label: 'Category',
                value: l.category ?? 'N/A',
              ),
              _InfoItem(
                icon: Icons.star_rounded,
                label: 'Featured',
                value: l.isFeatured == true ? 'Yes' : 'No',
                valueColor: l.isFeatured == true ? AppColors.accent : null,
              ),
              _InfoItem(
                icon: Icons.flag_outlined,
                label: 'Reports',
                value: '${l.reportCount ?? 0}',
              ),
              _InfoItem(
                icon: Icons.schedule_outlined,
                label: 'Created',
                value: _formatDate(l.createdAt),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Description
          if (l.description != null && l.description!.isNotEmpty) ...[
            Text(
              'Description',
              style: AppTextStyles.labelLarge.copyWith(
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: AppRadius.md,
                border: Border.all(color: context.cardBorder),
              ),
              child: Text(
                l.description!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Seller info
          if (l.seller != null) ...[
            Text(
              'Seller',
              style: AppTextStyles.labelLarge.copyWith(
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: AppRadius.md,
                border: Border.all(color: context.cardBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundImage: l.seller!.avatar != null
                        ? NetworkImage(l.seller!.avatar!)
                        : null,
                    backgroundColor: AppColors.primaryLight,
                    child: l.seller!.avatar == null
                        ? Text(
                            (l.seller!.name ?? 'U')[0].toUpperCase(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.seller!.name ?? 'Unknown',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                        Text(
                          l.seller!.email ?? '',
                          style: AppTextStyles.caption.copyWith(
                            color: context.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      case 'removed':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  String _formatDate(String? d) {
    if (d == null) return 'N/A';
    try {
      final dt = DateTime.parse(d);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return d;
    }
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoItem> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.md,
        border: Border.all(color: context.cardBorder),
      ),
      child: Wrap(spacing: 16.w, runSpacing: 12.h, children: children),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140.w,
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.textMuted),
          SizedBox(width: 6.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(color: context.textMuted),
              ),
              Text(
                value,
                style: AppTextStyles.labelMedium.copyWith(
                  color: valueColor ?? context.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
