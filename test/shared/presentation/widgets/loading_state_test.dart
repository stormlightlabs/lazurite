import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/shared/presentation/widgets/loading_state.dart';

void main() {
  Widget buildSubject(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('renders progress indicator', (tester) async {
    await tester.pumpWidget(buildSubject(const LoadingState()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders optional message', (tester) async {
    await tester.pumpWidget(buildSubject(const LoadingState(message: 'Loading items...')));

    expect(find.text('Loading items...'), findsOneWidget);
  });
}
