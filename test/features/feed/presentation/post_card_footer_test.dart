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

    testWidgets('shows action counts when enabled', (tester) async {
      await tester.pumpWidget(
        _buildSubject(
          const PostCardFooter(
            timestamp: '1H',
            replyCount: 3,
            repostCount: 7,
            likeCount: 42,
            saveCount: 5,
            showCounts: true,
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows active like icon when isLiked is true', (tester) async {
      await tester.pumpWidget(_buildSubject(const PostCardFooter(timestamp: '1H', isLiked: true)));
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_outline), findsNothing);
    });

    testWidgets('shows active repost icon when isReposted is true', (tester) async {
      await tester.pumpWidget(_buildSubject(const PostCardFooter(timestamp: '1H', isReposted: true)));
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

    testWidgets('long press repost opens repost and quote sheet options', (tester) async {
      await tester.pumpWidget(_buildSubject(PostCardFooter(timestamp: '1H', onRepost: () {}, onQuote: () {})));

      await tester.longPress(find.byIcon(Icons.repeat));
      await tester.pumpAndSettle();

      expect(find.text('Repost'), findsOneWidget);
      expect(find.text('Quote Post'), findsOneWidget);
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

    testWidgets('uses compact spacing without overflow at narrow grid widths', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final previousOnError = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = previousOnError);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(width: 185.5, child: PostCardFooter(timestamp: 'SEP 20')),
            ),
          ),
        ),
      );

      expect(errors.where((error) => error.exceptionAsString().contains('A RenderFlex overflowed')), isEmpty);
      expect(find.text('SEP 20'), findsOneWidget);
    });

    testWidgets('wraps actions above the timestamp at narrow thread widths', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final previousOnError = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = previousOnError);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 150,
                child: PostCardFooter(
                  timestamp: 'SEP 20',
                  replyCount: 3,
                  repostCount: 7,
                  likeCount: 42,
                  saveCount: 5,
                  showCounts: true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(errors.where((error) => error.exceptionAsString().contains('A RenderFlex overflowed')), isEmpty);
      expect(find.text('SEP 20'), findsOneWidget);
    });

    testWidgets('hides counts at very narrow widths even when enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 220,
                child: PostCardFooter(
                  timestamp: '1H',
                  replyCount: 3,
                  repostCount: 7,
                  likeCount: 42,
                  saveCount: 5,
                  showCounts: true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('3'), findsNothing);
      expect(find.text('7'), findsNothing);
      expect(find.text('42'), findsNothing);
      expect(find.text('5'), findsNothing);
      expect(find.text('1H'), findsOneWidget);
    });

    testWidgets('shows kebab action when onMore is provided', (tester) async {
      await tester.pumpWidget(_buildSubject(PostCardFooter(timestamp: '1H', onMore: () {})));
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });
  });
}
