import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/collapse_toggle.dart';

void main() {
  group('CollapseToggle', () {
    testWidgets('renders with expanded state', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CollapseToggle(isCollapsed: false, onTap: () => tapped = true)),
        ),
      );

      expect(find.byType(CollapseToggle), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      await tester.tap(find.byType(CollapseToggle));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('renders with collapsed state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CollapseToggle(isCollapsed: true, onTap: () {})),
        ),
      );

      expect(find.byType(CollapseToggle), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('shows reply count badge when showCount is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollapseToggle(isCollapsed: false, onTap: () {}, replyCount: 5, showCount: true),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('hides reply count badge when showCount is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollapseToggle(
              isCollapsed: false,
              onTap: () {},
              replyCount: 5,
              showCount: false,
            ),
          ),
        ),
      );

      expect(find.text('5'), findsNothing);
    });

    testWidgets('hides badge when replyCount is 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollapseToggle(isCollapsed: false, onTap: () {}, replyCount: 0, showCount: true),
          ),
        ),
      );

      expect(find.byType(Container), findsNothing);
    });

    testWidgets('icon rotates when toggling collapse state', (tester) async {
      var isCollapsed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return CollapseToggle(
                  isCollapsed: isCollapsed,
                  onTap: () => setState(() => isCollapsed = !isCollapsed),
                );
              },
            ),
          ),
        ),
      );

      var rotation = tester.widget<AnimatedRotation>(find.byType(AnimatedRotation));
      expect(rotation.turns, 0);

      await tester.tap(find.byType(CollapseToggle));
      await tester.pump();

      rotation = tester.widget<AnimatedRotation>(find.byType(AnimatedRotation));
      expect(rotation.turns, -0.25);
    });

    testWidgets('displays different reply counts', (tester) async {
      for (final count in [1, 10, 100, 999]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CollapseToggle(
                isCollapsed: false,
                onTap: () {},
                replyCount: count,
                showCount: true,
              ),
            ),
          ),
        );

        expect(find.text(count.toString()), findsOneWidget);
      }
    });
  });
}
