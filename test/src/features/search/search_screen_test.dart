import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/search/presentation/search_screen.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('SearchScreen', () {
    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpApp(const SearchScreen());

      expect(find.text('Search'), findsWidgets);
    });

    testWidgets('renders search icon', (tester) async {
      await tester.pumpApp(const SearchScreen());

      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
    });

    testWidgets('renders search placeholder text', (tester) async {
      await tester.pumpApp(const SearchScreen());

      expect(find.text('Search posts and profiles'), findsOneWidget);
    });
  });
}
