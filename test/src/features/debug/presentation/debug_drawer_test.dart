import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/debug/application/system_info_provider.dart';
import 'package:lazurite/src/features/debug/presentation/debug_drawer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

void main() {
  group('DebugDrawer', () {
    Widget createSubject({List<Override> overrides = const []}) {
      return ProviderScope(
        overrides: [
          systemInfoProvider.overrideWith(
            (ref) => Future.value(
              const SystemInfo(
                flutterVersion: '3.0.0',
                buildMode: 'Debug',
                platform: 'TestOS',
                osVersion: '1.0',
                screenSize: Size(1000, 2000),
                pixelRatio: 1.0,
                safeAreaInsets: EdgeInsets.zero,
                appVersion: '1.0.0',
                buildNumber: '1',
                memoryUsage: 1024 * 1024 * 50,
                currentFps: 60.0,
              ),
            ),
          ),
          ...overrides,
        ],
        child: const MaterialApp(
          home: Scaffold(body: SizedBox(width: 320, height: 600, child: DebugDrawer())),
        ),
      );
    }

    testWidgets('displays header with title and close button', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pump();

      expect(find.text('Debug Overlay'), findsOneWidget);
      expect(find.byIcon(Icons.bug_report), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('displays tab bar with System and Session tabs', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pump();

      expect(find.text('System'), findsOneWidget);
      expect(find.text('Session'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
    });

    testWidgets('can switch to Session tab', (tester) async {
      await tester.pumpWidget(
        createSubject(
          overrides: [
            authProvider.overrideWith(() => _TestAuthNotifier(const AuthState.unauthenticated())),
          ],
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Session'));
      await tester.pumpAndSettle();

      expect(find.text('Not authenticated'), findsOneWidget);
    });

    group('ATProto Session Tab', () {
      testWidgets('shows unauthenticated state when not logged in', (tester) async {
        await tester.pumpWidget(
          createSubject(
            overrides: [
              authProvider.overrideWith(
                () => _TestAuthNotifier(const AuthState.unauthenticated()),
              ),
            ],
          ),
        );
        await tester.pump();

        await tester.tap(find.text('Session'));
        await tester.pumpAndSettle();

        expect(find.text('Not authenticated'), findsOneWidget);
        expect(find.text('Sign in to view session details.'), findsOneWidget);
      });

      testWidgets('shows session details when authenticated', (tester) async {
        final testSession = Session(
          did: 'did:plc:test123',
          handle: 'testuser.bsky.social',
          pdsUrl: 'https://morel.us-east.host.bsky.network',
          accessJwt: 'secret',
          refreshJwt: 'secret',
          scope: 'scope',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          dpopKey: const <String, dynamic>{},
        );

        await tester.pumpWidget(
          createSubject(
            overrides: [
              authProvider.overrideWith(
                () => _TestAuthNotifier(AuthState.authenticated(testSession)),
              ),
            ],
          ),
        );
        await tester.pump();

        await tester.tap(find.text('Session'));
        await tester.pumpAndSettle();

        expect(find.text('Authenticated'), findsOneWidget);
        expect(find.text('Session Details'), findsOneWidget);
        expect(find.text('DID'), findsOneWidget);
        expect(find.text('did:plc:test123'), findsOneWidget);
        expect(find.text('Handle'), findsOneWidget);
        expect(find.text('testuser.bsky.social'), findsOneWidget);
        expect(find.text('PDS Host'), findsOneWidget);
        expect(find.text('https://morel.us-east.host.bsky.network'), findsOneWidget);
      });

      testWidgets('never displays auth tokens', (tester) async {
        final testSession = Session(
          did: 'did:plc:test123',
          handle: 'testuser.bsky.social',
          pdsUrl: 'https://morel.us-east.host.bsky.network',
          accessJwt: 'super_secret_access_token',
          refreshJwt: 'super_secret_refresh_token',
          scope: 'scope',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          dpopKey: const <String, dynamic>{},
        );

        await tester.pumpWidget(
          createSubject(
            overrides: [
              authProvider.overrideWith(
                () => _TestAuthNotifier(AuthState.authenticated(testSession)),
              ),
            ],
          ),
        );
        await tester.pump();

        await tester.tap(find.text('Session'));
        await tester.pumpAndSettle();

        expect(find.text('super_secret_access_token'), findsNothing);
        expect(find.text('super_secret_refresh_token'), findsNothing);
        expect(find.textContaining('accessJwt'), findsNothing);
        expect(find.textContaining('refreshJwt'), findsNothing);
        expect(
          find.text('Tokens and keys are stored securely and never displayed.'),
          findsOneWidget,
        );
      });
    });

    group('System Info Tab', () {
      testWidgets('displays build section', (tester) async {
        await tester.pumpWidget(createSubject());
        await tester.pump();

        expect(find.text('Build'), findsOneWidget);
        expect(find.text('Flutter Version'), findsOneWidget);
        expect(find.text('Build Mode'), findsOneWidget);
        expect(find.text('Debug'), findsOneWidget);
      });

      testWidgets('displays platform section header', (tester) async {
        await tester.pumpWidget(createSubject());
        await tester.pump();
        expect(find.text('Platform'), findsWidgets);
        expect(find.text('OS Version'), findsOneWidget);
      });

      testWidgets('displays display section', (tester) async {
        await tester.pumpWidget(createSubject());
        await tester.pump();

        expect(find.text('Display'), findsOneWidget);
        expect(find.text('Screen Size'), findsOneWidget);
        expect(find.text('Pixel Ratio'), findsOneWidget);
        expect(find.text('Safe Area'), findsOneWidget);
      });

      testWidgets('displays performance section', (tester) async {
        await tester.pumpWidget(createSubject());
        await tester.pump();

        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pump();

        expect(find.text('Performance'), findsOneWidget);
        expect(find.text('Memory (RSS)'), findsOneWidget);
        expect(find.text('FPS'), findsOneWidget);
      });
    });

    testWidgets('displays Open Full DevTools button', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pump();

      expect(find.text('Open Full DevTools'), findsOneWidget);
      expect(find.byIcon(Icons.developer_mode), findsOneWidget);
    });
  });
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(this._state);

  final AuthState _state;

  @override
  AuthState build() => _state;
}
