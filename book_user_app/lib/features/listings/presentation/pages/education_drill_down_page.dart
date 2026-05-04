// ignore_for_file: deprecated_member_use
import 'package:book_user_app/core/services/education_config_service.dart';
import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Screen 2: Shows streams and departments for a selected education level.
/// - University → Science & Engineering → [CSE, EEE, Physics…]
/// - College → Science / Arts / Commerce
class EducationDrillDownPage extends StatelessWidget {
  final EducationLevel level;

  const EducationDrillDownPage({super.key, required this.level});

  IconData _getStreamIcon(String key) {
    switch (key) {
      case 'science-engineering':
        return Icons.science_rounded;
      case 'arts-humanities':
        return Icons.auto_stories_rounded;
      case 'business':
        return Icons.business_center_rounded;
      case 'law':
        return Icons.gavel_rounded;
      case 'medical':
        return Icons.local_hospital_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'arts':
        return Icons.auto_stories_rounded;
      case 'commerce':
        return Icons.business_center_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  Color _getStreamColor(int index) {
    const palette = [
      Color(0xFF3B82F6),
      Color(0xFFF59E0B),
      Color(0xFF10B981),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
    ];
    return palette[index % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // ─── App Bar ───
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: colors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              level.label,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: false,
          ),

          // ─── Description ───
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
              child: Text(
                'Choose your stream to find books from your department.',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: colors.textLight,
                  height: 1.4,
                ),
              ),
            ),
          ),

          // ─── Streams List ───
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final stream = level.streams[index];
                final color = _getStreamColor(index);
                return _StreamExpandableCard(
                  stream: stream,
                  icon: _getStreamIcon(stream.key),
                  color: color,
                  levelKey: level.key,
                );
              },
              childCount: level.streams.length,
            ),
          ),

          // ─── Popular Departments Quick Access ───
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 8.h),
              child: Text(
                'Popular Departments',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44.h,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                scrollDirection: Axis.horizontal,
                itemCount: _getPopularDepartments().length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final dept = _getPopularDepartments()[index];
                  return GestureDetector(
                    onTap: () {
                      context.pushNamed(
                        'see-all',
                        pathParameters: {'type': 'latest'},
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: colors.subtleFill,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: colors.border.withOpacity(0.5)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        dept.label,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom padding
          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
        ],
      ),
    );
  }

  List<EducationDepartment> _getPopularDepartments() {
    final all = <EducationDepartment>[];
    for (final stream in level.streams) {
      all.addAll(stream.departments);
    }
    return all.take(8).toList();
  }
}

/// Expandable card that shows a stream and its departments.
class _StreamExpandableCard extends StatefulWidget {
  final EducationStream stream;
  final IconData icon;
  final Color color;
  final String levelKey;

  const _StreamExpandableCard({
    required this.stream,
    required this.icon,
    required this.color,
    required this.levelKey,
  });

  @override
  State<_StreamExpandableCard> createState() => _StreamExpandableCardState();
}

class _StreamExpandableCardState extends State<_StreamExpandableCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      child: Container(
        decoration: BoxDecoration(
          color: colors.subtleFill,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Header
            GestureDetector(
              onTap: _toggle,
              child: Container(
                padding: EdgeInsets.all(16.w),
                color: Colors.transparent,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 22.sp,
                        color: widget.color,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.stream.label,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${widget.stream.departments.length} departments',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: colors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: _expanded ? 0.5 : 0,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 24.sp,
                        color: colors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Departments List (animated)
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                children: [
                  Divider(
                    height: 1,
                    color: colors.border.withOpacity(0.5),
                    indent: 16.w,
                    endIndent: 16.w,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: widget.stream.departments.map((dept) {
                        return _buildDepartmentChip(dept, colors);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentChip(EducationDepartment dept, AppColors colors) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'see-all',
          pathParameters: {'type': 'latest'},
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: colors.border.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dept.label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(width: 6.w),
            if (dept.subLevels.isNotEmpty)
              Text(
                '${dept.subLevels.length} sem',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: colors.textLight,
                ),
              ),
            SizedBox(width: 4.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 10.sp,
              color: colors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
