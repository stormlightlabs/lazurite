import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/theme.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/developer_tools/presentation/screens/dev_tools_home_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/mocks.dart';

void main() {
  late MockSession session;
  setUp(() {
    session = MockSession();

    when(() => session.did).thenReturn('did:web:test');
    when(() => session.pdsUrl).thenReturn('https://pds.example.com');
  });

  group('DevToolsHomePage', () {
    testWidgets('renders correctly with authenticated user', (tester) async {
      final authState = AuthState.authenticated(session);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWith(() => _TestAuthNotifier(authState))],
          child: MaterialApp(home: const DevToolsHomePage(), theme: AppTheme.dark),
        ),
      );

      expect(find.text('Developer Tools'), findsOneWidget);

      expect(find.text('My DID'), findsOneWidget);
      expect(find.text('did:web:test'), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);

      expect(find.text('PDS Host'), findsOneWidget);
      expect(find.text('https://pds.example.com'), findsOneWidget);

      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Browse My Repository'), findsOneWidget);
      expect(find.text('Explore collections and records'), findsOneWidget);
    });

    testWidgets('copies DID to clipboard', (tester) async {
      final authState = AuthState.authenticated(session);
      final log = <MethodCall>[];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWith(() => _TestAuthNotifier(authState))],
          child: MaterialApp(home: const DevToolsHomePage(), theme: AppTheme.dark),
        ),
      );

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pumpAndSettle();

      final clipboardCalls = log.where((c) => c.method == 'Clipboard.setData');
      expect(clipboardCalls, hasLength(1));
      expect(clipboardCalls.first.arguments['text'], 'did:web:test');

      expect(find.text('DID copied to clipboard'), findsOneWidget);
    });

    testWidgets('handles unauthenticated state gracefully', (tester) async {
      const authState = AuthState.unauthenticated();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWith(() => _TestAuthNotifier(authState))],
          child: MaterialApp(home: const DevToolsHomePage(), theme: AppTheme.dark),
        ),
      );

      expect(find.text('My DID'), findsOneWidget);
      expect(find.text('Not authenticated'), findsOneWidget);
      expect(find.text('PDS Host'), findsOneWidget);
      expect(find.text('Unknown'), findsOneWidget);
    });
  });
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(this._initialState);

  final AuthState _initialState;

  @override
  AuthState build() => _initialState;
}
