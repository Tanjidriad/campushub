import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/api_client.dart';
import '../core/constants.dart';

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
          const SnackBar(
            content: Text('Configuration saved!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save'),
            backgroundColor: Colors.red,
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_config == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Failed to load config',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8.h),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    final levels = _config!['levels'] as List? ?? [];
    final bookTypes = _config!['bookTypes'] as List? ?? [];

    return Stack(
      children: [
        RefreshIndicator(
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
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
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
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Configure education levels and book types for your marketplace.',
                style: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
              ),
              SizedBox(height: 24.h),

              // Education Levels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Education Levels',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: _addLevel,
                    icon: const Icon(
                      Icons.add_circle,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              ...List.generate(levels.length, (li) {
                final level = levels[li];
                final subLevels = level['subLevels'] as List? ?? [];
                return Card(
                  margin: EdgeInsets.only(bottom: 12.h),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
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
                                color: const Color(
                                  0xFF6366F1,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                level['key'] ?? '',
                                style: TextStyle(
                                  color: const Color(0xFF6366F1),
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                level['label'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 20),
                              color: Colors.green,
                              onPressed: () => _addSubLevel(li),
                              tooltip: 'Add sub-level',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              color: Colors.red,
                              onPressed: () {
                                setState(() => levels.removeAt(li));
                              },
                              tooltip: 'Remove level',
                            ),
                          ],
                        ),
                        if (subLevels.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          Wrap(
                            spacing: 6.w,
                            runSpacing: 6.h,
                            children: List.generate(subLevels.length, (si) {
                              final sub = subLevels[si];
                              return Chip(
                                label: Text(
                                  sub['label'] ?? '',
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  setState(() => subLevels.removeAt(si));
                                },
                                backgroundColor: const Color(0xFF334155),
                                side: BorderSide.none,
                              );
                            }),
                          ),
                        ] else
                          Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              'No sub-levels. Tap + to add.',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12.sp,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),

              SizedBox(height: 24.h),

              // Book Types
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Book Types',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: _addBookType,
                    icon: const Icon(
                      Icons.add_circle,
                      color: Color(0xFF6366F1),
                    ),
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
                      style: TextStyle(fontSize: 12.sp, color: Colors.white),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() => bookTypes.removeAt(i));
                    },
                    backgroundColor: const Color(0xFF334155),
                    side: BorderSide.none,
                  );
                }),
              ),

              SizedBox(height: 100.h),
            ],
          ),
        ),
      ],
    );
  }
}
