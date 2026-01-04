import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/widgets/tab_scaffold.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('TabScaffold', () {
    testWidgets('renders NavigationBar with 5 destinations', (tester) async {
      // Create a minimal router for testing
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, shell) {
              return TabScaffold(navigationShell: shell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (_, __) =>
                        const Scaffold(body: Center(child: Text('Home'))),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/search',
                    builder: (_, __) =>
                        const Scaffold(body: Center(child: Text('Search'))),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/notifications',
                    builder: (_, __) => const Scaffold(
                      body: Center(child: Text('Notifications')),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/dms',
                    builder: (_, __) =>
                        const Scaffold(body: Center(child: Text('DMs'))),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/profile',
                    builder: (_, __) =>
                        const Scaffold(body: Center(child: Text('Profile'))),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpRouterApp(router: router);

      // Verify NavigationBar is present
      expect(find.byType(NavigationBar), findsOneWidget);

      // Verify all 5 destinations are present
      expect(find.byType(NavigationDestination), findsNWidgets(5));
    });

    testWidgets('switching tabs calls goBranch', (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, shell) {
              return TabScaffold(navigationShell: shell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (_, __) => const Scaffold(
                      body: Center(child: Text('Home Content')),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/search',
                    builder: (_, __) => const Scaffold(
                      body: Center(child: Text('Search Content')),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/notifications',
                    builder: (_, __) => const Scaffold(
                      body: Center(child: Text('Notifications Content')),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/dms',
                    builder: (_, __) => const Scaffold(
                      body: Center(child: Text('DMs Content')),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/profile',
                    builder: (_, __) => const Scaffold(
                      body: Center(child: Text('Profile Content')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpRouterApp(router: router);

      // Initial state - Home
      expect(find.text('Home Content'), findsOneWidget);

      // Tap Search tab
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.text('Search Content'), findsOneWidget);

      // Tap Messages tab
      await tester.tap(find.text('Messages'));
      await tester.pumpAndSettle();
      expect(find.text('DMs Content'), findsOneWidget);
    });

    testWidgets('shows correct icons for navigation destinations', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, shell) {
              return TabScaffold(navigationShell: shell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/search',
                    builder: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/notifications',
                    builder: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/dms',
                    builder: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/profile',
                    builder: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpRouterApp(router: router);

      // Verify icons are present (home is selected, so it shows filled icon)
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      expect(find.byIcon(Icons.mail_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outlined), findsOneWidget);
    });
  });
}
