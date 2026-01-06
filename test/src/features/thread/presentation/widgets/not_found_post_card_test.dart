import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/not_found_post_card.dart';

void main() {
  group('NotFoundPostCard', () {
    testWidgets('renders deleted message', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: NotFoundPostCard())));
      expect(find.text('This post has been deleted'), findsOneWidget);
    });

    testWidgets('displays delete icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: NotFoundPostCard())));
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('has semantic label for accessibility', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: NotFoundPostCard())));
      final semantics = tester.getSemantics(find.byType(NotFoundPostCard));
      expect(semantics.label, contains('Deleted post'));
    });
  });
}
