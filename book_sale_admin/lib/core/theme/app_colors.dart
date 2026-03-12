import 'package:flutter/material.dart';

/// Unified color system for CampusHub Admin.
/// Emerald/Teal palette — scholarly, trustworthy, fresh.
class AppColors {
  AppColors._();

  // ─── Brand ───────────────────────────────────────────────
  static const primary = Color(0xFF0D9488); // Teal 600
  static const primaryLight = Color(0xFFCCFBF1); // Teal 100
  static const primaryDark = Color(0xFF0F766E); // Teal 700
  static const primaryDeep = Color(0xFF115E59); // Teal 800
  static const accent = Color(0xFFF59E0B); // Amber 500

  // ─── Semantic ────────────────────────────────────────────
  static const success = Color(0xFF22C55E); // Green 500
  static const successLight = Color(0xFFDCFCE7);
  static const warning = Color(0xFFF97316); // Orange 500
  static const warningLight = Color(0xFFFFF7ED);
  static const error = Color(0xFFEF4444); // Red 500
  static const errorLight = Color(0xFFFEE2E2);
  static const info = Color(0xFF3B82F6); // Blue 500
  static const infoLight = Color(0xFFDBEAFE);

  // ─── Light Theme ─────────────────────────────────────────
  static const backgroundLight = Color(0xFFF8FAFB); // Warm off-white
  static const surfaceLight = Colors.white;
  static const cardLight = Colors.white;
  static const cardBorderLight = Color(0xFFE5E7EB); // Gray 200
  static const dividerLight = Color(0xFFF1F3F5);

  // ─── Dark Theme ──────────────────────────────────────────
  static const backgroundDark = Color(0xFF111318); // Warm charcoal
  static const surfaceDark = Color(0xFF1A1D27);
  static const cardDark = Color(0xFF1F2233);
  static const cardBorderDark = Color(0xFF2E3148);
  static const dividerDark = Color(0xFF272A3A);

  // ─── Text — Light ────────────────────────────────────────
  static const textPrimaryLight = Color(0xFF111827); // Gray 900
  static const textSecondaryLight = Color(0xFF4B5563); // Gray 600
  static const textMutedLight = Color(0xFF9CA3AF); // Gray 400

  // ─── Text — Dark ─────────────────────────────────────────
  static const textPrimaryDark = Color(0xFFF3F4F6); // Gray 100
  static const textSecondaryDark = Color(0xFF9CA3AF); // Gray 400
  static const textMutedDark = Color(0xFF6B7280); // Gray 500

  // ─── Sidebar ─────────────────────────────────────────────
  static const sidebarLight = Color(0xFFFFFFFF);
  static const sidebarDark = Color(0xFF151827);
  static const sidebarActiveLight = Color(0xFFE6FAF7);
  static const sidebarActiveDark = Color(0xFF1A3A36);

  // ─── Navigation ──────────────────────────────────────────
  static const navBarLight = Colors.white;
  static const navBarDark = Color(0xFF1A1D27);

  // ─── Gradients ───────────────────────────────────────────
  static const List<Color> primaryGradient = [
    Color(0xFF0D9488),
    Color(0xFF14B8A6),
  ];
  static const List<Color> accentGradient = [
    Color(0xFFF59E0B),
    Color(0xFFFBBF24),
  ];
  static const List<Color> darkCardGradient = [
    Color(0xFF1F2233),
    Color(0xFF252842),
  ];

  // ─── Backward-compatible aliases ─────────────────────────
  static const background = backgroundLight;
  static const surface = surfaceLight;
  static const cardBorder = cardBorderLight;
  static const textPrimary = textPrimaryLight;
  static const textSecondary = textSecondaryLight;
  static const textMuted = textMutedLight;
}
