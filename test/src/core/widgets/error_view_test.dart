import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('ErrorView', () {
    testWidgets('renders error icon', (tester) async {
      await tester.pumpApp(const ErrorView(title: 'Error'));
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders title', (tester) async {
      const title = 'Something went wrong';
      await tester.pumpApp(const ErrorView(title: title));

      expect(find.text(title), findsOneWidget);
    });

    testWidgets('renders message when provided', (tester) async {
      const title = 'Error';
      const message = 'Please try again later';
      await tester.pumpApp(const ErrorView(title: title, message: message));

      expect(find.text(title), findsOneWidget);
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('does not render message when null', (tester) async {
      await tester.pumpApp(const ErrorView(title: 'Error'));
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('renders retry button when onRetry is provided', (tester) async {
      await tester.pumpApp(ErrorView(title: 'Error', onRetry: () {}));

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('does not render retry button when onRetry is null', (tester) async {
      await tester.pumpApp(const ErrorView(title: 'Error'));
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('calls onRetry when retry button is tapped', (tester) async {
      var retryCalled = false;
      await tester.pumpApp(ErrorView(title: 'Error', onRetry: () => retryCalled = true));

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryCalled, isTrue);
    });

    testWidgets('centers content vertically and horizontally', (tester) async {
      await tester.pumpApp(const ErrorView(title: 'Error'));
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('applies padding to content', (tester) async {
      await tester.pumpApp(const ErrorView(title: 'Error'));
      expect(find.byType(Padding), findsWidgets);
    });
  });
}
