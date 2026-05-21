import 'package:poptart_core/poptart_core.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/search_posts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/search/data/post_search_filters.dart';
import 'package:lazurite/features/search/data/search_repository.dart';

import '../../../helpers/test_bluesky_client.dart';

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

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    if (url.pathSegments.last != 'app.bsky.feed.searchPosts') {
      return unexpectedGetClient(url, headers: headers);
    }

    final query = url.queryParameters;
    lastQ = query['q'];
    lastSort = FeedSearchPostsSort.valueOf(query['sort']);
    lastSince = query['since'];
    lastUntil = query['until'];
    lastMentions = query['mentions'];
    lastAuthor = query['author'];
    lastLang = query['lang'];
    lastDomain = query['domain'];
    lastUrl = query['url'];
    lastTags = url.queryParametersAll['tag'];
    lastCursor = query['cursor'];
    lastLimit = int.tryParse(query['limit'] ?? '');

    return jsonResponse(
      url,
      'GET',
      FeedSearchPostsOutput(
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
      ).toJson(),
    );
  }
}

void main() {
  group('SearchRepository.searchPosts filter mapping', () {
    late _FakeFeedService feed;
    late SearchRepository repository;

    setUp(() {
      feed = _FakeFeedService();
      repository = SearchRepository(bluesky: testBluesky(getClient: feed.get));
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

    test('refreshes and retries search after unauthorized response', () async {
      var initialRequests = 0;
      var recoveryCalls = 0;
      final refreshedFeed = _FakeFeedService();
      final initialClient = testBluesky(
        getClient: (url, {headers}) async {
          initialRequests += 1;
          return http.Response(
            '{"error":"Unauthorized","message":"\\"exp\\" claim timestamp check failed"}',
            401,
            request: http.Request('GET', url),
          );
        },
      );
      final refreshedClient = testBluesky(getClient: refreshedFeed.get);
      final recoveringRepository = SearchRepository(
        bluesky: initialClient,
        onUnauthorized: () async {
          recoveryCalls += 1;
          return const AuthTokens(
            accessToken: 'fresh-access',
            refreshToken: 'fresh-refresh',
            did: 'did:plc:test',
            handle: 'test.bsky.social',
          );
        },
        blueskyClientFactory: (_) => refreshedClient,
      );

      final result = await recoveringRepository.searchPosts(query: 'flutter');

      expect(result.posts, hasLength(1));
      expect(initialRequests, 1);
      expect(recoveryCalls, 1);
      expect(refreshedFeed.lastQ, 'flutter');
    });

    test('throws validation exception when query and filters are empty', () {
      expect(
        () => repository.searchPosts(query: '   ', filters: const PostSearchFilters()),
        throwsA(isA<PostSearchValidationException>()),
      );
    });
  });
}
