import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/domain/content_label.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/content_warning.dart';

import '../../../../../../helpers/pump_app.dart';

void main() {
  group('ContentWarning', () {
    testWidgets('shows child directly when no labels provided', (tester) async {
      await tester.pumpApp(
        const Material(
          child: ContentWarning(labels: [], child: Text('Post content')),
        ),
      );

      expect(find.text('Post content'), findsOneWidget);
      expect(find.text('Show content'), findsNothing);
    });

    testWidgets('shows child directly for informational labels', (tester) async {
      final labels = [
        ContentLabel(src: 'did:plc:test', uri: 'at://...', val: 'spam', cts: DateTime(2024)),
      ];

      await tester.pumpApp(
        Material(
          child: ContentWarning(labels: labels, child: const Text('Post content')),
        ),
      );

      expect(find.text('Post content'), findsOneWidget);
      expect(find.text('Show content'), findsNothing);
      expect(find.text('spam'), findsOneWidget);
    });

    testWidgets('shows warning overlay for warn labels', (tester) async {
      final labels = [
        ContentLabel(src: 'did:plc:test', uri: 'at://...', val: '!warn', cts: DateTime(2024)),
      ];

      await tester.pumpApp(
        Material(
          child: ContentWarning(labels: labels, child: const Text('Sensitive content')),
        ),
      );

      expect(find.text('Content warning: warn'), findsOneWidget);
      expect(find.text('Show content'), findsOneWidget);
    });

    testWidgets('shows warning overlay for porn label', (tester) async {
      final labels = [
        ContentLabel(src: 'did:plc:test', uri: 'at://...', val: 'porn', cts: DateTime(2024)),
      ];

      await tester.pumpApp(
        Material(
          child: ContentWarning(labels: labels, child: const Text('Adult content')),
        ),
      );

      expect(find.text('Content warning: porn'), findsOneWidget);
      expect(find.text('Show content'), findsOneWidget);
    });

    testWidgets('tap to reveal shows content', (tester) async {
      final labels = [
        ContentLabel(src: 'did:plc:test', uri: 'at://...', val: '!warn', cts: DateTime(2024)),
      ];

      await tester.pumpApp(
        Material(
          child: ContentWarning(labels: labels, child: const Text('Hidden content')),
        ),
      );

      await tester.tap(find.text('Show content'));
      await tester.pumpAndSettle();

      expect(find.text('Hidden content'), findsOneWidget);
      expect(find.text('warn'), findsOneWidget);
    });

    testWidgets('hides content with no reveal for hide labels', (tester) async {
      final labels = [
        ContentLabel(src: 'did:plc:test', uri: 'at://...', val: '!hide', cts: DateTime(2024)),
      ];

      await tester.pumpApp(
        Material(
          child: ContentWarning(labels: labels, child: const Text('Takedown content')),
        ),
      );

      expect(find.text('Content hidden'), findsOneWidget);
      expect(find.text('This content cannot be shown'), findsOneWidget);
      expect(find.text('Show content'), findsNothing);
    });

    testWidgets('respects negation labels', (tester) async {
      final labels = [
        ContentLabel(
          src: 'did:plc:test',
          uri: 'at://...',
          val: '!warn',
          cts: DateTime(2024),
          neg: true,
        ),
      ];

      await tester.pumpApp(
        Material(
          child: ContentWarning(labels: labels, child: const Text('Post content')),
        ),
      );

      expect(find.text('Post content'), findsOneWidget);
      expect(find.text('Show content'), findsNothing);
    });

    testWidgets('shows multiple label types', (tester) async {
      final labels = [
        ContentLabel(src: 'did:plc:test', uri: 'at://...', val: 'porn', cts: DateTime(2024)),
        ContentLabel(src: 'did:plc:test', uri: 'at://...', val: 'gore', cts: DateTime(2024)),
      ];

      await tester.pumpApp(
        Material(
          child: ContentWarning(labels: labels, child: const Text('Content')),
        ),
      );

      expect(find.textContaining('porn'), findsOneWidget);
      expect(find.textContaining('gore'), findsOneWidget);
    });

    testWidgets('uses most restrictive behavior from multiple labels', (tester) async {
      final labels = [
        ContentLabel(src: 'did:plc:a', uri: 'at://...', val: '!warn', cts: DateTime(2024)),
        ContentLabel(src: 'did:plc:b', uri: 'at://...', val: '!hide', cts: DateTime(2024)),
      ];

      await tester.pumpApp(
        Material(
          child: ContentWarning(labels: labels, child: const Text('Content')),
        ),
      );

      expect(find.text('Content hidden'), findsOneWidget);
      expect(find.text('Show content'), findsNothing);
    });
  });

  group('LabelChips', () {
    testWidgets('shows nothing for empty labels', (tester) async {
      await tester.pumpApp(const Material(child: LabelChips(labels: [])));

      expect(find.byType(Container), findsNothing);
    });

    testWidgets('shows chips for labels', (tester) async {
      final labels = [
        ContentLabel(src: 'did:plc:test', uri: 'at://...', val: 'spam', cts: DateTime(2024)),
        ContentLabel(src: 'did:plc:test', uri: 'at://...', val: 'scam', cts: DateTime(2024)),
      ];

      await tester.pumpApp(Material(child: LabelChips(labels: labels)));

      expect(find.text('spam'), findsOneWidget);
      expect(find.text('scam'), findsOneWidget);
    });

    testWidgets('shows shield icon for system labels', (tester) async {
      final labels = [
        ContentLabel(src: 'did:plc:test', uri: 'at://...', val: '!warn', cts: DateTime(2024)),
      ];

      await tester.pumpApp(Material(child: LabelChips(labels: labels)));

      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    });

    testWidgets('hides negated labels', (tester) async {
      final labels = [
        ContentLabel(
          src: 'did:plc:test',
          uri: 'at://...',
          val: 'spam',
          cts: DateTime(2024),
          neg: true,
        ),
      ];

      await tester.pumpApp(Material(child: LabelChips(labels: labels)));

      expect(find.text('spam'), findsNothing);
    });
  });
}
