import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/search/bloc/search_bloc.dart';
import 'package:lazurite/features/search/presentation/widgets/search_result_states.dart';

void main() {
  testWidgets('SearchEmptyState renders tab-aware empty copy', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SearchEmptyState(tab: SearchTab.posts)),
      ),
    );

    expect(find.text('Search posts'), findsOneWidget);
    expect(find.textContaining('Find conversations and keywords across posts'), findsOneWidget);
  });

  testWidgets('SearchNoResultsState includes query when provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SearchNoResultsState(tab: SearchTab.actors, query: 'river'),
        ),
      ),
    );

    expect(find.text('No people found'), findsOneWidget);
    expect(find.textContaining('for "river"'), findsOneWidget);
  });
}
