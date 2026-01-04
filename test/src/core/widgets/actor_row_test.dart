import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/actor_row.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('ActorRow', () {
    testWidgets('renders handle', (tester) async {
      await tester.pumpApp(
        const Material(
          child: ActorRow(did: 'did:plc:test', handle: 'testuser.bsky.social'),
        ),
      );

      expect(find.text('@testuser.bsky.social'), findsOneWidget);
    });

    testWidgets('renders display name when provided', (tester) async {
      await tester.pumpApp(
        const Material(
          child: ActorRow(
            did: 'did:plc:test',
            handle: 'testuser.bsky.social',
            displayName: 'Test User',
          ),
        ),
      );

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('@testuser.bsky.social'), findsOneWidget);
    });

    testWidgets('shows handle as primary text when no display name', (tester) async {
      await tester.pumpApp(
        const Material(
          child: ActorRow(did: 'did:plc:test', handle: 'testuser.bsky.social', displayName: null),
        ),
      );

      expect(find.text('testuser.bsky.social'), findsOneWidget);
      expect(find.text('@testuser.bsky.social'), findsOneWidget);
    });

    testWidgets('renders description when provided', (tester) async {
      await tester.pumpApp(
        const Material(
          child: ActorRow(
            did: 'did:plc:test',
            handle: 'testuser.bsky.social',
            description: 'Flutter developer and open source enthusiast',
          ),
        ),
      );

      expect(find.text('Flutter developer and open source enthusiast'), findsOneWidget);
    });

    testWidgets('hides description when null or empty', (tester) async {
      await tester.pumpApp(
        const Material(
          child: ActorRow(did: 'did:plc:test', handle: 'testuser.bsky.social', description: ''),
        ),
      );

      expect(find.byType(ActorRow), findsOneWidget);
    });

    testWidgets('invokes onTap callback when pressed', (tester) async {
      var tapped = false;

      await tester.pumpApp(
        Material(
          child: ActorRow(
            did: 'did:plc:test',
            handle: 'testuser.bsky.social',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(ActorRow));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('renders trailing widget when provided', (tester) async {
      await tester.pumpApp(
        const Material(
          child: ActorRow(
            did: 'did:plc:test',
            handle: 'testuser.bsky.social',
            trailing: Text('Follow'),
          ),
        ),
      );

      expect(find.text('Follow'), findsOneWidget);
    });

    testWidgets('shows avatar placeholder when no image', (tester) async {
      await tester.pumpApp(
        const Material(
          child: ActorRow(did: 'did:plc:test', handle: 'testuser.bsky.social', avatar: null),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('truncates long display name', (tester) async {
      await tester.pumpApp(
        const Material(
          child: SizedBox(
            width: 200,
            child: ActorRow(
              did: 'did:plc:test',
              handle: 'testuser.bsky.social',
              displayName: 'This is an extremely long display name that should be truncated',
            ),
          ),
        ),
      );

      expect(find.byType(ActorRow), findsOneWidget);
    });
  });
}
