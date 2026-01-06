import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/domain/content_label.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/profile_labels.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('ProfileLabels', () {
    testWidgets('renders nothing when no labels provided', (tester) async {
      await tester.pumpApp(const Material(child: ProfileLabels()));
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('renders chips for raw labels', (tester) async {
      final labels = [
        {'val': '!warn', 'uri': 'at://...', 'src': 'did:plc:test', 'cts': '2024-01-01T00:00:00Z'},
        {'val': 'spam', 'uri': 'at://...', 'src': 'did:plc:test', 'cts': '2024-01-01T00:00:00Z'},
      ];

      await tester.pumpApp(Material(child: ProfileLabels(rawLabels: labels)));

      expect(find.text('warn'), findsOneWidget); // displayValue strips !
      expect(find.text('spam'), findsOneWidget);
    });

    testWidgets('renders chips for ContentLabel objects', (tester) async {
      final labels = [
        ContentLabel(
          src: 'did:plc:test',
          uri: 'at://did:plc:user/app.bsky.actor.profile/self',
          val: '!warn',
          cts: DateTime(2024),
        ),
        ContentLabel(
          src: 'did:plc:test',
          uri: 'at://did:plc:user/app.bsky.actor.profile/self',
          val: 'scam',
          cts: DateTime(2024),
        ),
      ];

      await tester.pumpApp(Material(child: ProfileLabels(labels: labels)));

      expect(find.text('warn'), findsOneWidget);
      expect(find.text('scam'), findsOneWidget);
    });

    testWidgets('shows shield icon for system labels', (tester) async {
      final labels = [
        ContentLabel(src: 'did:plc:test', uri: 'at://...', val: '!warn', cts: DateTime(2024)),
      ];

      await tester.pumpApp(Material(child: ProfileLabels(labels: labels)));

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

      await tester.pumpApp(Material(child: ProfileLabels(labels: labels)));

      expect(find.text('spam'), findsNothing);
    });
  });
}
