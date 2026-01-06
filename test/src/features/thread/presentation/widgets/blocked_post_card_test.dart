import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/blocked_post_card.dart';

void main() {
  group('BlockedPostCard', () {
    testWidgets('renders blocked message', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BlockedPostCard())));
      expect(find.text("This post is from an account you've blocked"), findsOneWidget);
    });

    testWidgets('displays block icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BlockedPostCard())));
      expect(find.byIcon(Icons.block), findsOneWidget);
    });

    testWidgets('has semantic label for accessibility', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BlockedPostCard())));
      final semantics = tester.getSemantics(find.byType(BlockedPostCard));
      expect(semantics.label, contains('Blocked post'));
    });
  });
}
