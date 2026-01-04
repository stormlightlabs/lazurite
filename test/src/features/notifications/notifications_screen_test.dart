import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/notifications/presentation/notifications_screen.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('NotificationsScreen', () {
    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpApp(const NotificationsScreen());

      expect(find.text('Notifications'), findsWidgets);
    });

    testWidgets('renders notifications icon', (tester) async {
      await tester.pumpApp(const NotificationsScreen());

      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('renders notifications placeholder text', (tester) async {
      await tester.pumpApp(const NotificationsScreen());

      expect(find.text('Your notifications will appear here'), findsOneWidget);
    });
  });
}
