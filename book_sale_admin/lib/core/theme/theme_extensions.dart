import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Extension on BuildContext for easy theme-aware access.
/// Usage: context.colorScheme, context.isDark, context.adaptiveColor(...)
extension ThemeContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDark => theme.brightness == Brightness.dark;

  // ─── Adaptive Colors ─────────────────────────────────────
  Color get background =>
      isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get surface => isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
  Color get cardColor => isDark ? AppColors.cardDark : AppColors.cardLight;
  Color get cardBorder =>
      isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight;
  Color get dividerColor =>
      isDark ? AppColors.dividerDark : AppColors.dividerLight;
  Color get textPrimary =>
      isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondary =>
      isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get textMuted =>
      isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
  Color get sidebarColor =>
      isDark ? AppColors.sidebarDark : AppColors.sidebarLight;
  Color get sidebarActiveColor =>
      isDark ? AppColors.sidebarActiveDark : AppColors.sidebarActiveLight;
  Color get navBarColor =>
      isDark ? AppColors.navBarDark : AppColors.navBarLight;

  // ─── Gradients ───────────────────────────────────────────
  LinearGradient get primaryGradient => const LinearGradient(
    colors: AppColors.primaryGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get accentGradient => const LinearGradient(
    colors: AppColors.accentGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
