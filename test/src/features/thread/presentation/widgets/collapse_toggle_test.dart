import 'package:flutter/cupertino.dart';
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
      expect(find.byIcon(CupertinoIcons.chevron_down_circle), findsOneWidget);

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
      expect(find.byIcon(CupertinoIcons.chevron_right_circle), findsOneWidget);
    });

    testWidgets('switches chevron direction when toggling', (tester) async {
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

      expect(find.byIcon(CupertinoIcons.chevron_down_circle), findsOneWidget);

      await tester.tap(find.byType(CollapseToggle));
      await tester.pump();

      expect(find.byIcon(CupertinoIcons.chevron_right_circle), findsOneWidget);
    });

    testWidgets('reserves consistent tap target size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: CollapseToggle(isCollapsed: false, onTap: () {})),
          ),
        ),
      );

      expect(tester.getSize(find.byType(CollapseToggle)), const Size(32, 32));
    });
  });
}
