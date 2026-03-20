import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_footer.dart';

Widget _buildSubject(PostCardFooter footer) {
  return MaterialApp(home: Scaffold(body: footer));
}

void main() {
  group('formatPostTime', () {
    test('returns NOW for times less than 1 minute ago', () {
      final now = DateTime.now().subtract(const Duration(seconds: 30));
      expect(formatPostTime(now), 'NOW');
    });

    test('returns minutes with M suffix for less than 1 hour', () {
      final time = DateTime.now().subtract(const Duration(minutes: 15));
      expect(formatPostTime(time), '15M');
    });

    test('returns hours with H suffix for less than 1 day', () {
      final time = DateTime.now().subtract(const Duration(hours: 3));
      expect(formatPostTime(time), '3H');
    });

    test('returns days with D suffix for less than 1 week', () {
      final time = DateTime.now().subtract(const Duration(days: 2));
      expect(formatPostTime(time), '2D');
    });

    test('returns uppercase month+day for older times', () {
      final time = DateTime(2025, 1, 5);
      final result = formatPostTime(time);
      expect(result, equals(result.toUpperCase()));
      expect(result, contains('JAN'));
    });
  });

  group('PostCardFooter', () {
    testWidgets('renders timestamp text', (tester) async {
      await tester.pumpWidget(_buildSubject(const PostCardFooter(timestamp: '2H')));

      expect(find.text('2H'), findsOneWidget);
    });

    testWidgets('renders reply, repost, like, and save icons', (tester) async {
      await tester.pumpWidget(_buildSubject(const PostCardFooter(timestamp: '1H')));

      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      expect(find.byIcon(Icons.repeat), findsOneWidget);
      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_outline), findsOneWidget);
    });

    testWidgets('shows active like icon when isLiked is true', (tester) async {
      await tester.pumpWidget(_buildSubject(const PostCardFooter(timestamp: '1H', isLiked: true)));

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_outline), findsNothing);
    });

    testWidgets('shows active repost icon when isReposted is true', (tester) async {
      await tester.pumpWidget(_buildSubject(const PostCardFooter(timestamp: '1H', isReposted: true)));

      // repeat icon is used for both active and inactive
      expect(find.byIcon(Icons.repeat), findsOneWidget);
    });

    testWidgets('calls onReply when reply icon tapped', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildSubject(PostCardFooter(timestamp: '1H', onReply: () => called = true)));

      await tester.tap(find.byIcon(Icons.chat_bubble_outline));
      expect(called, isTrue);
    });

    testWidgets('calls onRepost when repost icon tapped', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildSubject(PostCardFooter(timestamp: '1H', onRepost: () => called = true)));

      await tester.tap(find.byIcon(Icons.repeat));
      expect(called, isTrue);
    });

    testWidgets('calls onLike when like icon tapped', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildSubject(PostCardFooter(timestamp: '1H', onLike: () => called = true)));

      await tester.tap(find.byIcon(Icons.favorite_outline));
      expect(called, isTrue);
    });

    testWidgets('shows loading indicator instead of like icon when isLoadingLike', (tester) async {
      await tester.pumpWidget(_buildSubject(const PostCardFooter(timestamp: '1H', isLoadingLike: true)));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.favorite_outline), findsNothing);
    });

    testWidgets('shows loading indicator instead of repost icon when isLoadingRepost', (tester) async {
      await tester.pumpWidget(_buildSubject(const PostCardFooter(timestamp: '1H', isLoadingRepost: true)));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.repeat), findsNothing);
    });

    testWidgets('has a top border via BoxDecoration', (tester) async {
      await tester.pumpWidget(_buildSubject(const PostCardFooter(timestamp: '1H')));

      final container = tester.widget<Container>(
        find.ancestor(of: find.byType(Row), matching: find.byType(Container)).first,
      );
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.border, isNotNull);
    });
  });
}
