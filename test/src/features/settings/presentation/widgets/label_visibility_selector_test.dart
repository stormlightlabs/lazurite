import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/settings/domain/bluesky_preferences.dart';
import 'package:lazurite/src/features/settings/presentation/widgets/label_visibility_selector.dart';

void main() {
  Widget buildTestWidget({
    required LabelVisibility value,
    required ValueChanged<LabelVisibility> onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: LabelVisibilitySelector(value: value, onChanged: onChanged),
        ),
      ),
    );
  }

  group('LabelVisibilitySelector', () {
    testWidgets('renders all visibility options', (tester) async {
      await tester.pumpWidget(buildTestWidget(value: LabelVisibility.warn, onChanged: (_) {}));

      expect(find.text('Off'), findsOneWidget);
      expect(find.text('Warn'), findsOneWidget);
      expect(find.text('Hide'), findsOneWidget);
    });

    testWidgets('shows current selection as ignore', (tester) async {
      await tester.pumpWidget(buildTestWidget(value: LabelVisibility.ignore, onChanged: (_) {}));

      final segmentedButton = tester.widget<SegmentedButton<LabelVisibility>>(
        find.byType(SegmentedButton<LabelVisibility>),
      );
      expect(segmentedButton.selected, contains(LabelVisibility.ignore));
    });

    testWidgets('shows current selection as warn', (tester) async {
      await tester.pumpWidget(buildTestWidget(value: LabelVisibility.warn, onChanged: (_) {}));

      final segmentedButton = tester.widget<SegmentedButton<LabelVisibility>>(
        find.byType(SegmentedButton<LabelVisibility>),
      );
      expect(segmentedButton.selected, contains(LabelVisibility.warn));
    });

    testWidgets('shows current selection as hide', (tester) async {
      await tester.pumpWidget(buildTestWidget(value: LabelVisibility.hide, onChanged: (_) {}));

      final segmentedButton = tester.widget<SegmentedButton<LabelVisibility>>(
        find.byType(SegmentedButton<LabelVisibility>),
      );
      expect(segmentedButton.selected, contains(LabelVisibility.hide));
    });

    testWidgets('tapping Off calls onChanged with ignore', (tester) async {
      LabelVisibility? selectedValue;
      await tester.pumpWidget(
        buildTestWidget(value: LabelVisibility.warn, onChanged: (v) => selectedValue = v),
      );

      await tester.tap(find.text('Off'));
      await tester.pumpAndSettle();

      expect(selectedValue, LabelVisibility.ignore);
    });

    testWidgets('tapping Warn calls onChanged with warn', (tester) async {
      LabelVisibility? selectedValue;
      await tester.pumpWidget(
        buildTestWidget(value: LabelVisibility.ignore, onChanged: (v) => selectedValue = v),
      );

      await tester.tap(find.text('Warn'));
      await tester.pumpAndSettle();

      expect(selectedValue, LabelVisibility.warn);
    });

    testWidgets('tapping Hide calls onChanged with hide', (tester) async {
      LabelVisibility? selectedValue;
      await tester.pumpWidget(
        buildTestWidget(value: LabelVisibility.warn, onChanged: (v) => selectedValue = v),
      );

      await tester.tap(find.text('Hide'));
      await tester.pumpAndSettle();

      expect(selectedValue, LabelVisibility.hide);
    });
  });
}
