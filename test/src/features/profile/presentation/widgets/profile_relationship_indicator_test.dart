import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/profile_relationship_indicator.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('ProfileRelationshipIndicator', () {
    testWidgets('renders nothing when no relationship states', (tester) async {
      await tester.pumpApp(const Material(child: ProfileRelationshipIndicator()));

      expect(find.byType(Container), findsNothing);
    });

    testWidgets('displays muted indicator', (tester) async {
      await tester.pumpApp(const Material(child: ProfileRelationshipIndicator(viewerMuted: true)));

      expect(find.text('Muted'), findsOneWidget);
      expect(find.byIcon(Icons.volume_off), findsOneWidget);
    });

    testWidgets('displays muted via list indicator', (tester) async {
      await tester.pumpApp(
        const Material(
          child: ProfileRelationshipIndicator(
            viewerMuted: true,
            mutedByList: 'at://did:plc:test/list/123',
          ),
        ),
      );

      expect(find.text('Muted via list'), findsOneWidget);
    });

    testWidgets('displays blocked indicator', (tester) async {
      await tester.pumpApp(
        const Material(child: ProfileRelationshipIndicator(viewerBlocked: true)),
      );

      expect(find.text('Blocked'), findsOneWidget);
      expect(find.byIcon(Icons.block), findsOneWidget);
    });

    testWidgets('displays blocked via list indicator', (tester) async {
      await tester.pumpApp(
        const Material(
          child: ProfileRelationshipIndicator(
            viewerBlocked: true,
            blockingByList: 'at://did:plc:test/list/123',
          ),
        ),
      );

      expect(find.text('Blocked via list'), findsOneWidget);
    });

    testWidgets('displays blocked-by indicator', (tester) async {
      await tester.pumpApp(
        const Material(child: ProfileRelationshipIndicator(viewerBlockedBy: true)),
      );

      expect(find.text('Blocks you'), findsOneWidget);
      expect(find.byIcon(Icons.block), findsOneWidget);
    });

    testWidgets('displays follows you indicator', (tester) async {
      await tester.pumpApp(
        const Material(child: ProfileRelationshipIndicator(viewerFollowedBy: true)),
      );

      expect(find.text('Follows you'), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });

    testWidgets('displays multiple states when applicable', (tester) async {
      await tester.pumpApp(
        const Material(
          child: ProfileRelationshipIndicator(viewerMuted: true, viewerFollowedBy: true),
        ),
      );

      expect(find.text('Muted'), findsOneWidget);
      expect(find.text('Follows you'), findsOneWidget);
    });

    testWidgets('has proper semantic labels', (tester) async {
      await tester.pumpApp(
        const Material(child: ProfileRelationshipIndicator(viewerBlockedBy: true)),
      );

      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Blocks you',
      );
      expect(semanticsFinder, findsOneWidget);
    });
  });
}
