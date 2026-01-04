import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/login/presentation/login_screen.dart';
import 'package:lazurite/src/infrastructure/auth/auth_repository.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionStorage extends Mock implements SessionStorage {}

void main() {
  late MockAuthRepository mockAuthRepository;

  late MockSessionStorage mockSessionStorage;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSessionStorage = MockSessionStorage();
    when(() => mockAuthRepository.login(any())).thenAnswer((_) async {});

    when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);
  });

  group('LoginScreen', () {
    testWidgets('renders app bar with Login title', (tester) async {
      await tester.pumpApp(
        const LoginScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          sessionStorageProvider.overrideWithValue(mockSessionStorage),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('renders handle input field', (tester) async {
      await tester.pumpApp(
        const LoginScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          sessionStorageProvider.overrideWithValue(mockSessionStorage),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Handle'), findsOneWidget);
    });

    testWidgets('renders handle hint text', (tester) async {
      await tester.pumpApp(
        const LoginScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          sessionStorageProvider.overrideWithValue(mockSessionStorage),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.text('yourname.bsky.social'), findsOneWidget);
    });

    testWidgets('renders login button', (tester) async {
      await tester.pumpApp(
        const LoginScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          sessionStorageProvider.overrideWithValue(mockSessionStorage),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.text('Continue with Bluesky'), findsOneWidget);
    });

    testWidgets('renders cloud icon', (tester) async {
      await tester.pumpApp(
        const LoginScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          sessionStorageProvider.overrideWithValue(mockSessionStorage),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.cloud_outlined), findsOneWidget);
    });

    testWidgets('renders sign in header text', (tester) async {
      await tester.pumpApp(
        const LoginScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          sessionStorageProvider.overrideWithValue(mockSessionStorage),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.text('Sign in to Bluesky'), findsOneWidget);
    });

    testWidgets('renders app password hint text', (tester) async {
      await tester.pumpApp(
        const LoginScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          sessionStorageProvider.overrideWithValue(mockSessionStorage),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.text('You can also use an app password for testing.'), findsOneWidget);
    });

    testWidgets('can enter text in handle field', (tester) async {
      await tester.pumpApp(
        const LoginScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          sessionStorageProvider.overrideWithValue(mockSessionStorage),
        ],
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'testuser.bsky.social');
      await tester.pump();
      expect(find.text('testuser.bsky.social'), findsOneWidget);
    });

    testWidgets('login button shows loading state when tapped with valid input', (tester) async {
      await tester.pumpApp(
        const LoginScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          sessionStorageProvider.overrideWithValue(mockSessionStorage),
        ],
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'testuser.bsky.social');
      await tester.pump();

      await tester.tap(find.text('Continue with Bluesky'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not trigger login when handle is empty', (tester) async {
      await tester.pumpApp(
        const LoginScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          sessionStorageProvider.overrideWithValue(mockSessionStorage),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Bluesky'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows snackbar after login attempt failure', (tester) async {
      const error = 'Something went wrong';
      when(() => mockAuthRepository.login(any())).thenThrow(error);

      await tester.pumpApp(
        const LoginScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          sessionStorageProvider.overrideWithValue(mockSessionStorage),
        ],
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'testuser');
      await tester.pump();

      await tester.tap(find.text('Continue with Bluesky'));

      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Login failed: $error'), findsOneWidget);
    });

    testWidgets('text field has prefix icon', (tester) async {
      await tester.pumpApp(
        const LoginScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          sessionStorageProvider.overrideWithValue(mockSessionStorage),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.alternate_email), findsOneWidget);
    });

    testWidgets('login button has login icon', (tester) async {
      await tester.pumpApp(
        const LoginScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          sessionStorageProvider.overrideWithValue(mockSessionStorage),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('replaces form with progress view during loading', (tester) async {
      await tester.pumpApp(
        const LoginScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          sessionStorageProvider.overrideWithValue(mockSessionStorage),
        ],
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'testuser');
      await tester.pump();
      await tester.tap(find.text('Continue with Bluesky'));
      await tester.pump();

      final textField = find.byType(TextField);
      expect(textField, findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 600));
    });
  });
}
