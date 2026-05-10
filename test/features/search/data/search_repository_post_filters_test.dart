import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:poptart_lex/app/bsky/feed/search_posts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/search/data/post_search_filters.dart';
import 'package:lazurite/features/search/data/search_repository.dart';

class _FakeResponse<T> {
  _FakeResponse(this.data);

  final T data;
}

class _FakeSearchPostsData {
  _FakeSearchPostsData({required this.posts, this.cursor, this.hitsTotal});

  final List<PostView> posts;
  final String? cursor;
  final int? hitsTotal;
}

class _FakeFeedService {
  String? lastQ;
  FeedSearchPostsSort? lastSort;
  String? lastSince;
  String? lastUntil;
  String? lastMentions;
  String? lastAuthor;
  String? lastLang;
  String? lastDomain;
  String? lastUrl;
  List<String>? lastTags;
  String? lastCursor;
  int? lastLimit;

  Future<_FakeResponse<_FakeSearchPostsData>> searchPosts({
    required String q,
    FeedSearchPostsSort? sort,
    String? since,
    String? until,
    String? mentions,
    String? author,
    String? lang,
    String? domain,
    String? url,
    List<String>? tag,
    String? cursor,
    int? limit,
    Map<String, String>? $headers,
  }) async {
    lastQ = q;
    lastSort = sort;
    lastSince = since;
    lastUntil = until;
    lastMentions = mentions;
    lastAuthor = author;
    lastLang = lang;
    lastDomain = domain;
    lastUrl = url;
    lastTags = tag;
    lastCursor = cursor;
    lastLimit = limit;

    return _FakeResponse(
      _FakeSearchPostsData(
        posts: [
          PostView(
            uri: AtUri.parse('at://did:plc:test/app.bsky.feed.post/1'),
            cid: 'cid1',
            author: const ProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social'),
            record: const {r'$type': 'app.bsky.feed.post', 'text': 'post', 'createdAt': '2026-01-01T00:00:00.000Z'},
            indexedAt: DateTime.utc(2026, 1, 1),
          ),
        ],
        cursor: 'next',
        hitsTotal: 42,
      ),
    );
  }
}

class _FakeBluesky {
  _FakeBluesky(this.feed);

  final _FakeFeedService feed;
}

void main() {
  group('SearchRepository.searchPosts filter mapping', () {
    late _FakeFeedService feed;
    late SearchRepository repository;

    setUp(() {
      feed = _FakeFeedService();
      repository = SearchRepository(bluesky: _FakeBluesky(feed));
    });

    test('maps all filters and sort to SDK call', () async {
      final since = DateTime.utc(2026, 1, 1, 5);
      final until = DateTime.utc(2026, 1, 2, 6);
      final result = await repository.searchPosts(
        query: '  flutter  ',
        sort: 'latest',
        filters: PostSearchFilters(
          since: since,
          until: until,
          mentions: ' did:plc:mentions ',
          author: ' did:plc:author ',
          lang: ' en ',
          domain: ' example.com ',
          url: ' https://example.com ',
          tags: const [' #dart ', '#flutter', '#Dart'],
        ),
        cursor: 'cursor-1',
        limit: 120,
      );

      expect(result.posts, hasLength(1));
      expect(result.cursor, 'next');
      expect(result.hitsTotal, 42);

      expect(feed.lastQ, 'flutter');
      expect(feed.lastSort?.toJson(), KnownFeedSearchPostsSort.latest.value);
      expect(feed.lastSince, since.toIso8601String());
      expect(feed.lastUntil, until.toIso8601String());
      expect(feed.lastMentions, 'did:plc:mentions');
      expect(feed.lastAuthor, 'did:plc:author');
      expect(feed.lastLang, 'en');
      expect(feed.lastDomain, 'example.com');
      expect(feed.lastUrl, 'https://example.com');
      expect(feed.lastTags, ['dart', 'flutter']);
      expect(feed.lastCursor, 'cursor-1');
      expect(feed.lastLimit, 100);
    });

    test('uses wildcard query for filter-only request', () async {
      await repository.searchPosts(
        query: '   ',
        filters: const PostSearchFilters(author: 'did:plc:author'),
      );

      expect(feed.lastQ, '*');
      expect(feed.lastAuthor, 'did:plc:author');
    });

    test('throws validation exception when query and filters are empty', () {
      expect(
        () => repository.searchPosts(query: '   ', filters: const PostSearchFilters()),
        throwsA(isA<PostSearchValidationException>()),
      );
    });
  });
}
