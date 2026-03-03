// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:book_user_app/core/services/education_config_service.dart';
import '../bloc/listings_bloc.dart';
import '../bloc/listings_event.dart';
import '../bloc/listings_state.dart';

/// Horizontal filter bar for browsing by education level and class/semester.
/// Dynamically loads levels and sub-levels from the EducationConfigService.
class EducationFilterBar extends StatefulWidget {
  const EducationFilterBar({super.key});

  @override
  State<EducationFilterBar> createState() => _EducationFilterBarState();
}

class _EducationFilterBarState extends State<EducationFilterBar> {
  final _configService = EducationConfigService();
  EducationConfig? _config;

  String? _activeLevel;
  String? _activeClass;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await _configService.fetchConfig();
    if (mounted) {
      setState(() => _config = config);
    }
  }

  void _onLevelTap(String? level, BuildContext ctx) {
    setState(() {
      _activeLevel = level;
      _activeClass = null;
    });
    final s = ctx.read<ListingsBloc>().state;
    final loaded = s is ListingsLoaded ? s : null;
    ctx.read<ListingsBloc>().add(
      ListingsFilterChanged(
        category: loaded?.category,
        condition: loaded?.condition,
        minPrice: loaded?.minPrice,
        maxPrice: loaded?.maxPrice,
        sortBy: loaded?.sortBy,
        sortOrder: loaded?.sortOrder,
        educationLevel: level,
        classOrSemester: null,
        subject: loaded?.subject,
        bookType: loaded?.bookType,
        division: loaded?.division,
        district: loaded?.district,
        upazila: loaded?.upazila,
      ),
    );
  }

  void _onClassTap(String cls, BuildContext ctx) {
    final newClass = _activeClass == cls ? null : cls;
    setState(() {
      _activeClass = newClass;
    });
    final s = ctx.read<ListingsBloc>().state;
    final loaded = s is ListingsLoaded ? s : null;
    ctx.read<ListingsBloc>().add(
      ListingsFilterChanged(
        category: loaded?.category,
        condition: loaded?.condition,
        minPrice: loaded?.minPrice,
        maxPrice: loaded?.maxPrice,
        sortBy: loaded?.sortBy,
        sortOrder: loaded?.sortOrder,
        educationLevel: _activeLevel,
        classOrSemester: newClass,
        subject: loaded?.subject,
        bookType: loaded?.bookType,
        division: loaded?.division,
        district: loaded?.district,
        upazila: loaded?.upazila,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final borderColor = isDark
        ? const Color(0xFF344155)
        : const Color(0xFFE2E8F0);
    final bgColor = isDark ? const Color(0xFF1A242F) : const Color(0xFFFFFFFF);

    final config = _config ?? EducationConfig.fallback;

    // Build level list: "All" + dynamic levels from config
    final levelItems = <Map<String, String?>>[
      {'value': null, 'label': 'All'},
      ...config.levels.map((l) => {'value': l.key, 'label': l.label}),
    ];

    // Get sub-levels for the active level
    final subLevels = _activeLevel != null
        ? config.levels
              .where((l) => l.key == _activeLevel)
              .expand((l) => l.subLevels)
              .map((s) => s.label)
              .toList()
        : <String>[];
    final showSubLevels = subLevels.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Level row
        SizedBox(
          height: 36.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
            itemCount: levelItems.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, i) {
              final level = levelItems[i];
              final val = level['value'];
              final label = level['label'] ?? '';
              final isActive = _activeLevel == val;
              return GestureDetector(
                onTap: () => _onLevelTap(val, context),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: isActive ? primary : bgColor,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: isActive ? primary : borderColor),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: primary.withOpacity(0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isActive
                            ? Colors.white
                            : (isDark ? Colors.grey[300] : Colors.grey[700]),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Sub-level row (animated)
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: showSubLevels
              ? Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: SizedBox(
                    height: 32.h,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      scrollDirection: Axis.horizontal,
                      itemCount: subLevels.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (context, i) {
                        final cls = subLevels[i];
                        final isActive = _activeClass == cls;
                        return GestureDetector(
                          onTap: () => _onClassTap(cls, context),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? primary.withOpacity(0.15)
                                  : bgColor,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isActive ? primary : borderColor,
                                width: isActive ? 1.5 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                cls,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isActive
                                      ? primary
                                      : (isDark
                                            ? Colors.grey[300]
                                            : Colors.grey[600]),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
