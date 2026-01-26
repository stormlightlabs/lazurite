import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/scheduling/presentation/widgets/schedule_picker_sheet.dart';

void main() {
  group('SchedulePickerSheet', () {
    testWidgets('displays initial scheduled date and time', (WidgetTester tester) async {
      final initialDate = DateTime(2030, 1, 26, 10, 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SchedulePickerSheet(initialScheduledAt: initialDate)),
        ),
      );

      expect(find.textContaining('Jan 26, 2030'), findsNWidgets(2));
      expect(find.textContaining('10:00'), findsNWidgets(2));
    });

    testWidgets('defaults to 1 hour from now when no initial date', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SchedulePickerSheet())));
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('shows confirm button only when valid future date selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SchedulePickerSheet(
              initialScheduledAt: DateTime.now().add(const Duration(hours: 1)),
            ),
          ),
        ),
      );

      final scheduleButton = find.widgetWithText(TextButton, 'Schedule');
      expect(scheduleButton, findsOneWidget);

      final button = tester.widget<TextButton>(scheduleButton);
      expect(button.style?.foregroundColor, isNull);
    });

    testWidgets('disables confirm button for past dates', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SchedulePickerSheet(
              initialScheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Scheduled time must be in the future'), findsOneWidget);
    });

    testWidgets('shows preview of scheduled time', (WidgetTester tester) async {
      final initialDate = DateTime(2030, 2, 14, 15, 30);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SchedulePickerSheet(initialScheduledAt: initialDate)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Feb 14, 2030'), findsNWidgets(2));
      expect(find.textContaining('3:30'), findsNWidgets(2));
    });

    testWidgets('shows time remaining message', (WidgetTester tester) async {
      final futureDate = DateTime.now().add(const Duration(days: 2, hours: 5));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SchedulePickerSheet(initialScheduledAt: futureDate)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('in'), findsOneWidget);
    });

    testWidgets('tapping date card opens date picker', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SchedulePickerSheet())));

      await tester.pumpAndSettle();

      final dateRow = find.widgetWithText(ListTile, 'Date');
      expect(dateRow, findsOneWidget);

      await tester.tap(dateRow);
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('tapping time card opens time picker', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SchedulePickerSheet())));

      await tester.pumpAndSettle();

      final timeRow = find.widgetWithText(ListTile, 'Time');
      expect(timeRow, findsOneWidget);

      await tester.tap(timeRow);
      await tester.pumpAndSettle();

      expect(find.byType(TimePickerDialog), findsOneWidget);
    });

    testWidgets('confirms and returns selected date', (WidgetTester tester) async {
      final selectedDate = DateTime(2030, 6, 15, 14, 30);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SchedulePickerSheet(initialScheduledAt: selectedDate)),
        ),
      );

      await tester.pumpAndSettle();

      final scheduleButton = find.text('Schedule');
      await tester.tap(scheduleButton);
      await tester.pumpAndSettle();
      expect(find.byType(SchedulePickerSheet), findsNothing);
    });
  });

  group('SchedulePickerSheet - formatting', () {
    testWidgets('formats single day remaining correctly', (WidgetTester tester) async {
      final tomorrow = DateTime.now().add(const Duration(days: 1, minutes: 5));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SchedulePickerSheet(initialScheduledAt: tomorrow)),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('in 1 day'), findsOneWidget);
    });

    testWidgets('formats hours remaining correctly', (WidgetTester tester) async {
      final inThreeHours = DateTime.now().add(const Duration(hours: 3, minutes: 5));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SchedulePickerSheet(initialScheduledAt: inThreeHours)),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('in 3 hours'), findsOneWidget);
    });

    testWidgets('formats minutes remaining correctly', (WidgetTester tester) async {
      final inThirtyMinutes = DateTime.now().add(const Duration(minutes: 30));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SchedulePickerSheet(initialScheduledAt: inThirtyMinutes)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('minutes'), findsOneWidget);
      final minutesText = tester.widget<Text>(find.textContaining('minutes')).data!;
      expect(
        minutesText == 'in 30 minutes' || minutesText == 'in 29 minutes',
        isTrue,
        reason: 'Expected 29 or 30 minutes, got: $minutesText',
      );
    });
  });
}
