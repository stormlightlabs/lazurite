import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/app.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionStorage extends Mock implements SessionStorage {}

void main() {
  late MockSessionStorage mockSessionStorage;

  setUp(() {
    mockSessionStorage = MockSessionStorage();
    when(() => mockSessionStorage.getSession()).thenAnswer(
      (_) async => Session(
        did: 'did:web:test',
        handle: 'handle',
        pdsUrl: 'https://pds',
        accessJwt: 'access',
        refreshJwt: 'refresh',
        scope: 'scope',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        dpopKey: {},
      ),
    );
  });

  group('App', () {
    testWidgets('boots and renders root scaffold', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sessionStorageProvider.overrideWithValue(mockSessionStorage)],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify app boots with bottom navigation
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('displays all 5 navigation destinations', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sessionStorageProvider.overrideWithValue(mockSessionStorage)],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationDestination), findsNWidgets(5));

      expect(
        find.descendant(of: find.byType(NavigationBar), matching: find.text('Home')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(NavigationBar), matching: find.text('Search')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(NavigationBar), matching: find.text('Notifications')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(NavigationBar), matching: find.text('Messages')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(NavigationBar), matching: find.text('Profile')),
        findsOneWidget,
      );
    });

    testWidgets('starts on home screen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sessionStorageProvider.overrideWithValue(mockSessionStorage)],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify home screen content is displayed
      expect(find.text('Home Timeline'), findsOneWidget);
    });

    testWidgets('uses dark theme by default', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sessionStorageProvider.overrideWithValue(mockSessionStorage)],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);
    });
  });
}
