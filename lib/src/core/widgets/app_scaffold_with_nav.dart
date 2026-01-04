import 'package:flutter/material.dart';

/// Navigation destination configuration.
class NavDestination {
  /// Creates a navigation destination.
  const NavDestination({required this.icon, required this.selectedIcon, required this.label});

  /// Icon shown when not selected.
  final IconData icon;

  /// Icon shown when selected.
  final IconData selectedIcon;

  /// Label for the destination.
  final String label;
}

/// A scaffold with bottom navigation bar and body slot.
///
/// This is a general-purpose navigation scaffold that can be used independently of go_router's
/// StatefulShellRoute.
/// For use with StatefulShellRoute, see [TabScaffold] instead.
class AppScaffoldWithNav extends StatelessWidget {
  const AppScaffoldWithNav({
    required this.body,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.floatingActionButton,
    super.key,
  });

  /// The main content body.
  final Widget body;

  /// The navigation destinations to display.
  final List<NavDestination> destinations;

  /// The currently selected destination index.
  final int selectedIndex;

  /// Callback when a destination is selected.
  final ValueChanged<int> onDestinationSelected;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          for (final dest in destinations)
            NavigationDestination(
              icon: Icon(dest.icon),
              selectedIcon: Icon(dest.selectedIcon),
              label: dest.label,
            ),
        ],
      ),
    );
  }
}
