import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/app_scaffold_with_nav.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final testDestinations = [
    const NavDestination(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
    const NavDestination(icon: Icons.search_outlined, selectedIcon: Icons.search, label: 'Search'),
    const NavDestination(
      icon: Icons.person_outlined,
      selectedIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  group('AppScaffoldWithNav', () {
    testWidgets('renders body content', (tester) async {
      await tester.pumpApp(
        AppScaffoldWithNav(
          body: const Center(child: Text('Body Content')),
          destinations: testDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      expect(find.text('Body Content'), findsOneWidget);
    });

    testWidgets('renders navigation bar with destinations', (tester) async {
      await tester.pumpApp(
        AppScaffoldWithNav(
          body: const SizedBox(),
          destinations: testDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('highlights selected destination', (tester) async {
      await tester.pumpApp(
        AppScaffoldWithNav(
          body: const SizedBox(),
          destinations: testDestinations,
          selectedIndex: 1,
          onDestinationSelected: (_) {},
        ),
      );

      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, equals(1));
    });

    testWidgets('calls onDestinationSelected when destination tapped', (tester) async {
      var selectedIndex = -1;
      await tester.pumpApp(
        AppScaffoldWithNav(
          body: const SizedBox(),
          destinations: testDestinations,
          selectedIndex: 0,
          onDestinationSelected: (index) => selectedIndex = index,
        ),
      );

      await tester.tap(find.text('Search'));
      await tester.pump();

      expect(selectedIndex, equals(1));
    });

    testWidgets('renders floating action button when provided', (tester) async {
      await tester.pumpApp(
        AppScaffoldWithNav(
          body: const SizedBox(),
          destinations: testDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('does not render FAB when not provided', (tester) async {
      await tester.pumpApp(
        AppScaffoldWithNav(
          body: const SizedBox(),
          destinations: testDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('shows correct icons for destinations', (tester) async {
      await tester.pumpApp(
        AppScaffoldWithNav(
          body: const SizedBox(),
          destinations: testDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outlined), findsOneWidget);
    });
  });

  group('NavDestination', () {
    test('stores icon, selectedIcon, and label', () {
      const dest = NavDestination(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: 'Home',
      );

      expect(dest.icon, equals(Icons.home_outlined));
      expect(dest.selectedIcon, equals(Icons.home));
      expect(dest.label, equals('Home'));
    });
  });
}
