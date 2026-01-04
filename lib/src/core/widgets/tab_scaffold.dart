import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation scaffold that wraps the tab content.
///
/// Uses [StatefulNavigationShell] to preserve state across tab switches.
class TabScaffold extends StatelessWidget {
  /// Creates a tab scaffold.
  const TabScaffold({required this.navigationShell, super.key});

  /// The navigation shell from [StatefulShellRoute].
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          // Navigate to the branch with the corresponding index.
          // goBranch(index) navigates to the initial route of the branch.
          navigationShell.goBranch(
            index,
            // If the current branch is the same as the destination,
            // navigate to the initial location of the branch.
            initialLocation: index == navigationShell.currentIndex,
          );
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
  }
}
