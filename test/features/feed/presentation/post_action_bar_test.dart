import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_action_bar.dart';

Widget _buildBar({
  int replyCount = 0,
  int repostCount = 0,
  int likeCount = 0,
  int saveCount = 0,
  bool isLiked = false,
  bool isReposted = false,
  bool isSaved = false,
  VoidCallback? onSave,
  VoidCallback? onLongPressSave,
  VoidCallback? onRepost,
  VoidCallback? onLike,
  VoidCallback? onReply,
}) {
  return MaterialApp(
    home: Scaffold(
      body: PostActionBar(
        replyCount: replyCount,
        repostCount: repostCount,
        likeCount: likeCount,
        saveCount: saveCount,
        isLiked: isLiked,
        isReposted: isReposted,
        isSaved: isSaved,
        postUri: 'at://did:plc:author/app.bsky.feed.post/abc123',
        onSave: onSave,
        onLongPressSave: onLongPressSave,
        onRepost: onRepost,
        onLike: onLike,
        onReply: onReply,
      ),
    ),
  );
}

void main() {
  group('PostActionBar', () {
    testWidgets('renders with all counts', (tester) async {
      await tester.pumpWidget(_buildBar(replyCount: 3, repostCount: 7, likeCount: 42, saveCount: 5));

      expect(find.text('3'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('does not show saveCount when zero', (tester) async {
      await tester.pumpWidget(_buildBar(saveCount: 0));

      // Count of 0 is not shown — only counts > 0 are rendered
      expect(find.text('0'), findsNothing);
    });

    testWidgets('shows save count when > 0', (tester) async {
      await tester.pumpWidget(_buildBar(saveCount: 12));
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('long press bookmark calls onLongPressSave', (tester) async {
      var longPressCalled = false;
      await tester.pumpWidget(_buildBar(onLongPressSave: () => longPressCalled = true));

      await tester.longPress(find.byIcon(Icons.bookmark_outline));
      await tester.pump();

      expect(longPressCalled, isTrue);
    });

    testWidgets('tap bookmark shows save options bottom sheet', (tester) async {
      await tester.pumpWidget(_buildBar(onSave: () {}));

      await tester.tap(find.byIcon(Icons.bookmark_outline));
      await tester.pumpAndSettle();

      expect(find.text('Save locally'), findsOneWidget);
      expect(find.text('Save to Bluesky'), findsOneWidget);
    });

    testWidgets('save menu shows Remove label when already saved', (tester) async {
      await tester.pumpWidget(_buildBar(isSaved: true, onSave: () {}));

      await tester.tap(find.byIcon(Icons.bookmark));
      await tester.pumpAndSettle();

      expect(find.text('Remove local save'), findsOneWidget);
    });

    testWidgets('tapping Save locally in menu calls onSave', (tester) async {
      var saveCalled = false;
      await tester.pumpWidget(_buildBar(onSave: () => saveCalled = true));

      await tester.tap(find.byIcon(Icons.bookmark_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save locally'));
      await tester.pumpAndSettle();

      expect(saveCalled, isTrue);
    });

    testWidgets('bookmark icon is amber when saved', (tester) async {
      await tester.pumpWidget(_buildBar(isSaved: true, onSave: () {}));

      final icon = tester.widget<Icon>(find.byIcon(Icons.bookmark));
      expect(icon.color, equals(Colors.amber));
    });
  });
}
