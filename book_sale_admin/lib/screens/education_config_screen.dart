import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class EducationConfigScreen extends StatefulWidget {
  const EducationConfigScreen({super.key});

  @override
  State<EducationConfigScreen> createState() => _EducationConfigScreenState();
}

class _EducationConfigScreenState extends State<EducationConfigScreen> {
  Map<String, dynamic>? _config;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final response = await ApiClient().dio.get(ApiConstants.educationConfig);
      if (mounted && response.data['success'] == true) {
        setState(() {
          _config = Map<String, dynamic>.from(response.data['data']);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_config == null) return;
    setState(() => _saving = true);
    try {
      await ApiClient().dio.put(
        ApiConstants.adminEducationConfig,
        data: {
          'levels': _config!['levels'],
          'bookTypes': _config!['bookTypes'],
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Configuration saved!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addLevel() {
    final keyCtl = TextEditingController();
    final labelCtl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Education Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyCtl,
              decoration: const InputDecoration(
                labelText: 'Key (e.g., school)',
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: labelCtl,
              decoration: const InputDecoration(
                labelText: 'Label (e.g., School)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (keyCtl.text.isNotEmpty && labelCtl.text.isNotEmpty) {
                setState(() {
                  (_config!['levels'] as List).add({
                    'key': keyCtl.text.trim(),
                    'label': labelCtl.text.trim(),
                    'subLevels': [],
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addSubLevel(int levelIndex) {
    final keyCtl = TextEditingController();
    final labelCtl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Sub-Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyCtl,
              decoration: const InputDecoration(
                labelText: 'Key (e.g., class-6)',
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: labelCtl,
              decoration: const InputDecoration(
                labelText: 'Label (e.g., Class 6)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (keyCtl.text.isNotEmpty && labelCtl.text.isNotEmpty) {
                setState(() {
                  ((_config!['levels'] as List)[levelIndex]['subLevels']
                          as List)
                      .add({
                        'key': keyCtl.text.trim(),
                        'label': labelCtl.text.trim(),
                      });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addBookType() {
    final keyCtl = TextEditingController();
    final labelCtl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Book Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyCtl,
              decoration: const InputDecoration(labelText: 'Key (e.g., nctb)'),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: labelCtl,
              decoration: const InputDecoration(
                labelText: 'Label (e.g., NCTB)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (keyCtl.text.isNotEmpty && labelCtl.text.isNotEmpty) {
                setState(() {
                  (_config!['bookTypes'] as List).add({
                    'key': keyCtl.text.trim(),
                    'label': labelCtl.text.trim(),
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_config == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Failed to load config'),
            SizedBox(height: 8.h),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    final levels = _config!['levels'] as List? ?? [];
    final bookTypes = _config!['bookTypes'] as List? ?? [];

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Education Config',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save, size: 18),
                label: Text(_saving ? 'Saving...' : 'Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Configure education levels and book types.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
          ),
          SizedBox(height: 20.h),

          // Education Levels
          Row(
            children: [
              Text(
                'Education Levels',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _addLevel,
                icon: Icon(Icons.add_circle, color: AppColors.primary),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          ...List.generate(levels.length, (li) {
            final level = levels[li];
            final subLevels = level['subLevels'] as List? ?? [];
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
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          level['key'] ?? '',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          level['label'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        color: AppColors.success,
                        onPressed: () => _addSubLevel(li),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: AppColors.error,
                        onPressed: () => setState(() => levels.removeAt(li)),
                      ),
                    ],
                  ),
                  if (subLevels.isNotEmpty) ...[
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: List.generate(subLevels.length, (si) {
                        final sub = subLevels[si];
                        return Chip(
                          label: Text(
                            sub['label'] ?? '',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () =>
                              setState(() => subLevels.removeAt(si)),
                          backgroundColor: AppColors.background,
                          side: BorderSide(color: AppColors.cardBorder),
                        );
                      }),
                    ),
                  ] else
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        'No sub-levels. Tap + to add.',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12.sp,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),

          SizedBox(height: 20.h),

          // Book Types
          Row(
            children: [
              Text(
                'Book Types',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _addBookType,
                icon: Icon(Icons.add_circle, color: AppColors.primary),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: List.generate(bookTypes.length, (i) {
              final bt = bookTypes[i];
              return Chip(
                label: Text(
                  '${bt['label']} (${bt['key']})',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => setState(() => bookTypes.removeAt(i)),
                backgroundColor: AppColors.background,
                side: BorderSide(color: AppColors.cardBorder),
              );
            }),
          ),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }
}
