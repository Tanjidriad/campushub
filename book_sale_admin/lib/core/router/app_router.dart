import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/listings/presentation/bloc/listings_bloc.dart';
import '../../features/listings/presentation/pages/listings_screen.dart';
import '../../features/category_config/presentation/bloc/category_bloc.dart';
import '../../features/category_config/presentation/pages/categories_screen.dart';
import '../../features/reports/presentation/bloc/reports_bloc.dart';
import '../../features/reports/presentation/pages/reports_screen.dart';
import '../../features/users/presentation/bloc/users_bloc.dart';
import '../../screens/users_screen.dart';
import '../../injection_container.dart' as di;
import '../theme/theme.dart';
import '../theme/theme_bloc.dart';
import '../widgets/admin_shell_layout.dart';

/// Route path constants
abstract class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const users = '/users';
  static const listings = '/listings';
  static const categories = '/categories';
  static const reports = '/reports';
  static const auditLog = '/audit-log';
  static const settings = '/settings';
}

/// Nav items shared between router and shell layout
const shellNavItems = [
  NavItem(
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard_rounded,
    label: 'Dashboard',
  ),
  NavItem(
    icon: Icons.people_outlined,
    activeIcon: Icons.people_rounded,
    label: 'Users',
  ),
  NavItem(
    icon: Icons.inventory_2_outlined,
    activeIcon: Icons.inventory_2_rounded,
    label: 'Listings',
  ),
  NavItem(
    icon: Icons.category_outlined,
    activeIcon: Icons.category_rounded,
    label: 'Categories',
  ),
  NavItem(
    icon: Icons.flag_outlined,
    activeIcon: Icons.flag_rounded,
    label: 'Reports',
  ),
];

/// Converts an AuthBloc stream into a [Listenable] for GoRouter.refreshListenable
class GoRouterAuthRefresh extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;

  GoRouterAuthRefresh(Stream<AuthState> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// Creates the app-level GoRouter
GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: false,
    refreshListenable: GoRouterAuthRefresh(authBloc.stream),

    // ── Redirect logic ──
    redirect: (context, state) {
      final authState = authBloc.state;
      final isOnLogin = state.matchedLocation == AppRoutes.login;

      // Still loading — don't redirect yet
      if (authState is AuthInitial || authState is AuthLoading) return null;

      final isAuthenticated = authState is Authenticated;

      // Not authenticated → force login
      if (!isAuthenticated && !isOnLogin) return AppRoutes.login;

      // Authenticated but still on login → go to dashboard
      if (isAuthenticated && isOnLogin) return AppRoutes.dashboard;

      return null; // no redirect
    },

    // ── Routes ──
    routes: [
      // Login (outside the shell)
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Main admin shell with 6 tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final isDark = context.isDark;
          return AdminShellLayout(
            currentIndex: navigationShell.currentIndex,
            onIndexChanged: (i) => navigationShell.goBranch(
              i,
              initialLocation: i == navigationShell.currentIndex,
            ),
            navItems: shellNavItems,
            child: navigationShell,
            isDark: isDark,
            onToggleTheme: () =>
                context.read<ThemeBloc>().add(ToggleThemeEvent()),
            onLogout: () => _confirmLogout(context),
          );
        },
        branches: [
          // 0 — Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => BlocProvider(
                  create: (_) => di.sl<DashboardBloc>(),
                  child: const DashboardScreen(),
                ),
              ),
            ],
          ),

          // 1 — Users
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.users,
                builder: (context, state) => BlocProvider(
                  create: (_) => di.sl<UsersBloc>(),
                  child: const UsersScreen(),
                ),
              ),
            ],
          ),

          // 2 — Listings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.listings,
                builder: (context, state) => BlocProvider(
                  create: (_) => di.sl<ListingsBloc>(),
                  child: const ListingsScreen(),
                ),
              ),
            ],
          ),

          // 3 — Categories
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.categories,
                builder: (context, state) => BlocProvider(
                  create: (_) => di.sl<CategoryBloc>(),
                  child: const CategoriesScreen(),
                ),
              ),
            ],
          ),

          // 4 — Reports
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reports,
                builder: (context, state) => BlocProvider(
                  create: (_) => di.sl<ReportsBloc>(),
                  child: const ReportsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

void _confirmLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Logout?'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            context.read<AuthBloc>().add(LogoutEvent());
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Logout'),
        ),
      ],
    ),
  );
}
