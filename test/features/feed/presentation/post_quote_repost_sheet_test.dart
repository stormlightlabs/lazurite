import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_bookmark_getbookmarks.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_getlikes.dart';
import 'package:bluesky/app_bsky_feed_getquotes.dart';
import 'package:bluesky/app_bsky_feed_getrepostedby.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_quote_repost_sheet.dart';

class _FakeRepository implements PostActionRepository {
  _FakeRepository({this.quotes = const [], this.reposters = const []});

  final List<PostView> quotes;
  final List<ProfileView> reposters;

  @override
  Future<FeedGetQuotesOutput> getQuotes({required AtUri uri, String? cursor}) async {
    return FeedGetQuotesOutput(uri: uri, posts: quotes);
  }

  @override
  Future<FeedGetRepostedByOutput> getRepostedBy({required AtUri uri, String? cursor}) async {
    return FeedGetRepostedByOutput(uri: uri, repostedBy: reposters);
  }

  @override
  Future<FeedGetLikesOutput> getLikes({required AtUri uri, String? cursor}) async {
    return FeedGetLikesOutput(uri: uri, likes: []);
  }

  @override
  Future<String> likePost({required AtUri uri, required String cid}) async => '';

  @override
  Future<void> unlikePost({required String likeUri}) async {}

  @override
  Future<String> repostPost({required AtUri uri, required String cid}) async => '';

  @override
  Future<void> unrepostPost({required String repostUri}) async {}

  @override
  Future<void> deletePost({required String postUri}) async {}

  @override
  Future<void> createBookmark({required AtUri uri, required String cid}) async {}

  @override
  Future<void> deleteBookmark({required AtUri uri}) async {}

  @override
  Future<BookmarkGetBookmarksOutput> getBookmarks({int? limit, String? cursor}) async {
    return const BookmarkGetBookmarksOutput(bookmarks: []);
  }
}

PostView _makeQuotePost({required String rkey, required String text, required String handle}) {
  return PostView(
    uri: AtUri('at://did:plc:$rkey/app.bsky.feed.post/$rkey'),
    cid: 'cid-$rkey',
    author: ProfileViewBasic(did: 'did:plc:$rkey', handle: handle, displayName: handle.split('.').first),
    record: {r'$type': 'app.bsky.feed.post', 'text': text, 'createdAt': DateTime.utc(2026, 3, 15).toIso8601String()},
    indexedAt: DateTime.utc(2026, 3, 15),
  );
}

ProfileView _makeProfile({required String handle}) {
  return ProfileView(did: 'did:plc:$handle', handle: handle, displayName: handle.split('.').first);
}

Widget _buildSheet(PostActionRepository repository) {
  final theme = AppTheme.getTheme(AppThemePalette.oxocarbon, AppThemeVariant.dark);
  return MaterialApp(
    theme: theme,
    home: Scaffold(
      body: PostQuoteRepostSheet(
        postUri: AtUri.parse('at://did:plc:test/app.bsky.feed.post/abc'),
        quoteCount: 1,
        repostCount: 2,
        repository: repository,
      ),
    ),
  );
}

void main() {
  group('PostQuoteRepostSheet', () {
    testWidgets('renders grouped quote and repost sections', (tester) async {
      await tester.pumpWidget(
        _buildSheet(
          _FakeRepository(
            quotes: [_makeQuotePost(rkey: 'quote1', text: 'Quoted post', handle: 'q.bsky.social')],
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('QUOTE / REPOSTS'), findsOneWidget);
      expect(find.text('Quotes'), findsOneWidget);
      expect(find.text('Reposts'), findsOneWidget);
      expect(find.text('Quoted post'), findsOneWidget);
    });

    testWidgets('expands repost group and shows reposter list', (tester) async {
      await tester.pumpWidget(_buildSheet(_FakeRepository(reposters: [_makeProfile(handle: 'alice.bsky.social')])));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Reposts'));
      await tester.pump();
      await tester.pump();

      expect(find.text('alice'), findsOneWidget);
      expect(find.text('@alice.bsky.social'), findsOneWidget);
    });
  });
}
