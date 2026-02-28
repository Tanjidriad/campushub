import 'package:book_user_app/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:book_user_app/features/listings/presentation/bloc/listings_bloc.dart';
import 'package:book_user_app/features/listings/presentation/widgets/filter_bottom_sheet.dart';
import 'package:book_user_app/features/listings/presentation/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

class CleanSearchBar extends StatelessWidget {
  const CleanSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchPage()),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Color(0xFFF7F7FB),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(Iconsax.search_normal, color: Colors.grey[400], size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  "Search with keywords...",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final listingsBloc = context.read<ListingsBloc>();
                  final categoriesBloc = context.read<CategoriesBloc>();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (sheetContext) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: listingsBloc),
                        BlocProvider.value(value: categoriesBloc),
                      ],
                      child: const FilterBottomSheet(),
                    ),
                  );
                },
                child: Icon(
                  Iconsax.setting_4,
                  color: Colors.grey[600],
                  size: 20.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
