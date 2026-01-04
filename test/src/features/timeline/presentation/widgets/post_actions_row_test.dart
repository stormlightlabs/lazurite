import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/timeline/presentation/widgets/post_actions_row.dart';

void main() {
  group('PostActionsRow', () {
    testWidgets('renders icons', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PostActionsRow())));

      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      expect(find.byIcon(Icons.repeat), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });

    testWidgets('renders counts correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PostActionsRow(replyCount: 5, repostCount: 1500, likeCount: 2000000),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
      expect(find.text('1.5k'), findsOneWidget);
      expect(find.text('2.0M'), findsOneWidget);
    });

    testWidgets('hides counts when zero', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PostActionsRow())));

      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });
  });
}
