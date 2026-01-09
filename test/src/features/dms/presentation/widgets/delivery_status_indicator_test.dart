import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/dms/domain/dm_message.dart';
import 'package:lazurite/src/features/dms/presentation/widgets/delivery_status_indicator.dart';

void main() {
  group('DeliveryStatusIndicator', () {
    testWidgets('shows clock icon for pending status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DeliveryStatusIndicator(status: MessageStatus.pending)),
        ),
      );

      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('shows progress indicator for sending status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DeliveryStatusIndicator(status: MessageStatus.sending)),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows check icon for sent status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DeliveryStatusIndicator(status: MessageStatus.sent)),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows done_all icon for read status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DeliveryStatusIndicator(status: MessageStatus.read)),
        ),
      );

      expect(find.byIcon(Icons.done_all), findsOneWidget);
    });

    testWidgets('shows error icon for failed status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DeliveryStatusIndicator(status: MessageStatus.failed)),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows retry text when onRetry is provided for failed status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryStatusIndicator(status: MessageStatus.failed, onRetry: () {}),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('calls onRetry when tapped on failed status', (tester) async {
      var retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryStatusIndicator(
              status: MessageStatus.failed,
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.error_outline));
      expect(retryCalled, isTrue);
    });

    testWidgets('shows block icon for deleted status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DeliveryStatusIndicator(status: MessageStatus.deleted)),
        ),
      );

      expect(find.byIcon(Icons.block), findsOneWidget);
    });

    testWidgets('uses AnimatedSwitcher for status transitions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DeliveryStatusIndicator(status: MessageStatus.pending)),
        ),
      );

      expect(find.byType(AnimatedSwitcher), findsOneWidget);
    });

    testWidgets('animates between status changes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DeliveryStatusIndicator(status: MessageStatus.pending)),
        ),
      );

      expect(find.byIcon(Icons.access_time), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DeliveryStatusIndicator(status: MessageStatus.sent)),
        ),
      );

      // Pump to trigger animation
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
