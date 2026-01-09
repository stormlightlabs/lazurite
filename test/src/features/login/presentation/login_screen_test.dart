import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/login/presentation/login_screen.dart';
import 'package:lazurite/src/infrastructure/auth/handle_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSessionStorage mockSessionStorage;
  late MockHandleStorage mockHandleStorage;

  final testSession = Session(
    did: 'did:plc:test',
    handle: 'test.bsky.social',
    pdsUrl: 'https://test.pds.com',
    accessJwt: 'access',
    refreshJwt: 'refresh',
    scope: 'atproto',
    expiresAt: DateTime.now().add(const Duration(hours: 2)),
    dpopKey: {},
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSessionStorage = MockSessionStorage();
    mockHandleStorage = MockHandleStorage();

    when(() => mockAuthRepository.login(any())).thenAnswer((_) async => testSession);
    when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);
    when(() => mockHandleStorage.getLastHandle()).thenReturn(null);
    when(() => mockHandleStorage.saveHandle(any())).thenAnswer((_) async {});
  });

  List<Override> testOverrides() => [
    authRepositoryProvider.overrideWithValue(mockAuthRepository),
    sessionStorageProvider.overrideWithValue(mockSessionStorage),
    handleStorageProvider.overrideWith((ref) => Future.value(mockHandleStorage)),
  ];

  group('LoginScreen', () {
    testWidgets('renders app bar with Login title', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: testOverrides());
      await tester.pumpAndSettle();
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('renders handle input field', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: testOverrides());
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Handle'), findsOneWidget);
    });

    testWidgets('renders handle hint text', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: testOverrides());
      await tester.pumpAndSettle();
      expect(find.text('yourname.bsky.social'), findsOneWidget);
    });

    testWidgets('renders login button', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: testOverrides());
      await tester.pumpAndSettle();
      expect(find.text('Continue with Bluesky'), findsOneWidget);
    });

    testWidgets('renders app logo', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: testOverrides());
      await tester.pumpAndSettle();
      // SvgPicture renders the logo from assets/logo.svg
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('renders sign in header text', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: testOverrides());
      await tester.pumpAndSettle();
      expect(find.text('Sign in to Bluesky'), findsOneWidget);
    });

    testWidgets('renders app password login button', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: testOverrides());
      await tester.pumpAndSettle();
      expect(find.text('Use App Password (Dev)'), findsOneWidget);
    });

    testWidgets('can enter text in handle field', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: testOverrides());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'testuser.bsky.social');
      await tester.pump();
      expect(find.text('testuser.bsky.social'), findsOneWidget);
    });

    testWidgets('login button triggers authentication when tapped with valid input', (
      tester,
    ) async {
      await tester.pumpApp(const LoginScreen(), overrides: testOverrides());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'testuser.bsky.social');
      await tester.pump();

      await tester.tap(find.text('Continue with Bluesky'));
      await tester.pumpAndSettle();

      verify(() => mockAuthRepository.login('testuser.bsky.social')).called(1);
    });

    testWidgets('does not trigger login when handle is empty', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: testOverrides());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Bluesky'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows snackbar after login attempt failure', (tester) async {
      const error = 'Something went wrong';
      when(() => mockAuthRepository.login(any())).thenThrow(error);

      await tester.pumpApp(const LoginScreen(), overrides: testOverrides());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'testuser');
      await tester.pump();

      await tester.tap(find.text('Continue with Bluesky'));

      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Login failed: $error'), findsOneWidget);
    });

    testWidgets('text field has prefix icon', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: testOverrides());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.alternate_email), findsOneWidget);
    });

    testWidgets('login button has login icon', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: testOverrides());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('triggers login with entered handle', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: testOverrides());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'testuser');
      await tester.pump();
      await tester.tap(find.text('Continue with Bluesky'));
      await tester.pumpAndSettle();

      verify(() => mockAuthRepository.login('testuser')).called(1);
    });
  });
}
