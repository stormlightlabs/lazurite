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
/// - Unauthenticated: Home, Search, Login
/// - Authenticated: Home, Search, Notifications, Messages, Profile
class TabScaffold extends ConsumerWidget {
  const TabScaffold({required this.navigationShell, super.key});

  /// The navigation shell from [StatefulShellRoute].
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    if (authState is AuthStateAuthenticated) {
      return _buildAuthenticatedScaffold();
    } else {
      return _buildUnauthenticatedScaffold(context);
    }
  }

  Widget _buildAuthenticatedScaffold() => Scaffold(
    key: const ValueKey('authenticated_scaffold'),
    body: navigationShell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) {
        navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
      },
      destinations: const [
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
      ],
    ),
  );

  Widget _buildUnauthenticatedScaffold(BuildContext context) => Scaffold(
    key: const ValueKey('unauthenticated_scaffold'),
    body: navigationShell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        if (index == 1) {
          context.push(AppRoutes.login);
        } else {
          navigationShell.goBranch(0, initialLocation: true);
        }
      },
      destinations: const [
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
      ],
    ),
  );
}
