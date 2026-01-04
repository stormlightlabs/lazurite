import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/search/application/search_providers.dart';
import 'package:lazurite/src/features/search/presentation/widgets/recent_search_chips.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('RecentSearchChips', () {
    final testSearches = [
      RecentSearchItem(query: 'flutter', searchedAt: DateTime(2024, 1, 3)),
      RecentSearchItem(query: 'dart', searchedAt: DateTime(2024, 1, 2)),
      RecentSearchItem(query: 'riverpod', searchedAt: DateTime(2024, 1, 1)),
    ];

    testWidgets('renders nothing when searches is empty', (tester) async {
      await tester.pumpApp(const Material(child: RecentSearchChips(searches: [])));

      expect(find.byType(InputChip), findsNothing);
    });

    testWidgets('renders chips for each search', (tester) async {
      await tester.pumpApp(Material(child: RecentSearchChips(searches: testSearches)));

      expect(find.byType(InputChip), findsNWidgets(3));
      expect(find.text('flutter'), findsOneWidget);
      expect(find.text('dart'), findsOneWidget);
      expect(find.text('riverpod'), findsOneWidget);
    });

    testWidgets('invokes onTap when chip is pressed', (tester) async {
      String? tappedQuery;

      await tester.pumpApp(
        Material(
          child: RecentSearchChips(searches: testSearches, onTap: (query) => tappedQuery = query),
        ),
      );

      await tester.tap(find.text('flutter'));
      await tester.pump();

      expect(tappedQuery, 'flutter');
    });

    testWidgets('invokes onDelete when delete button is pressed', (tester) async {
      String? deletedQuery;

      await tester.pumpApp(
        Material(
          child: RecentSearchChips(
            searches: testSearches,
            onDelete: (query) => deletedQuery = query,
          ),
        ),
      );

      final deleteButtons = find.byIcon(Icons.close);
      expect(deleteButtons, findsNWidgets(3));

      await tester.tap(deleteButtons.first);
      await tester.pump();

      expect(deletedQuery, 'flutter');
    });

    testWidgets('renders horizontally in a ListView', (tester) async {
      await tester.pumpApp(Material(child: RecentSearchChips(searches: testSearches)));

      expect(find.byType(ListView), findsOneWidget);
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.scrollDirection, Axis.horizontal);
    });

    testWidgets('hides delete button when onDelete is null', (tester) async {
      await tester.pumpApp(
        Material(child: RecentSearchChips(searches: testSearches, onDelete: null)),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });
  });
}
