import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppPalette.background,
    primaryColor: AppPalette.primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPalette.primary,
      primary: AppPalette.primary,
      secondary: AppPalette.accent,
      background: AppPalette.background,
      surface: AppPalette.surface,
      error: AppPalette.error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppPalette.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppPalette.textPrimary),
      titleTextStyle: TextStyle(
        color: AppPalette.textPrimary,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.primary,
        foregroundColor: AppPalette.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppPalette.primary,
        side: const BorderSide(color: AppPalette.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: _border(AppPalette.border),
      enabledBorder: _border(AppPalette.border),
      focusedBorder: _border(AppPalette.primary, width: 1.5),
      errorBorder: _border(AppPalette.error),
      hintStyle: TextStyle(color: AppPalette.textSecondary, fontSize: 14.sp),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: AppPalette.textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: AppPalette.textPrimary,
      ),
      bodyLarge: TextStyle(fontSize: 16.sp, color: AppPalette.textPrimary),
      bodyMedium: TextStyle(fontSize: 14.sp, color: AppPalette.textSecondary),
      labelLarge: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppPalette.textPrimary,
      ),
    ),
  );

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color, width: width),
      borderRadius: BorderRadius.circular(12.r),
    );
  }
}
