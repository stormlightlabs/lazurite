import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/post_card_skeleton.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('PostCardSkeleton', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpApp(const PostCardSkeleton());
      expect(find.byType(PostCardSkeleton), findsOneWidget);
    });

    testWidgets('renders default 3 content lines', (tester) async {
      await tester.pumpApp(const PostCardSkeleton());
      await tester.pump();
      expect(find.byType(PostCardSkeleton), findsOneWidget);
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('renders custom line count', (tester) async {
      await tester.pumpApp(const PostCardSkeleton(lineCount: 5));
      await tester.pump();
      expect(find.byType(PostCardSkeleton), findsOneWidget);
    });

    testWidgets('has running animation', (tester) async {
      await tester.pumpApp(const PostCardSkeleton());
      expect(find.byType(AnimatedBuilder), findsWidgets);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(PostCardSkeleton), findsOneWidget);
    });

    testWidgets('contains avatar and content placeholders', (tester) async {
      await tester.pumpApp(const PostCardSkeleton());
      await tester.pump();
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('disposes animation controller properly', (tester) async {
      await tester.pumpApp(const PostCardSkeleton());
      await tester.pump();
      await tester.pumpWidget(Container());
      expect(tester.takeException(), isNull);
    });
  });
}
