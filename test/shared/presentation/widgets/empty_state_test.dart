import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/shared/presentation/widgets/empty_state.dart';

void main() {
  Widget buildSubject(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('renders message and icon', (tester) async {
    await tester.pumpWidget(buildSubject(const EmptyState(message: 'No items', icon: Icons.search_off_outlined)));

    expect(find.text('No items'), findsOneWidget);
    expect(find.byIcon(Icons.search_off_outlined), findsOneWidget);
  });

  testWidgets('renders subtitle and action', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        EmptyState(
          message: 'No feeds pinned',
          subtitle: 'Add feeds to continue.',
          action: FilledButton(onPressed: () {}, child: const Text('Manage Feeds')),
        ),
      ),
    );

    expect(find.text('No feeds pinned'), findsOneWidget);
    expect(find.text('Add feeds to continue.'), findsOneWidget);
    expect(find.text('Manage Feeds'), findsOneWidget);
  });
}
