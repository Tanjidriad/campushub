import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/theme/campus_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final lightTheme = _buildLightTheme();

  static final darkTheme = _buildDarkTheme(oled: false);

  static final darkThemeOled = _buildDarkTheme(oled: true);

  static ThemeData _buildLightTheme() {
    final base = ThemeData(brightness: Brightness.light).textTheme;
    final jakarta = GoogleFonts.plusJakartaSansTextTheme(base);
    final textTheme = jakarta.copyWith(
      displayLarge: GoogleFonts.outfit(
        textStyle: jakarta.displayLarge?.copyWith(
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: AppPalette.textPrimary,
        ),
      ),
      displayMedium: GoogleFonts.outfit(
        textStyle: jakarta.displayMedium?.copyWith(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: AppPalette.textPrimary,
        ),
      ),
      titleLarge: GoogleFonts.outfit(
        textStyle: jakarta.titleLarge?.copyWith(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: AppPalette.textPrimary,
        ),
      ),
      bodyLarge: jakarta.bodyLarge?.copyWith(
        fontSize: 16.sp,
        color: AppPalette.textPrimary,
      ),
      bodyMedium: jakarta.bodyMedium?.copyWith(
        fontSize: 14.sp,
        color: AppPalette.textSecondary,
      ),
      labelLarge: jakarta.labelLarge?.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppPalette.textPrimary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppPalette.background,
      primaryColor: AppPalette.primary,
      extensions: const [CampusThemeExtension(oledBlack: false)],
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppPalette.primary,
        brightness: Brightness.light,
        primary: AppPalette.primary,
        secondary: AppPalette.accent,
        surface: AppPalette.surface,
        error: AppPalette.error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppPalette.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppPalette.textPrimary),
        titleTextStyle: GoogleFonts.outfit(
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
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppPalette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: AppPalette.border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppPalette.border,
        thickness: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppPalette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppPalette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppPalette.gray100,
        selectedColor: AppPalette.primary,
        labelStyle: TextStyle(fontSize: 13.sp, color: AppPalette.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppPalette.surface,
        selectedItemColor: AppPalette.primary,
        unselectedItemColor: AppPalette.gray400,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  static ThemeData _buildDarkTheme({required bool oled}) {
    const oledBg = Color(0xFF000000);
    const oledSurface = Color(0xFF121212);
    const oledBorder = Color(0xFF2A2A2A);

    final scaffoldBg = oled ? oledBg : AppPalette.darkBackground;
    final surface = oled ? oledSurface : AppPalette.darkSurface;
    final borderCol = oled ? oledBorder : AppPalette.darkBorder;
    final btnFg = oled ? oledBg : AppPalette.darkBackground;

    final base = ThemeData(brightness: Brightness.dark).textTheme;
    final jakarta = GoogleFonts.plusJakartaSansTextTheme(base);
    final textTheme = jakarta.copyWith(
      displayLarge: GoogleFonts.outfit(
        textStyle: jakarta.displayLarge?.copyWith(
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: AppPalette.darkTextPrimary,
        ),
      ),
      displayMedium: GoogleFonts.outfit(
        textStyle: jakarta.displayMedium?.copyWith(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: AppPalette.darkTextPrimary,
        ),
      ),
      titleLarge: GoogleFonts.outfit(
        textStyle: jakarta.titleLarge?.copyWith(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: AppPalette.darkTextPrimary,
        ),
      ),
      bodyLarge: jakarta.bodyLarge?.copyWith(
        fontSize: 16.sp,
        color: AppPalette.darkTextPrimary,
      ),
      bodyMedium: jakarta.bodyMedium?.copyWith(
        fontSize: 14.sp,
        color: AppPalette.darkTextSecondary,
      ),
      labelLarge: jakarta.labelLarge?.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppPalette.darkTextPrimary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBg,
      primaryColor: AppPalette.darkPrimary,
      extensions: [CampusThemeExtension(oledBlack: oled)],
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppPalette.darkAccent,
        brightness: Brightness.dark,
        primary: AppPalette.darkAccent,
        secondary: AppPalette.darkAccent,
        surface: surface,
        error: AppPalette.error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppPalette.darkTextPrimary),
        titleTextStyle: GoogleFonts.outfit(
          color: AppPalette.darkTextPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.darkAccent,
          foregroundColor: btnFg,
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
          foregroundColor: AppPalette.darkAccent,
          side: const BorderSide(color: AppPalette.darkAccent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: oled ? const Color(0xFF161616) : AppPalette.darkSurface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: _border(borderCol),
        enabledBorder: _border(borderCol),
        focusedBorder: _border(AppPalette.darkAccent, width: 1.5),
        errorBorder: _border(AppPalette.error),
        hintStyle: TextStyle(
          color: AppPalette.darkTextSecondary,
          fontSize: 14.sp,
        ),
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: borderCol, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: borderCol,
        thickness: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: borderCol,
        selectedColor: AppPalette.darkAccent,
        labelStyle: TextStyle(fontSize: 13.sp, color: AppPalette.darkTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: AppPalette.darkAccent,
        unselectedItemColor: AppPalette.darkTextLight,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color, width: width),
      borderRadius: BorderRadius.circular(12.r),
    );
  }
}
