import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import '../../screens/settings_screen.dart';
import '../../screens/audit_log_screen.dart';
import '../theme/theme.dart';

/// Navigation item definition
class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Responsive admin shell: sidebar on wide screens, bottom nav on mobile.
class AdminShellLayout extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<NavItem> navItems;
  final Widget child;
  final VoidCallback onLogout;
  final VoidCallback onToggleTheme;
  final bool isDark;

  const AdminShellLayout({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.navItems,
    required this.child,
    required this.onLogout,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<AdminShellLayout> createState() => _AdminShellLayoutState();
}

class _AdminShellLayoutState extends State<AdminShellLayout>
    with SingleTickerProviderStateMixin {
  bool _sidebarExpanded = true;
  late AnimationController _animCtrl;
  late Animation<double> _widthAnim;

  static const double _expandedWidth = 240;
  static const double _collapsedWidth = 72;
  static const double _tabletBreakpoint = 768;
  static const double _desktopBreakpoint = 1100;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _widthAnim = Tween<double>(
      begin: _expandedWidth,
      end: _collapsedWidth,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOutCubic));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() => _sidebarExpanded = !_sidebarExpanded);
    if (_sidebarExpanded) {
      _animCtrl.reverse();
    } else {
      _animCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < _tabletBreakpoint) {
          return _buildMobileLayout(context);
        }

        if (width < _desktopBreakpoint) {
          return _buildSidebarLayout(context, forceCollapsed: true);
        }

        return _buildSidebarLayout(context, forceCollapsed: false);
      },
    );
  }

  // ─── Mobile Layout (ZoomDrawer) ─────────────────────────
  final _drawerController = ZoomDrawerController();

  Widget _buildMobileLayout(BuildContext context) {
    return ZoomDrawer(
      controller: _drawerController,
      menuScreen: _ZoomMenuScreen(
        isDark: widget.isDark,
        onToggleTheme: widget.onToggleTheme,
        onLogout: widget.onLogout,
        onNavigate: (screen) {
          _drawerController.close?.call();
          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => screen),
              );
            }
          });
        },
      ),
      mainScreen: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          centerTitle: true,
          title: Text(
            widget.navItems[widget.currentIndex].label,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          automaticallyImplyLeading:
              false, // Prevent back button from appearing
          actions: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: context.textSecondary,
              ),
              onPressed: () {

              },
            ),
            IconButton(
              icon: Icon(Icons.menu_rounded, color: context.textPrimary),
              onPressed: () => _drawerController.toggle?.call(),
            ),
            SizedBox(width: 4.w),
          ],
        ),
        body: SafeArea(bottom: false, child: widget.child),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: context.navBarColor,
            border: Border(
              top: BorderSide(
                color: context.cardBorder.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
              BoxShadow(
                color: Colors.black.withAlpha(4),
                blurRadius: 4,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(widget.navItems.length, (i) {
                  final item = widget.navItems[i];
                  final isActive = i == widget.currentIndex;
                  return _BottomNavItem(
                    icon: isActive ? item.activeIcon : item.icon,
                    label: item.label,
                    isActive: isActive,
                    onTap: () => widget.onIndexChanged(i),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
      style: DrawerStyle.defaultStyle,
      borderRadius: 24,
      angle: -10,
      showShadow: true,
      drawerShadowsBackgroundColor: AppColors.primary.withAlpha(40),
      slideWidth: MediaQuery.of(context).size.width * 0.65,
      mainScreenScale: 0.2,
      openCurve: Curves.easeOutCubic,
      closeCurve: Curves.easeInCubic,
      menuBackgroundColor: widget.isDark
          ? const Color(0xFF1A1A2E)
          : const Color(0xFFF0F4FF),
      mainScreenTapClose: true,
    );
  }

  // ─── Sidebar Layout ─────────────────────────────────────
  Widget _buildSidebarLayout(
    BuildContext context, {
    required bool forceCollapsed,
  }) {
    return Scaffold(
      body: Row(
        children: [
          AnimatedBuilder(
            animation: _widthAnim,
            builder: (context, child) {
              final sidebarWidth = forceCollapsed
                  ? _collapsedWidth
                  : _widthAnim.value;
              final isExpanded =
                  !forceCollapsed &&
                  sidebarWidth > (_expandedWidth + _collapsedWidth) / 2;

              return Container(
                width: sidebarWidth,
                decoration: BoxDecoration(
                  color: context.sidebarColor,
                  border: Border(
                    right: BorderSide(color: context.cardBorder, width: 1),
                  ),
                ),
                child: SafeArea(
                  right: false,
                  bottom: false,
                  child: Column(
                    children: [
                      _buildSidebarHeader(context, isExpanded, forceCollapsed),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 8.h,
                          ),
                          children: List.generate(widget.navItems.length, (i) {
                            final item = widget.navItems[i];
                            final isActive = i == widget.currentIndex;
                            return _SidebarNavItem(
                              icon: isActive ? item.activeIcon : item.icon,
                              label: item.label,
                              isActive: isActive,
                              isExpanded: isExpanded,
                              onTap: () => widget.onIndexChanged(i),
                            );
                          }),
                        ),
                      ),
                      const Divider(height: 1),
                      _buildSidebarFooter(context, isExpanded),
                    ],
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: SafeArea(left: false, bottom: false, child: widget.child),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(
    BuildContext context,
    bool isExpanded,
    bool forceCollapsed,
  ) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16.w : 0),
      child: Row(
        children: [
          if (isExpanded) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'CampusHub',
                style: AppTextStyles.h4.copyWith(color: context.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!forceCollapsed)
              IconButton(
                onPressed: _toggleSidebar,
                icon: Icon(
                  Icons.menu_open_rounded,
                  color: context.textMuted,
                  size: 20,
                ),
                splashRadius: 18,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
          ] else ...[
            Expanded(
              child: Center(
                child: forceCollapsed
                    ? Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      )
                    : IconButton(
                        onPressed: _toggleSidebar,
                        icon: Icon(
                          Icons.menu_rounded,
                          color: context.textMuted,
                          size: 22,
                        ),
                        splashRadius: 18,
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebarFooter(BuildContext context, bool isExpanded) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Column(
        children: [
          _SidebarNavItem(
            icon: widget.isDark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            label: widget.isDark ? 'Light Mode' : 'Dark Mode',
            isActive: false,
            isExpanded: isExpanded,
            onTap: widget.onToggleTheme,
          ),
          SizedBox(height: 4.h),
          _SidebarNavItem(
            icon: Icons.logout_rounded,
            label: 'Logout',
            isActive: false,
            isExpanded: isExpanded,
            onTap: widget.onLogout,
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ─── ZOOM MENU SCREEN ────────────────────────────────────
// ═══════════════════════════════════════════════════════════

class _ZoomMenuScreen extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;
  final void Function(Widget screen) onNavigate;

  const _ZoomMenuScreen({
    required this.isDark,
    required this.onToggleTheme,
    required this.onLogout,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),

              // Logo
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CampusHub',
                        style: AppTextStyles.h3.copyWith(
                          color: isDark ? Colors.white : context.textPrimary,
                        ),
                      ),
                      Text(
                        'Admin Panel',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark ? Colors.white60 : context.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 36.h),

              // Menu items
              _ZoomMenuItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                color: AppColors.primary,
                isDark: isDark,
                onTap: () => onNavigate(
                  SettingsScreen(
                    onLogout: () {
                      Navigator.pop(context);
                      onLogout();
                    },
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              _ZoomMenuItem(
                icon: Icons.history_rounded,
                label: 'Audit Log',
                color: AppColors.warning,
                isDark: isDark,
                onTap: () => onNavigate(const AuditLogScreen()),
              ),
              SizedBox(height: 6.h),
              _ZoomMenuItem(
                icon: isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                label: isDark ? 'Light Mode' : 'Dark Mode',
                color: AppColors.info,
                isDark: isDark,
                onTap: onToggleTheme,
              ),

              const Spacer(),

              // Sign out
              _ZoomMenuItem(
                icon: Icons.logout_rounded,
                label: 'Sign Out',
                color: AppColors.error,
                isDark: isDark,
                onTap: onLogout,
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Zoom Menu Item ─────────────────────────────────────────
class _ZoomMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ZoomMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: AppRadius.sm,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 14.w),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : context.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sidebar Nav Item ──────────────────────────────────────
class _SidebarNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isExpanded;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SidebarNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isExpanded,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive
        ? AppColors.error
        : widget.isActive
        ? AppColors.primary
        : _hovering
        ? context.textPrimary
        : context.textSecondary;

    final bgColor = widget.isActive
        ? context.sidebarActiveColor
        : _hovering
        ? context.cardBorder.withAlpha(60)
        : Colors.transparent;

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isExpanded ? 12.w : 0,
              vertical: 10.h,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppRadius.md,
            ),
            child: widget.isExpanded
                ? Row(
                    children: [
                      Icon(widget.icon, size: 20, color: color),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          widget.label,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.isActive)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  )
                : Tooltip(
                    message: widget.label,
                    child: Center(
                      child: Icon(widget.icon, size: 22, color: color),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Nav Item ───────────────────────────────────────
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : context.textMuted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 14.w : 12.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withValues(
                      alpha: context.isDark ? 0.2 : 0.12,
                    ),
                    AppColors.primary.withValues(
                      alpha: context.isDark ? 0.08 : 0.04,
                    ),
                  ],
                )
              : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: AppRadius.full,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            if (isActive) ...[
              SizedBox(width: 6.w),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Header Icon Button ──────────────────────────────────────


