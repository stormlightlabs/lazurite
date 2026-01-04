import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/login/presentation/login_screen.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('renders app bar with Login title', (tester) async {
      await tester.pumpApp(const LoginScreen());
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('renders handle input field', (tester) async {
      await tester.pumpApp(const LoginScreen());
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Handle'), findsOneWidget);
    });

    testWidgets('renders handle hint text', (tester) async {
      await tester.pumpApp(const LoginScreen());
      expect(find.text('yourname.bsky.social'), findsOneWidget);
    });

    testWidgets('renders login button', (tester) async {
      await tester.pumpApp(const LoginScreen());
      expect(find.text('Continue with Bluesky'), findsOneWidget);
    });

    testWidgets('renders cloud icon', (tester) async {
      await tester.pumpApp(const LoginScreen());
      expect(find.byIcon(Icons.cloud_outlined), findsOneWidget);
    });

    testWidgets('renders sign in header text', (tester) async {
      await tester.pumpApp(const LoginScreen());
      expect(find.text('Sign in to Bluesky'), findsOneWidget);
    });

    testWidgets('renders app password hint text', (tester) async {
      await tester.pumpApp(const LoginScreen());
      expect(find.text('You can also use an app password for testing.'), findsOneWidget);
    });

    testWidgets('can enter text in handle field', (tester) async {
      await tester.pumpApp(const LoginScreen());
      await tester.enterText(find.byType(TextField), 'testuser.bsky.social');
      await tester.pump();
      expect(find.text('testuser.bsky.social'), findsOneWidget);
    });

    testWidgets('login button shows loading state when tapped with valid input', (tester) async {
      await tester.pumpApp(const LoginScreen());

      await tester.enterText(find.byType(TextField), 'testuser.bsky.social');
      await tester.pump();

      await tester.tap(find.text('Continue with Bluesky'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('does not trigger login when handle is empty', (tester) async {
      await tester.pumpApp(const LoginScreen());

      await tester.tap(find.text('Continue with Bluesky'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows snackbar after login attempt', (tester) async {
      await tester.pumpApp(const LoginScreen());

      await tester.enterText(find.byType(TextField), 'testuser');
      await tester.pump();

      await tester.tap(find.text('Continue with Bluesky'));

      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Login for @testuser not yet implemented'), findsOneWidget);
    });

    testWidgets('text field has prefix icon', (tester) async {
      await tester.pumpApp(const LoginScreen());
      expect(find.byIcon(Icons.alternate_email), findsOneWidget);
    });

    testWidgets('login button has login icon', (tester) async {
      await tester.pumpApp(const LoginScreen());
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('text field is disabled during loading', (tester) async {
      await tester.pumpApp(const LoginScreen());

      await tester.enterText(find.byType(TextField), 'testuser');
      await tester.pump();
      await tester.tap(find.text('Continue with Bluesky'));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);

      await tester.pump(const Duration(milliseconds: 600));
    });
  });
}
