import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/dms/presentation/dms_screen.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('DmsScreen', () {
    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpApp(const DmsScreen());

      expect(find.text('Messages'), findsOneWidget);
    });

    testWidgets('renders mail icon', (tester) async {
      await tester.pumpApp(const DmsScreen());

      expect(find.byIcon(Icons.mail_outlined), findsOneWidget);
    });

    testWidgets('renders DMs placeholder text', (tester) async {
      await tester.pumpApp(const DmsScreen());

      expect(find.text('Direct Messages'), findsOneWidget);
      expect(find.text('Your conversations will appear here'), findsOneWidget);
    });
  });
}
