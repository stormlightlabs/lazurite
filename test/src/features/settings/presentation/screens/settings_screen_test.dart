import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

void main() {
  Session createMockSession() {
    return Session(
      did: 'did:plc:test123',
      handle: 'test.bsky.social',
      accessJwt: 'mock_access_token',
      refreshJwt: 'mock_refresh_token',
      pdsUrl: 'https://pds.example.com',
      scope: 'atproto transition:generic',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      dpopKey: const {},
    );
  }

  Widget buildTestApp(List<Override> overrides) {
    return ProviderScope(
      overrides: overrides,
      child: Builder(
        builder: (context) {
          final router = GoRouter(
            initialLocation: '/settings',
            routes: [
              GoRoute(
                path: '/',
                builder: (ctx, state) => const Scaffold(body: Center(child: Text('Home'))),
              ),
              GoRoute(path: '/settings', builder: (ctx, state) => const SettingsScreen()),
              GoRoute(
                path: '/feeds/manage',
                builder: (ctx, state) =>
                    const Scaffold(body: Center(child: Text('Feed Management'))),
              ),
            ],
          );
          return MaterialApp.router(routerConfig: router);
        },
      ),
    );
  }

  group('SettingsScreen', () {
    testWidgets('shows all sections when authenticated', (tester) async {
      final mockSession = createMockSession();

      await tester.pumpWidget(
        buildTestApp([authProvider.overrideWith(() => _TestAuthNotifier(mockSession))]),
      );

      await tester.pumpAndSettle();

      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(find.text('APP'), findsOneWidget);
      expect(find.text('Content Moderation'), findsOneWidget);
      expect(find.text('Feed Preferences'), findsOneWidget);
      expect(find.text('Muted Words'), findsOneWidget);
      expect(find.text('Saved Feeds'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('ACCOUNT MANAGEMENT'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('hides account sections when unauthenticated', (tester) async {
      await tester.pumpWidget(
        buildTestApp([authProvider.overrideWith(() => _TestAuthNotifier.unauthenticated())]),
      );

      await tester.pumpAndSettle();

      expect(find.text('ACCOUNT'), findsNothing);
      expect(find.text('ACCOUNT MANAGEMENT'), findsNothing);
      expect(find.text('Sign Out'), findsNothing);
      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(find.text('APP'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('shows coming soon snackbar for unimplemented features', (tester) async {
      final mockSession = createMockSession();

      await tester.pumpWidget(
        buildTestApp([authProvider.overrideWith(() => _TestAuthNotifier(mockSession))]),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Content Moderation'));
      await tester.pumpAndSettle();

      expect(find.text('Content Moderation - Coming soon'), findsOneWidget);
    });

    testWidgets('shows sign out confirmation dialog', (tester) async {
      var logoutCalled = false;
      final mockSession = createMockSession();

      await tester.pumpWidget(
        buildTestApp([
          authProvider.overrideWith(
            () => _TestAuthNotifier(mockSession, onLogout: () => logoutCalled = true),
          ),
        ]),
      );

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();
      expect(find.text('Are you sure you want to sign out?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(logoutCalled, isFalse);
    });

    testWidgets('calls logout when confirmed in dialog', (tester) async {
      var logoutCalled = false;
      final mockSession = createMockSession();

      await tester.pumpWidget(
        buildTestApp([
          authProvider.overrideWith(
            () => _TestAuthNotifier(mockSession, onLogout: () => logoutCalled = true),
          ),
        ]),
      );

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      final signOutButtons = find.text('Sign Out');
      await tester.tap(signOutButtons.last);
      await tester.pumpAndSettle();

      expect(logoutCalled, isTrue);
    });
  });
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(this._session, {this.onLogout});

  _TestAuthNotifier.unauthenticated() : _session = null, onLogout = null;

  final Session? _session;
  final VoidCallback? onLogout;

  @override
  AuthState build() {
    final session = _session;
    if (session != null) {
      return AuthState.authenticated(session);
    }
    return const AuthState.unauthenticated();
  }

  @override
  Future<void> logout() async {
    onLogout?.call();
    state = const AuthState.unauthenticated();
  }
}
