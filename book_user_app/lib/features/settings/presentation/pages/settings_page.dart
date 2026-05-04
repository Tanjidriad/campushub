import 'dart:ui';

import 'package:book_user_app/core/locale/locale_cubit.dart';
import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/theme/theme_cubit.dart';
import 'package:book_user_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20.sp,
            color: colors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.settings,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        children: [
          // ── Appearance Section ──
          _SectionHeader(title: l10n.appearance),
          SizedBox(height: 8.h),
          _ThemeSelector(),
          SizedBox(height: 24.h),

          // ── Language Section ──
          _SectionHeader(title: l10n.language),
          SizedBox(height: 8.h),
          _LanguageSelector(),
          SizedBox(height: 24.h),

          // ── Account Section ──
          _SectionHeader(title: l10n.account),
          SizedBox(height: 8.h),
          _SettingsTile(
            icon: Iconsax.password_check,
            title: l10n.changePassword,
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: colors.textSecondary,
            ),
            onTap: () => context.pushNamed('change-password'),
          ),
          SizedBox(height: 8.h),
          _SettingsTile(
            icon: Iconsax.profile_delete,
            title: l10n.blockedUsers,
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: colors.textSecondary,
            ),
            onTap: () => context.pushNamed('blocked-users'),
          ),
          SizedBox(height: 24.h),

          // ── App Info ──

          _SectionHeader(title: l10n.general),
          SizedBox(height: 8.h),
          _SettingsTile(
            icon: Iconsax.info_circle,
            title: l10n.appVersion,
            trailing: Text(
              '1.0.0',
              style: TextStyle(fontSize: 13.sp, color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.of(context).textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ─── Theme Selector ──────────────────────────────────────────────

class _ThemeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, currentMode) {
        return Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              _ThemeOption(
                icon: Iconsax.sun_1,
                label: l10n.lightMode,
                isSelected: currentMode == ThemeMode.light,
                onTap: () =>
                    context.read<ThemeCubit>().setTheme(ThemeMode.light),
                showDivider: true,
              ),
              _ThemeOption(
                icon: Iconsax.moon,
                label: l10n.darkMode,
                isSelected: currentMode == ThemeMode.dark,
                onTap: () =>
                    context.read<ThemeCubit>().setTheme(ThemeMode.dark),
                showDivider: true,
              ),
              _ThemeOption(
                icon: Iconsax.mobile,
                label: l10n.systemDefault,
                isSelected: currentMode == ThemeMode.system,
                onTap: () =>
                    context.read<ThemeCubit>().setTheme(ThemeMode.system),
                showDivider: false,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showDivider;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: showDivider
              ? null
              : BorderRadius.vertical(bottom: Radius.circular(14.r)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20.sp,
                  color: isSelected ? colors.primary : colors.textSecondary,
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? colors.primary : colors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Iconsax.tick_circle5,
                    size: 20.sp,
                    color: colors.primary,
                  ),
              ],
            ),
          ),
        ),
        if (showDivider) Divider(height: 1, color: colors.border, indent: 50.w),
      ],
    );
  }
}

// ─── Language Selector ───────────────────────────────────────────

class _LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppColors.of(context);

    return BlocBuilder<LocaleCubit, Locale?>(
      builder: (context, currentLocale) {
        final effectiveCode =
            currentLocale?.languageCode ??
            PlatformDispatcher.instance.locale.languageCode;

        return Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              _LanguageOption(
                flag: '🇺🇸',
                label: l10n.english,
                isSelected: effectiveCode == 'en' && currentLocale != null,
                onTap: () =>
                    context.read<LocaleCubit>().setLocale(const Locale('en')),
                showDivider: true,
              ),
              _LanguageOption(
                flag: '🇧🇩',
                label: l10n.bengali,
                isSelected: effectiveCode == 'bn' && currentLocale != null,
                onTap: () =>
                    context.read<LocaleCubit>().setLocale(const Locale('bn')),
                showDivider: true,
              ),
              _LanguageOption(
                flag: '📱',
                label: l10n.systemDefault,
                isSelected: currentLocale == null,
                onTap: () => context.read<LocaleCubit>().useSystemLocale(),
                showDivider: false,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showDivider;

  const _LanguageOption({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: showDivider
              ? null
              : BorderRadius.vertical(bottom: Radius.circular(14.r)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Text(flag, style: TextStyle(fontSize: 20.sp)),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? colors.primary : colors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Iconsax.tick_circle5,
                    size: 20.sp,
                    color: colors.primary,
                  ),
              ],
            ),
          ),
        ),
        if (showDivider) Divider(height: 1, color: colors.border, indent: 50.w),
      ],
    );
  }
}

// ─── Generic Settings Tile ───────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: colors.textSecondary),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 15.sp, color: colors.textPrimary),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
