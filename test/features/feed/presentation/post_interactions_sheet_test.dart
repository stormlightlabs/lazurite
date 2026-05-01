import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_bookmark_getbookmarks.dart';
import 'package:bluesky/app_bsky_feed_getlikes.dart';
import 'package:bluesky/app_bsky_feed_getquotes.dart';
import 'package:bluesky/app_bsky_feed_getrepostedby.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_interactions_sheet.dart';

class _FakeRepository implements PostActionRepository {
  _FakeRepository({this.reposters = const []});
  final List<ProfileView> reposters;

  @override
  Future<FeedGetLikesOutput> getLikes({required AtUri uri, String? cursor}) async {
    return FeedGetLikesOutput(uri: uri, likes: []);
  }

  @override
  Future<FeedGetRepostedByOutput> getRepostedBy({required AtUri uri, String? cursor}) async {
    return FeedGetRepostedByOutput(uri: uri, repostedBy: reposters);
  }

  @override
  Future<FeedGetQuotesOutput> getQuotes({required AtUri uri, String? cursor}) async {
    return FeedGetQuotesOutput(uri: uri, posts: []);
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

class _FakeLikesRepository extends _FakeRepository {
  _FakeLikesRepository(this._likers);
  final List<ProfileView> _likers;

  @override
  Future<FeedGetLikesOutput> getLikes({required AtUri uri, String? cursor}) async {
    return FeedGetLikesOutput(
      uri: uri,
      likes: _likers.map((p) => Like(indexedAt: DateTime.utc(2026), createdAt: DateTime.utc(2026), actor: p)).toList(),
    );
  }
}

final _testUri = AtUri.parse('at://did:plc:test/app.bsky.feed.post/abc');

ProfileView _makeProfile({String handle = 'alice.bsky.social', String? displayName}) {
  return ProfileView(did: 'did:plc:$handle', handle: handle, displayName: displayName);
}

Widget _buildSheet({required PostActionRepository repository, int likeCount = 0, int repostCount = 0}) {
  final theme = AppTheme.getTheme(AppThemePalette.oxocarbon, AppThemeVariant.dark);
  return MaterialApp(
    theme: theme,
    home: Scaffold(
      body: PostInteractionsSheet(
        postUri: _testUri,
        likeCount: likeCount,
        repostCount: repostCount,
        repository: repository,
      ),
    ),
  );
}

void main() {
  group('PostInteractionsSheet', () {
    testWidgets('shows loading indicator while fetching likes', (tester) async {
      final repo = _FakeRepository();
      await tester.pumpWidget(_buildSheet(repository: repo, likeCount: 5));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows "LIKED BY" label when only likes available', (tester) async {
      final repo = _FakeLikesRepository([_makeProfile()]);
      await tester.pumpWidget(_buildSheet(repository: repo, likeCount: 1));
      await tester.pump();
      await tester.pump();

      expect(find.text('LIKED BY'), findsOneWidget);
    });

    testWidgets('shows "REPOSTED BY" label when only reposts available', (tester) async {
      final repo = _FakeRepository(reposters: [_makeProfile()]);
      await tester.pumpWidget(_buildSheet(repository: repo, repostCount: 1));
      await tester.pump();
      await tester.pump();

      expect(find.text('REPOSTED BY'), findsOneWidget);
    });

    testWidgets('shows tab chips when both likes and reposts are present', (tester) async {
      final repo = _FakeLikesRepository([_makeProfile()]);
      await tester.pumpWidget(_buildSheet(repository: repo, likeCount: 3, repostCount: 2));
      await tester.pump();
      await tester.pump();

      expect(find.text('3 Likes'), findsOneWidget);
      expect(find.text('2 Reposts'), findsOneWidget);
    });

    testWidgets('shows empty message when no likers returned', (tester) async {
      final repo = _FakeLikesRepository([]);
      await tester.pumpWidget(_buildSheet(repository: repo, likeCount: 1));
      await tester.pump();
      await tester.pump();

      expect(find.text('No interactions yet'), findsOneWidget);
    });

    testWidgets('shows likers list after loading', (tester) async {
      final repo = _FakeLikesRepository([
        _makeProfile(handle: 'alice.bsky.social', displayName: 'Alice'),
        _makeProfile(handle: 'bob.bsky.social', displayName: 'Bob'),
      ]);
      await tester.pumpWidget(_buildSheet(repository: repo, likeCount: 2));
      await tester.pump();
      await tester.pump();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('shows reposters list when repost tab selected', (tester) async {
      final repo = _FakeRepository(
        reposters: [_makeProfile(handle: 'carol.bsky.social', displayName: 'Carol')],
      );
      await tester.pumpWidget(_buildSheet(repository: repo, likeCount: 3, repostCount: 1));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('1 Reposts'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Carol'), findsOneWidget);
    });
  });
}
