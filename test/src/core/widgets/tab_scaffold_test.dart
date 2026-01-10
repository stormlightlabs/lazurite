import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/core/widgets/tab_scaffold.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/global_compose_fab.dart';
import 'package:lazurite/src/features/notifications/application/unread_count_notifier.dart';
import 'package:lazurite/src/features/notifications/presentation/widgets/unread_badge.dart';

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
    state = newState;
  }
}

class _TestUnreadCountNotifier extends UnreadCountNotifier {
  _TestUnreadCountNotifier(this._stream);

  final Stream<int> _stream;

  @override
  Stream<int> build() => _stream;
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
          unreadCountProvider.overrideWith(() => _TestUnreadCountNotifier(Stream.value(0))),
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
          unreadCountProvider.overrideWith(() => _TestUnreadCountNotifier(Stream.value(0))),
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
          unreadCountProvider.overrideWith(() => _TestUnreadCountNotifier(Stream.value(0))),
        ],
      );
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      expect(find.byIcon(Icons.mail_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outlined), findsOneWidget);
    });

    testWidgets('long press on profile destination shows menu with Drafts and Bookmarks', (
      tester,
    ) async {
      final router = _createTestRouter();
      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(AuthState.authenticated(_testSession())),
          ),
          unreadCountProvider.overrideWith(() => _TestUnreadCountNotifier(Stream.value(0))),
        ],
      );

      await tester.longPress(find.byIcon(Icons.person_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Drafts'), findsOneWidget);
      expect(find.text('Bookmarks'), findsOneWidget);
      expect(find.byIcon(Icons.drafts_outlined), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
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
          overrides: [
            authProvider.overrideWith(() => authNotifier),
            unreadCountProvider.overrideWith(() => _TestUnreadCountNotifier(Stream.value(0))),
          ],
        );

        expect(find.byType(NavigationDestination), findsNWidgets(2));
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Login'), findsOneWidget);

        authNotifier.updateState(AuthState.authenticated(_testSession()));
        await tester.pumpAndSettle();

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
          overrides: [
            authProvider.overrideWith(() => authNotifier),
            unreadCountProvider.overrideWith(() => _TestUnreadCountNotifier(Stream.value(0))),
          ],
        );

        expect(find.byType(NavigationDestination), findsNWidgets(5));
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Search'), findsOneWidget);

        authNotifier.updateState(const AuthState.unauthenticated());
        await tester.pumpAndSettle();

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
          overrides: [
            authProvider.overrideWith(() => authNotifier),
            unreadCountProvider.overrideWith(() => _TestUnreadCountNotifier(Stream.value(0))),
          ],
        );

        await tester.tap(find.text('Messages'));
        await tester.pumpAndSettle();
        expect(find.text('DMs Content'), findsOneWidget);

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

  group('TabScaffold - Global Compose FAB', () {
    testWidgets('shows FAB on home screen when authenticated', (tester) async {
      final router = _createTestRouter();
      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(AuthState.authenticated(_testSession())),
          ),
          unreadCountProvider.overrideWith(() => _TestUnreadCountNotifier(Stream.value(0))),
        ],
      );

      expect(find.byType(GlobalComposeFab), findsOneWidget);
    });

    testWidgets('shows FAB on search screen when authenticated', (tester) async {
      final router = _createTestRouter();
      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(AuthState.authenticated(_testSession())),
          ),
          unreadCountProvider.overrideWith(() => _TestUnreadCountNotifier(Stream.value(0))),
        ],
      );

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(find.byType(GlobalComposeFab), findsOneWidget);
    });

    testWidgets('shows FAB on notifications screen when authenticated', (tester) async {
      final router = _createTestRouter();
      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(AuthState.authenticated(_testSession())),
          ),
          unreadCountProvider.overrideWith(() => _TestUnreadCountNotifier(Stream.value(0))),
        ],
      );

      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      expect(find.byType(GlobalComposeFab), findsOneWidget);
    });

    testWidgets('shows FAB on profile screen when authenticated', (tester) async {
      final router = _createTestRouter();
      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(AuthState.authenticated(_testSession())),
          ),
          unreadCountProvider.overrideWith(() => _TestUnreadCountNotifier(Stream.value(0))),
        ],
      );

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.byType(GlobalComposeFab), findsOneWidget);
    });

    testWidgets('does not show FAB when unauthenticated', (tester) async {
      final router = _createTestRouter();
      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(() => _TestAuthNotifier(const AuthState.unauthenticated())),
        ],
      );

      expect(find.byType(GlobalComposeFab), findsNothing);
    });

    testWidgets('hides FAB when navigating to login', (tester) async {
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
                    builder: (_, _) => const Scaffold(body: Center(child: Text('Home'))),
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

      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(AuthState.authenticated(_testSession())),
          ),
          unreadCountProvider.overrideWith(() => _TestUnreadCountNotifier(Stream.value(0))),
        ],
      );

      expect(find.byType(GlobalComposeFab), findsOneWidget);

      router.go('/login');
      await tester.pumpAndSettle();

      expect(find.byType(GlobalComposeFab), findsNothing);
    });

    testWidgets('FAB persists across tab switches', (tester) async {
      final router = _createTestRouter();
      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(AuthState.authenticated(_testSession())),
          ),
          unreadCountProvider.overrideWith(() => _TestUnreadCountNotifier(Stream.value(0))),
        ],
      );

      expect(find.byType(GlobalComposeFab), findsOneWidget);

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.byType(GlobalComposeFab), findsOneWidget);

      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();
      expect(find.byType(GlobalComposeFab), findsOneWidget);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.byType(GlobalComposeFab), findsOneWidget);
    });
  });

  group('TabScaffold - Unread Badge', () {
    testWidgets('uses UnreadBadge widget for notifications tab', (tester) async {
      final router = _createTestRouter();
      final unreadCountController = StreamController<int>();

      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(AuthState.authenticated(_testSession())),
          ),
          unreadCountProvider.overrideWith(
            () => _TestUnreadCountNotifier(unreadCountController.stream),
          ),
        ],
      );

      unreadCountController.add(5);
      await tester.pumpAndSettle();

      expect(find.byType(UnreadBadge), findsAtLeastNWidgets(1));
      expect(find.text('5'), findsOneWidget);

      await unreadCountController.close();
    });

    testWidgets('shows badge with count on notifications tab when unread count > 0', (
      tester,
    ) async {
      final router = _createTestRouter();
      final unreadCountController = StreamController<int>();

      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(AuthState.authenticated(_testSession())),
          ),
          unreadCountProvider.overrideWith(
            () => _TestUnreadCountNotifier(unreadCountController.stream),
          ),
        ],
      );

      unreadCountController.add(5);
      await tester.pumpAndSettle();

      expect(find.byType(Badge), findsAtLeastNWidgets(1));
      expect(find.text('5'), findsOneWidget);

      await unreadCountController.close();
    });

    testWidgets('hides badge when unread count is 0', (tester) async {
      final router = _createTestRouter();
      final unreadCountController = StreamController<int>();

      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(AuthState.authenticated(_testSession())),
          ),
          unreadCountProvider.overrideWith(
            () => _TestUnreadCountNotifier(unreadCountController.stream),
          ),
        ],
      );

      unreadCountController.add(0);
      await tester.pumpAndSettle();

      final badges = tester.widgetList<Badge>(find.byType(Badge));
      for (final badge in badges) {
        expect(badge.isLabelVisible, false);
      }

      await unreadCountController.close();
    });

    testWidgets('updates badge count reactively', (tester) async {
      final router = _createTestRouter();
      final unreadCountController = StreamController<int>();

      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(AuthState.authenticated(_testSession())),
          ),
          unreadCountProvider.overrideWith(
            () => _TestUnreadCountNotifier(unreadCountController.stream),
          ),
        ],
      );

      unreadCountController.add(3);
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);

      unreadCountController.add(10);
      await tester.pumpAndSettle();
      expect(find.text('10'), findsOneWidget);
      expect(find.text('3'), findsNothing);

      unreadCountController.add(0);
      await tester.pumpAndSettle();
      final badges = tester.widgetList<Badge>(find.byType(Badge));
      for (final badge in badges) {
        expect(badge.isLabelVisible, false);
      }

      await unreadCountController.close();
    });

    testWidgets('badge appears on both selected and unselected notification icons', (
      tester,
    ) async {
      final router = _createTestRouter();
      final unreadCountController = StreamController<int>();

      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(AuthState.authenticated(_testSession())),
          ),
          unreadCountProvider.overrideWith(
            () => _TestUnreadCountNotifier(unreadCountController.stream),
          ),
        ],
      );

      unreadCountController.add(7);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      expect(find.byType(Badge), findsAtLeastNWidgets(1));
      expect(find.text('7'), findsOneWidget);

      await unreadCountController.close();
    });

    testWidgets('no badge shown when unauthenticated', (tester) async {
      final router = _createTestRouter();
      final unreadCountController = StreamController<int>();

      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(() => _TestAuthNotifier(const AuthState.unauthenticated())),
          unreadCountProvider.overrideWith(
            () => _TestUnreadCountNotifier(unreadCountController.stream),
          ),
        ],
      );

      unreadCountController.add(5);
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsNothing);
      expect(find.byType(Badge), findsNothing);

      await unreadCountController.close();
    });

    testWidgets('displays "99+" for counts greater than 99', (tester) async {
      final router = _createTestRouter();
      final unreadCountController = StreamController<int>();

      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(AuthState.authenticated(_testSession())),
          ),
          unreadCountProvider.overrideWith(
            () => _TestUnreadCountNotifier(unreadCountController.stream),
          ),
        ],
      );

      unreadCountController.add(150);
      await tester.pumpAndSettle();

      expect(find.text('99+'), findsOneWidget);
      expect(find.text('150'), findsNothing);

      await unreadCountController.close();
    });

    testWidgets('displays exact count for 99 notifications', (tester) async {
      final router = _createTestRouter();
      final unreadCountController = StreamController<int>();

      await tester.pumpRouterApp(
        router: router,
        overrides: [
          authProvider.overrideWith(
            () => _TestAuthNotifier(AuthState.authenticated(_testSession())),
          ),
          unreadCountProvider.overrideWith(
            () => _TestUnreadCountNotifier(unreadCountController.stream),
          ),
        ],
      );

      unreadCountController.add(99);
      await tester.pumpAndSettle();

      expect(find.text('99'), findsOneWidget);
      expect(find.text('99+'), findsNothing);

      await unreadCountController.close();
    });
  });
}
