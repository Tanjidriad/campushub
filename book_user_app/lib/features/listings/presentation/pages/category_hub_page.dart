// ignore_for_file: deprecated_member_use
import 'package:book_user_app/core/services/education_config_service.dart';
import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/features/categories/domain/entities/category.dart';
import 'package:book_user_app/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:book_user_app/features/categories/presentation/bloc/categories_state.dart';
import 'package:book_user_app/features/listings/presentation/pages/education_drill_down_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

/// The main Category Hub — entry point for all discovery flows.
/// Shows Education Levels, Product Categories, and Book Types.
class CategoryHubPage extends StatefulWidget {
  const CategoryHubPage({super.key});

  @override
  State<CategoryHubPage> createState() => _CategoryHubPageState();
}

class _CategoryHubPageState extends State<CategoryHubPage> {
  EducationConfig? _config;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await EducationConfigService().fetchConfig();
    if (mounted) setState(() => _config = config);
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'menu_book':
      case 'textbooks':
        return Icons.menu_book_rounded;
      case 'laptop':
      case 'electronics':
        return Icons.laptop_mac_rounded;
      case 'chair':
      case 'furniture':
        return Icons.chair_rounded;
      case 'checkroom':
      case 'clothing':
        return Icons.checkroom_rounded;
      case 'sports':
        return Icons.sports_basketball_rounded;
      case 'music_note':
      case 'music':
        return Icons.music_note_rounded;
      case 'palette':
      case 'art':
        return Icons.palette_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  IconData _getLevelIcon(String key) {
    switch (key) {
      case 'school':
        return Icons.school_rounded;
      case 'college':
        return Iconsax.teacher;
      case 'university':
        return Icons.account_balance_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  Color _getLevelColor(String key) {
    switch (key) {
      case 'school':
        return const Color(0xFF10B981);
      case 'college':
        return const Color(0xFF3B82F6);
      case 'university':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final config = _config ?? EducationConfig.fallback;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // ─── Premium App Bar ───
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
              'Browse',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: Icon(
                  Iconsax.search_normal,
                  size: 22.sp,
                  color: colors.textPrimary,
                ),
                onPressed: () {
                  // Could navigate to search
                },
              ),
              SizedBox(width: 8.w),
            ],
          ),

          // ─── Education Level Section ───
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
              child: Text(
                'Education Level',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 14.h)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 130.h,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                scrollDirection: Axis.horizontal,
                itemCount: config.levels.length,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  final level = config.levels[index];
                  final color = _getLevelColor(level.key);
                  return _buildEducationLevelCard(
                    level: level,
                    icon: _getLevelIcon(level.key),
                    color: color,
                  );
                },
              ),
            ),
          ),

          // ─── Divider ───
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Row(
                children: [
                  Expanded(child: Divider(color: colors.border, thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'Or browse by type',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: colors.textLight,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: colors.border, thickness: 1)),
                ],
              ),
            ),
          ),

          // ─── Product Categories Section ───
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
              child: Text(
                'Product Categories',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          BlocBuilder<CategoriesBloc, CategoriesState>(
            builder: (context, state) {
              if (state is CategoriesLoaded) {
                return _buildCategoryGrid(state.categories);
              }
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _buildCategoryShimmer(),
                ),
              );
            },
          ),

          // ─── Book Types Section ───
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
              child: Text(
                'Book Types',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: config.bookTypes.map((bt) {
                  return _buildBookTypeChip(bt);
                }).toList(),
              ),
            ),
          ),

          // Bottom padding
          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
        ],
      ),
    );
  }

  // ─── Education Level Card ───
  Widget _buildEducationLevelCard({
    required EducationLevel level,
    required IconData icon,
    required Color color,
  }) {
    final colors = AppColors.of(context);
    final subCount = level.hasStreams
        ? '${level.streams.length} streams'
        : '${level.subLevels.length} classes';

    return GestureDetector(
      onTap: () {
        if (level.hasStreams) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EducationDrillDownPage(level: level),
            ),
          );
        } else {
          // Flat level (School) — go straight to filtered listings
          context.pushNamed('see-all', pathParameters: {'type': 'latest'});
        }
      },
      child: Container(
        width: 140.w,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.15), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, size: 22.sp, color: color),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subCount,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Product Category Grid ───
  SliverPadding _buildCategoryGrid(List<Category> categories) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.8,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final cat = categories[index];
          return _buildCategoryCard(cat);
        }, childCount: categories.length),
      ),
    );
  }

  Widget _buildCategoryCard(Category cat) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: () {
        context.pushNamed('see-all', pathParameters: {'type': 'latest'});
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: colors.subtleFill,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: cat.image != null && cat.image!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: CachedNetworkImage(
                        imageUrl: cat.image!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Icon(
                          _getCategoryIcon(cat.icon),
                          size: 20.sp,
                          color: colors.textSecondary,
                        ),
                      ),
                    )
                  : Icon(
                      _getCategoryIcon(cat.icon),
                      size: 20.sp,
                      color: colors.textSecondary,
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cat.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (cat.listingCount > 0)
                    Padding(
                      padding: EdgeInsets.only(top: 3.h),
                      child: Text(
                        '${cat.listingCount} items',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: colors.textLight,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: colors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Book Type Chip ───
  Widget _buildBookTypeChip(BookType bookType) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: () {
        context.pushNamed('see-all', pathParameters: {'type': 'latest'});
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: colors.subtleFill,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.border.withOpacity(0.5)),
        ),
        child: Text(
          bookType.label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ─── Shimmer ───
  Widget _buildCategoryShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.8,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppColors.of(context).shimmerBase,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }
}
