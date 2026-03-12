import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Consistent spacing system based on 4px grid.
class AppSpacing {
  AppSpacing._();

  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 12.w;
  static double get lg => 16.w;
  static double get xl => 20.w;
  static double get xxl => 24.w;
  static double get xxxl => 32.w;
  static double get huge => 48.w;
  static double get massive => 64.w;

  /// Standard page padding
  static EdgeInsets get pagePadding => EdgeInsets.all(lg);
  static EdgeInsets get pagePaddingHorizontal =>
      EdgeInsets.symmetric(horizontal: lg);

  /// Card internal padding
  static EdgeInsets get cardPadding => EdgeInsets.all(lg);
  static EdgeInsets get cardPaddingSmall => EdgeInsets.all(md);
}

/// Text style system with Plus Jakarta Sans headings + Inter body.
class AppTextStyles {
  AppTextStyles._();

  // ─── Headings (Plus Jakarta Sans — geometric, premium) ───
  static TextStyle get h1 => GoogleFonts.plusJakartaSans(
    fontSize: 28.sp,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.8,
  );

  static TextStyle get h2 => GoogleFonts.plusJakartaSans(
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static TextStyle get h3 => GoogleFonts.plusJakartaSans(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static TextStyle get h4 => GoogleFonts.plusJakartaSans(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.2,
  );

  // ─── Body (Inter — clean, readable for data) ─────────────
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ─── Labels ──────────────────────────────────────────────
  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
    fontSize: 11.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.3,
  );

  // ─── Caption / Overline ──────────────────────────────────
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static TextStyle get overline => GoogleFonts.plusJakartaSans(
    fontSize: 10.sp,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 1.2,
  );

  // ─── Stat numbers ────────────────────────────────────────
  static TextStyle get statLarge => GoogleFonts.plusJakartaSans(
    fontSize: 28.sp,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -1.0,
  );

  static TextStyle get statMedium => GoogleFonts.plusJakartaSans(
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.5,
  );

  static TextStyle get statSmall => GoogleFonts.plusJakartaSans(
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
  );
}

/// Consistent border radius tokens.
class AppRadius {
  AppRadius._();

  static BorderRadius get xs => BorderRadius.circular(6.r);
  static BorderRadius get sm => BorderRadius.circular(8.r);
  static BorderRadius get md => BorderRadius.circular(12.r);
  static BorderRadius get lg => BorderRadius.circular(16.r);
  static BorderRadius get xl => BorderRadius.circular(20.r);
  static BorderRadius get xxl => BorderRadius.circular(24.r);
  static BorderRadius get full => BorderRadius.circular(999);
}

/// Richer, layered shadow system for premium depth.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get sm => [
    BoxShadow(
      color: Colors.black.withAlpha(10),
      blurRadius: 6,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get md => [
    BoxShadow(
      color: Colors.black.withAlpha(8),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: Colors.black.withAlpha(12),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get lg => [
    BoxShadow(
      color: Colors.black.withAlpha(6),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: Colors.black.withAlpha(12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withAlpha(6),
      blurRadius: 32,
      offset: const Offset(0, 16),
    ),
  ];

  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withAlpha(6),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: Colors.black.withAlpha(8),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ];

  /// Colored glow for primary action buttons
  static List<BoxShadow> primaryGlow(double opacity) => [
    BoxShadow(
      color: const Color(0xFF0D9488).withOpacity(opacity),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
