import 'package:book_user_app/core/theme/campus_theme_extension.dart';
import 'package:flutter/material.dart';

/// Resolved theme-aware color set. Obtain via `AppColors.of(context)`.
class AppColors {
  final Color primary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textLight;
  final Color border;
  final Color error;
  final Color success;
  final Color warning;
  final Color card;
  final Color shadow;
  final Color divider;
  final Color icon;
  final Color iconSecondary;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color subtleFill;
  final Color onPrimary;
  final Color inputFill;
  final Color overlay;
  final Color chatBubbleOutgoing;
  final Color chatBubbleIncoming;
  final Color badgeBg;
  final Color iconMuted;
  final bool isDark;

  const AppColors._({
    required this.primary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textLight,
    required this.border,
    required this.error,
    required this.success,
    required this.warning,
    required this.card,
    required this.shadow,
    required this.divider,
    required this.icon,
    required this.iconSecondary,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.subtleFill,
    required this.onPrimary,
    required this.inputFill,
    required this.overlay,
    required this.chatBubbleOutgoing,
    required this.chatBubbleIncoming,
    required this.badgeBg,
    required this.iconMuted,
    required this.isDark,
  });

  static const _light = AppColors._(
    primary: Color(0xFF111827),
    accent: Color(0xFF2563EB),
    background: Color(0xFFFFFFFF),
    surface: Colors.white,
    textPrimary: Color(0xFF1F2937),
    textSecondary: Color(0xFF6B7280),
    textLight: Color(0xFF9CA3AF),
    border: Color(0xFFE5E7EB),
    error: Color(0xFFEF4444),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    card: Colors.white,
    shadow: Color(0x1A000000),
    divider: Color(0xFFE5E7EB),
    icon: Color(0xFF1F2937),
    iconSecondary: Color(0xFF6B7280),
    shimmerBase: Color(0xFFE5E7EB),
    shimmerHighlight: Color(0xFFF9FAFB),
    subtleFill: Color(0xFFF3F4F6),
    onPrimary: Colors.white,
    inputFill: Color(0xFFF9FAFB),
    overlay: Color(0x0D000000),
    chatBubbleOutgoing: Color(0xFF111827),
    chatBubbleIncoming: Color(0xFFF3F4F6),
    badgeBg: Color(0xFFEF4444),
    iconMuted: Color(0xFF9CA3AF),
    isDark: false,
  );

  static const _dark = AppColors._(
    primary: Color(0xFF60A5FA),
    accent: Color(0xFF60A5FA),
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textLight: Color(0xFF64748B),
    border: Color(0xFF334155),
    error: Color(0xFFEF4444),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    card: Color(0xFF1E293B),
    shadow: Color(0x40000000),
    divider: Color(0xFF334155),
    icon: Color(0xFFF1F5F9),
    iconSecondary: Color(0xFF94A3B8),
    shimmerBase: Color(0xFF334155),
    shimmerHighlight: Color(0xFF475569),
    subtleFill: Color(0xFF253347),
    onPrimary: Color(0xFF0F172A),
    inputFill: Color(0xFF253347),
    overlay: Color(0x1AFFFFFF),
    chatBubbleOutgoing: Color(0xFF60A5FA),
    chatBubbleIncoming: Color(0xFF253347),
    badgeBg: Color(0xFFEF4444),
    iconMuted: Color(0xFF64748B),
    isDark: true,
  );

  /// OLED-friendly dark: true black scaffold, lifted cards for separation.
  static const _darkOled = AppColors._(
    primary: Color(0xFF60A5FA),
    accent: Color(0xFF60A5FA),
    background: Color(0xFF000000),
    surface: Color(0xFF121212),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textLight: Color(0xFF64748B),
    border: Color(0xFF2A2A2A),
    error: Color(0xFFEF4444),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    card: Color(0xFF121212),
    shadow: Color(0x60000000),
    divider: Color(0xFF2A2A2A),
    icon: Color(0xFFF1F5F9),
    iconSecondary: Color(0xFF94A3B8),
    shimmerBase: Color(0xFF2A2A2A),
    shimmerHighlight: Color(0xFF3A3A3A),
    subtleFill: Color(0xFF161616),
    onPrimary: Color(0xFF000000),
    inputFill: Color(0xFF161616),
    overlay: Color(0x1AFFFFFF),
    chatBubbleOutgoing: Color(0xFF60A5FA),
    chatBubbleIncoming: Color(0xFF161616),
    badgeBg: Color(0xFFEF4444),
    iconMuted: Color(0xFF64748B),
    isDark: true,
  );

  /// Resolve the correct palette for the current theme brightness.
  static AppColors of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (!dark) return _light;
    final oled =
        Theme.of(context).extension<CampusThemeExtension>()?.oledBlack ?? false;
    return oled ? _darkOled : _dark;
  }
}

class AppPalette {
  // Modern Minimalist Palette — Light
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

  // ── Dark Mode Palette ──
  static const Color darkPrimary = Color(0xFFE5E7EB); // Light text on dark
  static const Color darkAccent = Color(0xFF60A5FA); // Lighter blue

  static const Color darkBackground = Color(0xFF0F172A); // Deep navy
  static const Color darkSurface = Color(0xFF1E293B); // Slate card

  static const Color darkTextPrimary = Color(0xFFF1F5F9); // Near-white
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Muted slate
  static const Color darkTextLight = Color(0xFF64748B); // Dimmed

  static const Color darkBorder = Color(0xFF334155); // Subtle border
}
