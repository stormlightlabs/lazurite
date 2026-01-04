import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/empty_state.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('EmptyState', () {
    testWidgets('displays icon', (tester) async {
      await tester.pumpApp(const EmptyState(icon: Icons.inbox_outlined, title: 'No messages'));
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('displays title', (tester) async {
      await tester.pumpApp(const EmptyState(icon: Icons.inbox_outlined, title: 'No messages'));
      expect(find.text('No messages'), findsOneWidget);
    });

    testWidgets('displays subtitle when provided', (tester) async {
      await tester.pumpApp(
        const EmptyState(
          icon: Icons.inbox_outlined,
          title: 'No messages',
          subtitle: 'Your inbox is empty',
        ),
      );

      expect(find.text('Your inbox is empty'), findsOneWidget);
    });

    testWidgets('does not display subtitle when not provided', (tester) async {
      await tester.pumpApp(const EmptyState(icon: Icons.inbox_outlined, title: 'No messages'));
      expect(find.byType(Text), findsNWidgets(1));
    });

    testWidgets('displays action widget when provided', (tester) async {
      await tester.pumpApp(
        EmptyState(
          icon: Icons.inbox_outlined,
          title: 'No messages',
          action: ElevatedButton(onPressed: () {}, child: const Text('Refresh')),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
    });

    testWidgets('does not display action when not provided', (tester) async {
      await tester.pumpApp(const EmptyState(icon: Icons.inbox_outlined, title: 'No messages'));

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('centers content', (tester) async {
      await tester.pumpApp(const EmptyState(icon: Icons.inbox_outlined, title: 'No messages'));
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('renders with all optional parameters', (tester) async {
      var buttonPressed = false;

      await tester.pumpApp(
        EmptyState(
          icon: Icons.search_off,
          title: 'No results',
          subtitle: 'Try a different search term',
          action: TextButton(
            onPressed: () => buttonPressed = true,
            child: const Text('Clear search'),
          ),
        ),
      );

      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('No results'), findsOneWidget);
      expect(find.text('Try a different search term'), findsOneWidget);
      expect(find.text('Clear search'), findsOneWidget);

      await tester.tap(find.text('Clear search'));
      expect(buttonPressed, isTrue);
    });
  });
}
