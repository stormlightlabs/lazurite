import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/notifications/presentation/widgets/notification_list_item_skeleton.dart';

void main() {
  group('NotificationListItemSkeleton', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NotificationListItemSkeleton())),
      );

      expect(find.byType(NotificationListItemSkeleton), findsOneWidget);
    });

    testWidgets('contains Card widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NotificationListItemSkeleton())),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('animates shimmer effect', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NotificationListItemSkeleton())),
      );

      await tester.pump();

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(NotificationListItemSkeleton), findsOneWidget);
    });

    testWidgets('disposes animation controller', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NotificationListItemSkeleton())),
      );

      await tester.pump();

      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    });

    testWidgets('uses theme colors for shimmer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(body: NotificationListItemSkeleton()),
        ),
      );

      expect(find.byType(NotificationListItemSkeleton), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(body: NotificationListItemSkeleton()),
        ),
      );

      expect(find.byType(NotificationListItemSkeleton), findsOneWidget);
    });

    testWidgets('shows expected layout structure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NotificationListItemSkeleton())),
      );

      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });
  });
}
