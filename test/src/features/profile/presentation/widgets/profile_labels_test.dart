import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/profile_labels.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('ProfileLabels', () {
    testWidgets('renders nothing when no labels provided', (tester) async {
      await tester.pumpApp(const Material(child: ProfileLabels(labels: [])));
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('renders chips for labels', (tester) async {
      final labels = [
        {'val': '!warn', 'uri': 'at://...'},
        {'val': 'spam', 'uri': 'at://...'},
      ];

      await tester.pumpApp(Material(child: ProfileLabels(labels: labels)));

      expect(find.text('!warn'), findsOneWidget);
      expect(find.text('spam'), findsOneWidget);
    });
  });
}
