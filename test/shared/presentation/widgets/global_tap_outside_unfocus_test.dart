import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/shared/presentation/widgets/global_tap_outside_unfocus.dart';

void main() {
  testWidgets('tapping outside focused text input dismisses focus', (tester) async {
    final focusNode = FocusNode(debugLabel: 'global-focus-test');
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: GlobalTapOutsideUnfocus(
          child: Scaffold(
            body: Column(
              children: [
                TextField(focusNode: focusNode),
                const SizedBox(height: 200),
                const SizedBox(width: 120, height: 40, child: ColoredBox(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, isTrue);

    await tester.tapAt(const Offset(20, 260));
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, isFalse);
  });

  testWidgets('touch down outside does not unfocus until touch up', (tester) async {
    final focusNode = FocusNode(debugLabel: 'global-focus-test-up');
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: GlobalTapOutsideUnfocus(
          child: Scaffold(
            body: Column(
              children: [
                TextField(focusNode: focusNode),
                const SizedBox(height: 200),
                const SizedBox(width: 120, height: 40, child: ColoredBox(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, isTrue);

    final gesture = await tester.startGesture(const Offset(20, 260));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, isFalse);
  });
}
