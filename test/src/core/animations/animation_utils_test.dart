import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/animations/animation_utils.dart';

void main() {
  group('AnimatedItem', () {
    testWidgets('animates into view', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AnimatedItem(index: 0, child: Text('Item 0'))),
        ),
      );

      final fadeTransitionFinder = find.descendant(
        of: find.byType(AnimatedItem),
        matching: find.byType(FadeTransition),
      );
      final fadeTransition = tester.widget<FadeTransition>(fadeTransitionFinder);
      expect(fadeTransition.opacity.value, 0.0);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 150));

      final fadeTransitionMid = tester.widget<FadeTransition>(fadeTransitionFinder);
      expect(fadeTransitionMid.opacity.value, greaterThan(0.0));
      expect(fadeTransitionMid.opacity.value, lessThan(1.0));

      await tester.pump(const Duration(milliseconds: 150));
      final fadeTransitionEnd = tester.widget<FadeTransition>(fadeTransitionFinder);
      expect(fadeTransitionEnd.opacity.value, 1.0);
    });
  });

  group('ScaleButton', () {
    testWidgets('scales down on tap down', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ScaleButton(
                child: GestureDetector(
                  onTap: () => tapped = true,
                  child: Container(color: Colors.red, width: 100, height: 100),
                ),
              ),
            ),
          ),
        ),
      );

      final scaleFinder = find.descendant(
        of: find.byType(ScaleButton),
        matching: find.byType(ScaleTransition),
      );

      final scaleTransition = tester.widget<ScaleTransition>(scaleFinder);
      expect(scaleTransition.scale.value, 1.0);

      final gesture = await tester.startGesture(tester.getCenter(find.byType(ScaleButton)));
      await tester.pump();
      await tester.pumpAndSettle();

      final scaleTransitionAfter = tester.widget<ScaleTransition>(scaleFinder);
      expect(scaleTransitionAfter.scale.value, lessThan(1.0));

      await gesture.up();
      await tester.pump();
      await tester.pumpAndSettle();

      final scaleTransitionFinal = tester.widget<ScaleTransition>(scaleFinder);
      expect(scaleTransitionFinal.scale.value, 1.0);
      expect(tapped, isTrue);
    });
  });

  group('AnimatedContentSwitcher', () {
    testWidgets('switches content with animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedContentSwitcher(child: Text('State 1', key: ValueKey(1))),
          ),
        ),
      );

      expect(find.text('State 1'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedContentSwitcher(child: Text('State 2', key: ValueKey(2))),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('State 1'), findsOneWidget);
      expect(find.text('State 2'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('State 1'), findsNothing);
      expect(find.text('State 2'), findsOneWidget);
    });
  });
}
