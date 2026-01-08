import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/notifications/presentation/widgets/unread_badge.dart';

void main() {
  group('UnreadBadge', () {
    testWidgets('displays badge with count when count > 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UnreadBadge(count: 5, child: Icon(Icons.notifications))),
        ),
      );

      expect(find.byType(Badge), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isTrue);
    });

    testWidgets('hides badge when count is 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UnreadBadge(count: 0, child: Icon(Icons.notifications))),
        ),
      );

      expect(find.byType(Badge), findsOneWidget);
      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isFalse);
    });

    testWidgets('displays "99+" for counts greater than 99', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UnreadBadge(count: 150, child: Icon(Icons.notifications))),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
      expect(find.text('150'), findsNothing);

      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isTrue);
    });

    testWidgets('displays exact count for count = 99', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UnreadBadge(count: 99, child: Icon(Icons.notifications))),
        ),
      );

      expect(find.text('99'), findsOneWidget);
      expect(find.text('99+'), findsNothing);
    });

    testWidgets('displays "99+" for count = 100', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UnreadBadge(count: 100, child: Icon(Icons.notifications))),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
      expect(find.text('100'), findsNothing);
    });

    testWidgets('displays single digit counts correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UnreadBadge(count: 1, child: Icon(Icons.notifications))),
        ),
      );

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('displays double digit counts correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UnreadBadge(count: 42, child: Icon(Icons.notifications))),
        ),
      );

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('renders child widget correctly', (tester) async {
      const testIcon = Icon(Icons.notifications_outlined, key: Key('test-icon'));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UnreadBadge(count: 3, child: testIcon)),
        ),
      );

      expect(find.byKey(const Key('test-icon')), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('badge updates when count changes from 0 to positive', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UnreadBadge(count: 0, child: Icon(Icons.notifications))),
        ),
      );

      Badge badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isFalse);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UnreadBadge(count: 5, child: Icon(Icons.notifications))),
        ),
      );

      badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isTrue);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('badge updates when count changes from positive to 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UnreadBadge(count: 10, child: Icon(Icons.notifications))),
        ),
      );

      Badge badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isTrue);
      expect(find.text('10'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UnreadBadge(count: 0, child: Icon(Icons.notifications))),
        ),
      );

      badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isFalse);
    });

    testWidgets('badge updates when count changes from below 99 to above 99', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UnreadBadge(count: 50, child: Icon(Icons.notifications))),
        ),
      );

      expect(find.text('50'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UnreadBadge(count: 150, child: Icon(Icons.notifications))),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
      expect(find.text('50'), findsNothing);
    });

    group('Semantics', () {
      testWidgets('provides semantic label when count > 0', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: UnreadBadge(count: 7, child: Icon(Icons.notifications))),
          ),
        );

        expect(
          tester.getSemantics(find.byType(Icon)),
          matchesSemantics(label: '7 unread notifications'),
        );
      });

      testWidgets('no semantic label when count is 0', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: UnreadBadge(count: 0, child: Icon(Icons.notifications))),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Icon));
        expect(semantics.label, anyOf(isNull, isEmpty));
      });

      testWidgets('semantic label uses actual count for large numbers', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: UnreadBadge(count: 250, child: Icon(Icons.notifications))),
          ),
        );

        expect(
          tester.getSemantics(find.byType(Icon)),
          matchesSemantics(label: '250 unread notifications'),
        );
      });
    });

    group('Edge Cases', () {
      testWidgets('handles negative count gracefully', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: UnreadBadge(count: -5, child: Icon(Icons.notifications))),
          ),
        );

        final badge = tester.widget<Badge>(find.byType(Badge));
        expect(badge.isLabelVisible, isFalse);
      });

      testWidgets('handles very large counts', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: UnreadBadge(count: 999999, child: Icon(Icons.notifications))),
          ),
        );

        expect(find.text('99+'), findsOneWidget);
        expect(find.text('999999'), findsNothing);
      });
    });
  });
}
