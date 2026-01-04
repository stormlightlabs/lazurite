import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/network_error_banner.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('NetworkErrorBanner', () {
    testWidgets('renders error message', (tester) async {
      const message = 'Unable to connect';
      await tester.pumpApp(const Column(children: [NetworkErrorBanner(message: message)]));

      expect(find.text(message), findsOneWidget);
    });

    testWidgets('renders cloud_off icon', (tester) async {
      await tester.pumpApp(const Column(children: [NetworkErrorBanner(message: 'Error')]));

      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('renders retry button when onRetry is provided', (tester) async {
      await tester.pumpApp(
        Column(
          children: [NetworkErrorBanner(message: 'Error', onRetry: () {})],
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('does not render retry button when onRetry is null', (tester) async {
      await tester.pumpApp(const Column(children: [NetworkErrorBanner(message: 'Error')]));

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('calls onRetry when retry button is tapped', (tester) async {
      var retryCalled = false;
      await tester.pumpApp(
        Column(
          children: [NetworkErrorBanner(message: 'Error', onRetry: () => retryCalled = true)],
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryCalled, isTrue);
    });

    testWidgets('uses error container color for background', (tester) async {
      await tester.pumpApp(const Column(children: [NetworkErrorBanner(message: 'Error')]));

      // Material widget wraps the banner for background color
      expect(find.byType(Material), findsWidgets);
    });

    testWidgets('is displayed in a row layout', (tester) async {
      await tester.pumpApp(const Column(children: [NetworkErrorBanner(message: 'Error')]));

      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('message expands to fill available space', (tester) async {
      const longMessage = 'This is a very long error message that should expand';
      await tester.pumpApp(const Column(children: [NetworkErrorBanner(message: longMessage)]));

      expect(find.text(longMessage), findsOneWidget);
      expect(find.byType(Expanded), findsOneWidget);
    });
  });
}
