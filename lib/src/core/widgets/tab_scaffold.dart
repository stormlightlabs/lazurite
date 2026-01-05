import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/routes.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';

/// Bottom navigation scaffold that wraps the tab content.
///
/// Uses [StatefulNavigationShell] to preserve state across tab switches.
/// Shows different tabs based on authentication state:
/// - Unauthenticated: Home, Login
/// - Authenticated: Home, Search, Notifications, Messages, Profile
class TabScaffold extends ConsumerStatefulWidget {
  const TabScaffold({required this.navigationShell, super.key});

  /// The navigation shell from [StatefulShellRoute].
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<TabScaffold> createState() => _TabScaffoldState();
}

class _TabScaffoldState extends ConsumerState<TabScaffold> {
  bool _resetScheduled = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState is AuthStateAuthenticated;

    _ensureHomeBranchWhenUnauthenticated(isAuthenticated);

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: isAuthenticated ? widget.navigationShell.currentIndex : 0,
        onDestinationSelected: (index) {
          if (isAuthenticated) {
            widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
            );
          } else if (index == 1) {
            context.go(AppRoutes.login);
          } else {
            widget.navigationShell.goBranch(0, initialLocation: true);
          }
        },
        destinations: isAuthenticated ? _authenticatedDestinations : _unauthenticatedDestinations,
      ),
    );
  }

  void _ensureHomeBranchWhenUnauthenticated(bool isAuthenticated) {
    if (isAuthenticated) {
      _resetScheduled = false;
      return;
    }

    if (_resetScheduled || widget.navigationShell.currentIndex == 0) {
      return;
    }

    _resetScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.navigationShell.goBranch(0, initialLocation: true);
      _resetScheduled = false;
    });
  }
}

const _authenticatedDestinations = [
  NavigationDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
    label: 'Home',
  ),
  NavigationDestination(
    icon: Icon(Icons.search_outlined),
    selectedIcon: Icon(Icons.search),
    label: 'Search',
  ),
  NavigationDestination(
    icon: Icon(Icons.notifications_outlined),
    selectedIcon: Icon(Icons.notifications),
    label: 'Notifications',
  ),
  NavigationDestination(
    icon: Icon(Icons.mail_outlined),
    selectedIcon: Icon(Icons.mail),
    label: 'Messages',
  ),
  NavigationDestination(
    icon: Icon(Icons.person_outlined),
    selectedIcon: Icon(Icons.person),
    label: 'Profile',
  ),
];

const _unauthenticatedDestinations = [
  NavigationDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
    label: 'Home',
  ),
  NavigationDestination(
    icon: Icon(Icons.login_outlined),
    selectedIcon: Icon(Icons.login),
    label: 'Login',
  ),
];
