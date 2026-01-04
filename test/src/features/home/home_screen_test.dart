import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/home/presentation/home_screen.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpApp(const HomeScreen());

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('renders home icon', (tester) async {
      await tester.pumpApp(const HomeScreen());

      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    });

    testWidgets('renders timeline placeholder text', (tester) async {
      await tester.pumpApp(const HomeScreen());

      expect(find.text('Home Timeline'), findsOneWidget);
      expect(find.text('Your timeline will appear here'), findsOneWidget);
    });
  });
}
