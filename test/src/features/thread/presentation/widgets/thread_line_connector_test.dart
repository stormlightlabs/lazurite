import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/thread_line_connector.dart';

void main() {
  group('ThreadLineConnector', () {
    testWidgets('renders nothing for none position', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                SizedBox(height: 100, width: 100),
                ThreadLineConnector(position: ThreadLinePosition.none),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(Positioned), findsNothing);
    });

    testWidgets('renders Positioned widget for top position', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                SizedBox(height: 200, width: 100),
                ThreadLineConnector(position: ThreadLinePosition.top),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('renders Positioned widget for middle position', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                SizedBox(height: 200, width: 100),
                ThreadLineConnector(position: ThreadLinePosition.middle),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('renders Positioned widget for bottom position', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                SizedBox(height: 200, width: 100),
                ThreadLineConnector(position: ThreadLinePosition.bottom),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('accepts custom color parameter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                SizedBox(height: 200, width: 100),
                ThreadLineConnector(position: ThreadLinePosition.middle, color: Colors.red),
              ],
            ),
          ),
        ),
      );

      final threadLineConnector = tester.widget<ThreadLineConnector>(
        find.byType(ThreadLineConnector),
      );
      expect(threadLineConnector.color, Colors.red);
    });

    testWidgets('accepts custom width parameter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                SizedBox(height: 200, width: 100),
                ThreadLineConnector(position: ThreadLinePosition.middle, width: 4),
              ],
            ),
          ),
        ),
      );

      final threadLineConnector = tester.widget<ThreadLineConnector>(
        find.byType(ThreadLineConnector),
      );
      expect(threadLineConnector.width, 4);
    });
  });

  group('ThreadLinePosition', () {
    test('has all expected values', () {
      expect(ThreadLinePosition.values.length, 4);
      expect(ThreadLinePosition.values.contains(ThreadLinePosition.top), true);
      expect(ThreadLinePosition.values.contains(ThreadLinePosition.middle), true);
      expect(ThreadLinePosition.values.contains(ThreadLinePosition.bottom), true);
      expect(ThreadLinePosition.values.contains(ThreadLinePosition.none), true);
    });
  });
}
