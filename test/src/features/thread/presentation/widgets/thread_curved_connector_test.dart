import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/thread_curved_connector.dart';

void main() {
  group('ThreadCurvedConnector', () {
    testWidgets('renders with parentToChild style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 200,
              child: ThreadCurvedConnector(style: ConnectorStyle.parentToChild, depth: 1),
            ),
          ),
        ),
      );

      expect(find.byType(ThreadCurvedConnector), findsOneWidget);
    });

    testWidgets('renders with continuation style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 200,
              child: ThreadCurvedConnector(style: ConnectorStyle.continuation, depth: 2),
            ),
          ),
        ),
      );

      expect(find.byType(ThreadCurvedConnector), findsOneWidget);
    });

    testWidgets('renders with terminal style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 200,
              child: ThreadCurvedConnector(style: ConnectorStyle.terminal, depth: 3),
            ),
          ),
        ),
      );

      expect(find.byType(ThreadCurvedConnector), findsOneWidget);
    });

    testWidgets('uses custom color when provided', (tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 200,
              child: ThreadCurvedConnector(
                style: ConnectorStyle.parentToChild,
                depth: 1,
                color: customColor,
              ),
            ),
          ),
        ),
      );

      final connector = tester.widget<ThreadCurvedConnector>(find.byType(ThreadCurvedConnector));
      expect(connector.color, customColor);
    });

    testWidgets('uses custom width when provided', (tester) async {
      const customWidth = 4.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 200,
              child: ThreadCurvedConnector(
                style: ConnectorStyle.parentToChild,
                depth: 1,
                width: customWidth,
              ),
            ),
          ),
        ),
      );

      final connector = tester.widget<ThreadCurvedConnector>(find.byType(ThreadCurvedConnector));
      expect(connector.width, customWidth);
    });

    testWidgets('accepts different depth values', (tester) async {
      for (var depth = 0; depth <= 5; depth++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 100,
                height: 200,
                child: ThreadCurvedConnector(style: ConnectorStyle.parentToChild, depth: depth),
              ),
            ),
          ),
        );

        final connector = tester.widget<ThreadCurvedConnector>(find.byType(ThreadCurvedConnector));
        expect(connector.depth, depth);
      }
    });
  });
}
