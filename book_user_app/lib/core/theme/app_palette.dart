import 'package:flutter/material.dart';

class AppPalette {
  // Modern Minimalist Palette
  static const Color primary = Color(0xFF111827); // Charcoal Black
  static const Color accent = Color(0xFF2563EB); // Royal Blue

  static const Color background = Color(
    0xFFFFFFFF,
  ); // Subtle off-white (matching reference app)
  static const Color surface = Colors.white; // Pure White

  static const Color textPrimary = Color(0xFF1F2937); // Dark Gray
  static const Color textSecondary = Color(0xFF6B7280); // Medium Gray
  static const Color textLight = Color(0xFF9CA3AF); // Light Gray

  static const Color border = Color(0xFFE5E7EB); // Light Gray

  static const Color error = Color(0xFFEF4444); // Soft Red
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color warning = Color(0xFFF59E0B); // Amber

  // Utility colors (kept for compatibility but discouraged)
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // Gray variants (kept for compatibility)
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
}
