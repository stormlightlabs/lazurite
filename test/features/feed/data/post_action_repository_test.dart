import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_bookmark_getbookmarks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';

class MockPostActionRepository implements PostActionRepository {
  final Map<String, dynamic> _likes = {};
  final Map<String, dynamic> _reposts = {};
  final Set<String> _deletedPosts = {};
  final Map<String, String> _bookmarks = {};

  @override
  Future<String> likePost({required dynamic uri, required String cid}) async {
    final likeUri = 'at://did:plc:test/app.bsky.feed.like/${uri.rkey}_like';
    _likes[uri.toString()] = likeUri;
    return likeUri;
  }

  @override
  Future<void> unlikePost({required String likeUri}) async {
    _likes.removeWhere((key, value) => value == likeUri);
  }

  @override
  Future<String> repostPost({required dynamic uri, required String cid}) async {
    final repostUri = 'at://did:plc:test/app.bsky.feed.repost/${uri.rkey}_repost';
    _reposts[uri.toString()] = repostUri;
    return repostUri;
  }

  @override
  Future<void> unrepostPost({required String repostUri}) async {
    _reposts.removeWhere((key, value) => value == repostUri);
  }

  @override
  Future<void> deletePost({required String postUri}) async {
    _deletedPosts.add(postUri);
  }

  @override
  Future<void> createBookmark({required AtUri uri, required String cid}) async {
    _bookmarks[uri.toString()] = cid;
  }

  @override
  Future<void> deleteBookmark({required AtUri uri}) async {
    _bookmarks.remove(uri.toString());
  }

  @override
  Future<BookmarkGetBookmarksOutput> getBookmarks({int? limit, String? cursor}) async {
    return const BookmarkGetBookmarksOutput(bookmarks: []);
  }

  bool isLiked(String postUri) => _likes.containsKey(postUri);
  bool isReposted(String postUri) => _reposts.containsKey(postUri);
  bool isDeleted(String postUri) => _deletedPosts.contains(postUri);
  bool isBookmarked(String postUri) => _bookmarks.containsKey(postUri);
  String? getLikeUri(String postUri) => _likes[postUri];
  String? getRepostUri(String postUri) => _reposts[postUri];
}

void main() {
  late MockPostActionRepository repository;

  setUp(() {
    repository = MockPostActionRepository();
  });

  group('PostActionRepository Contract', () {
    const testCid = 'bafyreie5cvv4hhpwo4y6x4f4m6fsq3xrm5f3p5vzum5h5uv5x5x5x5x5x5';

    group('likePost', () {
      test('should return like URI when successful', () async {
        final uri = _createTestUri('abc123');

        final result = await repository.likePost(uri: uri, cid: testCid);

        expect(result, isNotNull);
        expect(result, contains('app.bsky.feed.like'));
        expect(repository.isLiked(uri.toString()), isTrue);
      });

      test('should return different URIs for different posts', () async {
        final uri1 = _createTestUri('post1');
        final uri2 = _createTestUri('post2');

        final result1 = await repository.likePost(uri: uri1, cid: testCid);
        final result2 = await repository.likePost(uri: uri2, cid: testCid);

        expect(result1, isNot(equals(result2)));
      });
    });

    group('unlikePost', () {
      test('should remove like record', () async {
        final uri = _createTestUri('abc123');
        final likeUri = await repository.likePost(uri: uri, cid: testCid);

        expect(repository.isLiked(uri.toString()), isTrue);

        await repository.unlikePost(likeUri: likeUri);

        expect(repository.isLiked(uri.toString()), isFalse);
      });
    });

    group('repostPost', () {
      test('should return repost URI when successful', () async {
        final uri = _createTestUri('abc123');

        final result = await repository.repostPost(uri: uri, cid: testCid);

        expect(result, isNotNull);
        expect(result, contains('app.bsky.feed.repost'));
        expect(repository.isReposted(uri.toString()), isTrue);
      });

      test('should return different URIs for different posts', () async {
        final uri1 = _createTestUri('post1');
        final uri2 = _createTestUri('post2');

        final result1 = await repository.repostPost(uri: uri1, cid: testCid);
        final result2 = await repository.repostPost(uri: uri2, cid: testCid);

        expect(result1, isNot(equals(result2)));
      });
    });

    group('unrepostPost', () {
      test('should remove repost record', () async {
        final uri = _createTestUri('abc123');
        final repostUri = await repository.repostPost(uri: uri, cid: testCid);

        expect(repository.isReposted(uri.toString()), isTrue);

        await repository.unrepostPost(repostUri: repostUri);

        expect(repository.isReposted(uri.toString()), isFalse);
      });
    });

    group('deletePost', () {
      test('should mark post as deleted', () async {
        const postUri = 'at://did:plc:test/app.bsky.feed.post/to_delete';

        expect(repository.isDeleted(postUri), isFalse);

        await repository.deletePost(postUri: postUri);

        expect(repository.isDeleted(postUri), isTrue);
      });
    });

    group('like and repost interaction', () {
      test('should track likes and reposts independently', () async {
        final uri = _createTestUri('abc123');

        expect(repository.isLiked(uri.toString()), isFalse);
        expect(repository.isReposted(uri.toString()), isFalse);

        await repository.likePost(uri: uri, cid: testCid);
        expect(repository.isLiked(uri.toString()), isTrue);
        expect(repository.isReposted(uri.toString()), isFalse);

        await repository.repostPost(uri: uri, cid: testCid);
        expect(repository.isLiked(uri.toString()), isTrue);
        expect(repository.isReposted(uri.toString()), isTrue);
      });
    });

    group('createBookmark', () {
      test('should add bookmark', () async {
        final uri = AtUri.parse('at://did:plc:test/app.bsky.feed.post/abc123');

        expect(repository.isBookmarked(uri.toString()), isFalse);

        await repository.createBookmark(uri: uri, cid: testCid);

        expect(repository.isBookmarked(uri.toString()), isTrue);
      });
    });

    group('deleteBookmark', () {
      test('should remove bookmark', () async {
        final uri = AtUri.parse('at://did:plc:test/app.bsky.feed.post/abc123');
        await repository.createBookmark(uri: uri, cid: testCid);

        expect(repository.isBookmarked(uri.toString()), isTrue);

        await repository.deleteBookmark(uri: uri);

        expect(repository.isBookmarked(uri.toString()), isFalse);
      });
    });

    group('getBookmarks', () {
      test('should return empty bookmarks list', () async {
        final output = await repository.getBookmarks();

        expect(output.bookmarks, isEmpty);
        expect(output.cursor, isNull);
      });

      test('should accept limit and cursor params', () async {
        final output = await repository.getBookmarks(limit: 10, cursor: 'abc');

        expect(output.bookmarks, isEmpty);
      });
    });
  });
}

dynamic _createTestUri(String rkey) {
  return _MockAtUri('at://did:plc:test/app.bsky.feed.post/$rkey', rkey);
}

class _MockAtUri {
  _MockAtUri(this._uri, this.rkey);

  final String _uri;
  final String rkey;

  @override
  String toString() => _uri;
}
