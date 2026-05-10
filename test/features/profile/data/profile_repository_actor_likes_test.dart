import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/network/actor_repository_service_resolver.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('self likes path uses app.bsky.feed.getActorLikes only', () async {
    final feedService = _FakeFeedService(
      actorLikesPage: _FakeActorLikesData(
        feed: [
          _makeFeedViewPost('at://did:plc:author/app.bsky.feed.post/1'),
          _makeFeedViewPost('at://did:plc:author/app.bsky.feed.post/2'),
        ],
      ),
      hydratedPosts: const [],
    );
    final repoService = _FakeRepoService(recordsData: const _FakeListRecordsData(records: []));
    final bluesky = _FakeBlueskyClient(
      session: const _FakeSession('did:plc:me', 'me.bsky.social'),
      feed: feedService,
      repo: repoService,
    );
    final repository = ProfileRepository(database: database, bluesky: bluesky);

    final result = await repository.getActorLikes(actor: 'did:plc:me', limit: 50);

    expect(feedService.getActorLikesCallCount, 1);
    expect(repoService.listRecordsCallCount, 0);
    expect(feedService.getPostsCallCount, 0);
    expect(result.posts.length, 2);
  });

  test('non-self likes path uses actor PDS listRecords + appview getPosts and keeps record order', () async {
    const actorDid = 'did:plc:friend';
    const firstSubject = 'at://did:plc:author/app.bsky.feed.post/first';
    const secondSubject = 'at://did:plc:author/app.bsky.feed.post/second';
    final feedService = _FakeFeedService(
      actorLikesPage: const _FakeActorLikesData(feed: []),
      hydratedPosts: [_makePostView(secondSubject)],
    );
    final repoService = _FakeRepoService(
      recordsData: const _FakeListRecordsData(
        records: [
          _FakeRepoRecord(
            value: {
              'subject': {'uri': firstSubject},
              'createdAt': '2026-05-02T01:34:47.734Z',
            },
          ),
          _FakeRepoRecord(
            value: {
              'subject': {'uri': secondSubject},
              'createdAt': '2026-05-02T01:00:00.000Z',
            },
          ),
        ],
      ),
    );
    final actorRepoResolver = _FakeActorRepositoryServiceResolver(
      const ActorRepositoryServiceResolution(actor: actorDid, did: actorDid, pdsHost: 'friend.host'),
    );
    final bluesky = _FakeBlueskyClient(
      session: const _FakeSession('did:plc:me', 'me.bsky.social'),
      feed: feedService,
      repo: repoService,
    );
    final repository = ProfileRepository(
      database: database,
      bluesky: bluesky,
      appViewProvider: 'bluesky',
      actorRepositoryServiceResolver: actorRepoResolver,
    );

    final result = await repository.getActorLikes(actor: actorDid, limit: 50);

    expect(actorRepoResolver.resolveCallCount, 1);
    expect(repoService.listRecordsCallCount, 1);
    expect(repoService.lastReverse, isFalse);
    expect(repoService.lastServiceHost, 'friend.host');
    expect(feedService.getActorLikesCallCount, 0);
    expect(feedService.getPostsCallCount, 1);
    expect(feedService.lastGetPostsServiceHost, 'public.api.bsky.app');
    expect(result.entries.length, 2);
    expect(result.entries.first.isAvailable, isFalse);
    expect(result.entries.first.subjectUri, firstSubject);
    expect(result.entries.last.isAvailable, isTrue);
    expect(result.entries.last.feedViewPost?.post.uri.toString(), secondSubject);
  });
}

FeedViewPost _makeFeedViewPost(String uri) => FeedViewPost(post: _makePostView(uri));

PostView _makePostView(String uri) {
  return PostView(
    uri: AtUri.parse(uri),
    cid: 'cid-$uri',
    author: const ProfileViewBasic(did: 'did:plc:author', handle: 'author.bsky.social'),
    record: const {r'$type': 'app.bsky.feed.post', 'text': 'hello', 'createdAt': '2026-05-01T00:00:00.000Z'},
    indexedAt: DateTime.utc(2026, 5, 1),
  );
}

class _FakeBlueskyClient {
  _FakeBlueskyClient({required this.session, required this.feed, required _FakeRepoService repo})
    : atproto = _FakeAtprotoClient(repo: repo);

  final _FakeSession session;
  final _FakeFeedService feed;
  final _FakeAtprotoClient atproto;
}

class _FakeSession {
  const _FakeSession(this.did, this.handle);

  final String did;
  final String handle;
}

class _FakeAtprotoClient {
  const _FakeAtprotoClient({required this.repo});

  final _FakeRepoService repo;
}

class _FakeFeedService {
  _FakeFeedService({required _FakeActorLikesData actorLikesPage, required List<PostView> hydratedPosts})
    : _actorLikesPage = actorLikesPage,
      _hydratedPosts = hydratedPosts;

  final _FakeActorLikesData _actorLikesPage;
  final List<PostView> _hydratedPosts;
  int getActorLikesCallCount = 0;
  int getPostsCallCount = 0;
  String? lastGetPostsServiceHost;

  Future<_FakeResponse<_FakeActorLikesData>> getActorLikes({
    required String actor,
    String? cursor,
    int? limit,
    Map<String, String>? $headers,
  }) async {
    if (cursor != null && cursor.isNotEmpty) {}
    getActorLikesCallCount++;
    return _FakeResponse(_actorLikesPage);
  }

  Future<_FakeResponse<_FakeGetPostsData>> getPosts({
    required List<AtUri> uris,
    String? $service,
    Map<String, String>? $headers,
  }) async {
    getPostsCallCount++;
    lastGetPostsServiceHost = $service;
    return _FakeResponse(_FakeGetPostsData(posts: _hydratedPosts));
  }
}

class _FakeRepoService {
  _FakeRepoService({required _FakeListRecordsData recordsData}) : _recordsData = recordsData;

  final _FakeListRecordsData _recordsData;
  int listRecordsCallCount = 0;
  String? lastServiceHost;
  bool? lastReverse;

  Future<_FakeResponse<_FakeListRecordsData>> listRecords({
    required String repo,
    required String collection,
    int? limit,
    String? cursor,
    bool? reverse,
    String? $service,
  }) async {
    if (cursor != null && cursor.isNotEmpty) {}
    listRecordsCallCount++;
    lastServiceHost = $service;
    lastReverse = reverse;
    return _FakeResponse(_recordsData);
  }
}

class _FakeResponse<T> {
  const _FakeResponse(this.data);

  final T data;
}

class _FakeActorLikesData {
  const _FakeActorLikesData({required this.feed}) : cursor = null;

  final List<FeedViewPost> feed;
  final String? cursor;
}

class _FakeGetPostsData {
  const _FakeGetPostsData({required this.posts});

  final List<PostView> posts;
}

class _FakeListRecordsData {
  const _FakeListRecordsData({required this.records}) : cursor = null;

  final List<_FakeRepoRecord> records;
  final String? cursor;
}

class _FakeRepoRecord {
  const _FakeRepoRecord({required this.value});

  final Map<String, dynamic> value;
}

class _FakeActorRepositoryServiceResolver extends ActorRepositoryServiceResolver {
  _FakeActorRepositoryServiceResolver(this._resolution) : super();

  final ActorRepositoryServiceResolution _resolution;
  int resolveCallCount = 0;

  @override
  Future<ActorRepositoryServiceResolution> resolve(String actor) async {
    resolveCallCount++;
    return _resolution;
  }
}
