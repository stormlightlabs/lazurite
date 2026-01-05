import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/core/widgets/tab_scaffold.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';

import '../../../helpers/pump_app.dart';

Session _testSession() => Session(
  did: 'did:plc:test',
  handle: 'test.bsky.social',
  pdsUrl: 'https://pds.example.com',
  accessJwt: 'access',
  refreshJwt: 'refresh',
  scope: 'atproto',
  expiresAt: DateTime.now().add(const Duration(hours: 1)),
  dpopKey: const {'kty': 'EC', 'crv': 'P-256', 'x': 'x', 'y': 'y'},
);

GoRouter _createTestRouter() {
  return GoRouter(
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
                builder: (_, _) => const Scaffold(body: Center(child: Text('Home Content'))),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (_, _) => const Scaffold(body: Center(child: Text('Search Content'))),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (_, _) =>
                    const Scaffold(body: Center(child: Text('Notifications Content'))),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dms',
                builder: (_, _) => const Scaffold(body: Center(child: Text('DMs Content'))),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const Scaffold(body: Center(child: Text('Profile Content'))),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) => const Scaffold(body: Center(child: Text('Login Screen'))),
      ),
    ],
  );
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(AuthState initialState) : _currentState = initialState;
  AuthState _currentState;

  @override
  AuthState build() => _currentState;

  void updateState(AuthState newState) {
    _currentState = newState;
    // Use state setter from parent Notifier class to trigger rebuild
    state = newState;
  }
}

void main() {
  group('TabScaffold - Authenticated', () {
    testWidgets('renders NavigationBar with 5 destinations when authenticated', (tester) async {
      final router = _createTestRouter();
      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(AuthState.authenticated(_testSession())),
          ),
        ],
      );
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
    });

    testWidgets('switching tabs calls goBranch when authenticated', (tester) async {
      final router = _createTestRouter();
      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(AuthState.authenticated(_testSession())),
          ),
        ],
      );
      expect(find.text('Home Content'), findsOneWidget);
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.text('Search Content'), findsOneWidget);
      await tester.tap(find.text('Messages'));
      await tester.pumpAndSettle();
      expect(find.text('DMs Content'), findsOneWidget);
    });

    testWidgets('shows correct icons for authenticated destinations', (tester) async {
      final router = _createTestRouter();
      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(AuthState.authenticated(_testSession())),
          ),
        ],
      );
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      expect(find.byIcon(Icons.mail_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outlined), findsOneWidget);
    });
  });

  group('TabScaffold - Auth State Transitions', () {
    testWidgets(
      'handles transition from unauthenticated to authenticated without GlobalKey errors',
      (tester) async {
        final router = _createTestRouter();
        final authNotifier = _TestAuthNotifier(const AuthState.unauthenticated());

        await tester.pumpRouterApp(
          router: router,
          overrides: [authProvider.overrideWith(() => authNotifier)],
        );

        // Verify unauthenticated state
        expect(find.byType(NavigationDestination), findsNWidgets(2));
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Login'), findsOneWidget);

        // Transition to authenticated - this should not throw GlobalKey errors
        authNotifier.updateState(AuthState.authenticated(_testSession()));
        await tester.pumpAndSettle();

        // Verify authenticated state
        expect(find.byType(NavigationDestination), findsNWidgets(5));
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Search'), findsOneWidget);
      },
    );

    testWidgets(
      'handles transition from authenticated to unauthenticated without GlobalKey errors',
      (tester) async {
        final router = _createTestRouter();
        final authNotifier = _TestAuthNotifier(AuthState.authenticated(_testSession()));

        await tester.pumpRouterApp(
          router: router,
          overrides: [authProvider.overrideWith(() => authNotifier)],
        );

        // Verify authenticated state
        expect(find.byType(NavigationDestination), findsNWidgets(5));
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Search'), findsOneWidget);

        // Transition to unauthenticated - should not result in GlobalKey errors
        authNotifier.updateState(const AuthState.unauthenticated());
        await tester.pumpAndSettle();

        // Verify unauthenticated state
        expect(find.byType(NavigationDestination), findsNWidgets(2));
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Login'), findsOneWidget);
      },
    );

    testWidgets(
      'resets to Home tab content when transitioning from authenticated to unauthenticated',
      (tester) async {
        final router = _createTestRouter();
        final authNotifier = _TestAuthNotifier(AuthState.authenticated(_testSession()));

        await tester.pumpRouterApp(
          router: router,
          overrides: [authProvider.overrideWith(() => authNotifier)],
        );

        // Switch away from the Home branch while authenticated.
        await tester.tap(find.text('Messages'));
        await tester.pumpAndSettle();
        expect(find.text('DMs Content'), findsOneWidget);

        // Transition to unauthenticated - content should snap back to Home.
        authNotifier.updateState(const AuthState.unauthenticated());
        await tester.pumpAndSettle();

        expect(find.text('DMs Content'), findsNothing);
        expect(find.text('Home Content'), findsOneWidget);
      },
    );
  });

  group('TabScaffold - Unauthenticated', () {
    testWidgets('renders NavigationBar with 2 destinations when unauthenticated', (tester) async {
      final router = _createTestRouter();
      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(() => _TestAuthNotifier(const AuthState.unauthenticated())),
        ],
      );
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(2));
    });

    testWidgets('shows Home and Login tabs when unauthenticated', (tester) async {
      final router = _createTestRouter();
      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(() => _TestAuthNotifier(const AuthState.unauthenticated())),
        ],
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Search'), findsNothing);
      expect(find.text('Notifications'), findsNothing);
      expect(find.text('Messages'), findsNothing);
      expect(find.text('Profile'), findsNothing);
    });

    testWidgets('Login tab navigates to login screen when unauthenticated', (tester) async {
      final router = _createTestRouter();
      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(() => _TestAuthNotifier(const AuthState.unauthenticated())),
        ],
      );
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      expect(find.text('Login Screen'), findsOneWidget);
    });
  });
}
