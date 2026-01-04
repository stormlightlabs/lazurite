import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/login/presentation/auth_button.dart';

void main() {
  testWidgets('AuthButton displays text and icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthButton(text: 'Test Button', onPressed: () {}),
        ),
      ),
    );

    expect(find.text('Test Button'), findsOneWidget);
    expect(find.byIcon(Icons.login), findsOneWidget);
  });

  testWidgets('AuthButton shows loader when loading', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthButton(text: 'Test Button', onPressed: () {}, isLoading: true),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.login), findsNothing);
  });

  testWidgets('AuthButton callback works', (tester) async {
    bool pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthButton(text: 'Test Button', onPressed: () => pressed = true),
        ),
      ),
    );

    await tester.tap(find.byType(AuthButton));
    expect(pressed, isTrue);
  });
}
