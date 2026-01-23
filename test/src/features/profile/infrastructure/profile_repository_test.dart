import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockXrpcClient mockApi;
  late AppDatabase db;
  late MockLogger mockLogger;
  late ProfileRepository repository;
  const ownerDid = 'did:web:test';

  setUp(() {
    mockApi = MockXrpcClient();
    db = AppDatabase(NativeDatabase.memory());
    mockLogger = MockLogger();
    repository = ProfileRepository(
      mockApi,
      db.profileDao,
      db.followsDao,
      db.profileRelationshipDao,
      mockLogger,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('ProfileRepository', () {
    group('getProfile', () {
      test('fetches profile from API and caches it', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockProfileResponse(withViewer: true));

        final profile = await repository.getProfile('testuser.bsky.social', ownerDid);

        expect(profile.did, 'did:plc:test123');
        expect(profile.handle, 'testuser.bsky.social');
        expect(profile.displayName, 'Test User');
        expect(profile.followersCount, 100);
        expect(profile.followsCount, 50);
        expect(profile.followsCount, 50);
        expect(profile.postsCount, 25);
        expect(profile.pronouns, 'they/them');
        expect(profile.website, 'https://example.com');
        expect(profile.verificationStatus, 'verified');
        expect(profile.pinnedPostUri, 'at://did:plc:test123/app.bsky.feed.post/pinned123');
        expect(profile.viewerFollowing, true);

        verify(
          () =>
              mockApi.call('app.bsky.actor.getProfile', params: {'actor': 'testuser.bsky.social'}),
        ).called(1);

        final cached = await db.profileDao.getProfile('did:plc:test123');
        expect(cached, isNotNull);
        expect(cached!.handle, 'testuser.bsky.social');

        final relationship = await db.profileRelationshipDao.getRelationship(
          'did:plc:test123',
          ownerDid,
        );
        expect(relationship, isNotNull);
        expect(relationship!.following, true);
        expect(relationship.followingUri, 'at://did:plc:viewer/app.bsky.graph.follow/abc123');
      });

      test('handles profile without optional fields', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => {'did': 'did:plc:minimal', 'handle': 'minimal.bsky.social'});

        final profile = await repository.getProfile('minimal.bsky.social', ownerDid);

        expect(profile.did, 'did:plc:minimal');
        expect(profile.handle, 'minimal.bsky.social');
        expect(profile.displayName, isNull);
        expect(profile.description, isNull);
        expect(profile.followersCount, 0);
      });

      test('logs error and rethrows on API failure', () async {
        final exception = Exception('Network error');
        when(() => mockApi.call(any(), params: any(named: 'params'))).thenThrow(exception);

        expect(() => repository.getProfile('testuser', ownerDid), throwsA(isA<Exception>()));

        verify(() => mockLogger.error(any(), exception, any())).called(1);
      });
    });

    group('getCachedProfile', () {
      test('returns cached profile from DAO', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockProfileResponse());

        await repository.getProfile('testuser.bsky.social', ownerDid);

        final result = await repository.getCachedProfile('did:plc:test123');

        expect(result, isNotNull);
        expect(result!.did, 'did:plc:test123');
      });

      test('returns null when profile not cached', () async {
        final result = await repository.getCachedProfile('did:plc:notcached');
        expect(result, isNull);
      });
    });

    group('watchProfile', () {
      test('returns stream from DAO', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockProfileResponse());

        await repository.getProfile('testuser.bsky.social', ownerDid);

        final result = await repository.watchProfile('did:plc:test123').first;
        expect(result, isNotNull);
        expect(result!.handle, 'testuser.bsky.social');
      });
    });

    group('getAuthorFeed', () {
      test('fetches author feed with pagination', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockAuthorFeedResponse());

        final result = await repository.getAuthorFeed('did:plc:test123');

        expect(result.items, hasLength(2));
        expect(result.cursor, 'next_cursor');
        expect(result.hasMore, isTrue);
        expect(result.items.first.text, 'Hello world');
      });

      test('passes cursor for pagination', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockAuthorFeedResponse(cursor: null));

        final result = await repository.getAuthorFeed('did:plc:test123', cursor: 'prev_cursor');

        expect(result.hasMore, isFalse);
        verify(
          () => mockApi.call(
            'app.bsky.feed.getAuthorFeed',
            params: {'actor': 'did:plc:test123', 'limit': 50, 'cursor': 'prev_cursor'},
          ),
        ).called(1);
      });

      test('handles empty feed', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => {'feed': <dynamic>[]});

        final result = await repository.getAuthorFeed('did:plc:empty');

        expect(result.items, isEmpty);
        expect(result.hasMore, isFalse);
      });
    });

    group('getProfile viewer relationship', () {
      test('parses viewerFollowing from API response', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockProfileResponse(withViewer: true));

        final profile = await repository.getProfile('testuser', ownerDid);

        expect(profile.viewerFollowing, isTrue);
        expect(profile.viewerFollowUri, 'at://did:plc:viewer/app.bsky.graph.follow/abc123');
      });

      test('handles missing viewer in response', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockProfileResponse());

        final profile = await repository.getProfile('testuser', ownerDid);

        expect(profile.viewerFollowing, isFalse);
        expect(profile.viewerFollowUri, isNull);
      });
    });

    group('getFollowers', () {
      test('fetches followers with pagination', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockFollowersResponse(cursor: 'next'));

        final result = await repository.getFollowers('did:plc:test123');

        expect(result.followers, hasLength(2));
        expect(result.cursor, 'next');
        expect(result.hasMore, isTrue);
        expect(result.followers.first.did, 'did:plc:follower1');
        expect(result.followers.first.displayName, 'Follower One');
      });

      test('handles empty followers', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => {'followers': <dynamic>[]});

        final result = await repository.getFollowers('did:plc:test123');

        expect(result.followers, isEmpty);
        expect(result.hasMore, isFalse);
      });
    });

    group('getFollows', () {
      test('fetches follows with pagination', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockFollowsResponse(cursor: 'next'));

        final result = await repository.getFollows('did:plc:test123');

        expect(result.follows, hasLength(1));
        expect(result.cursor, 'next');
        expect(result.hasMore, isTrue);
        expect(result.follows.first.did, 'did:plc:following1');
      });

      test('handles empty follows', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => {'follows': <dynamic>[]});

        final result = await repository.getFollows('did:plc:test123');

        expect(result.follows, isEmpty);
        expect(result.hasMore, isFalse);
      });
    });

    group('follow', () {
      test('creates follow record and caches it', () async {
        when(() => mockApi.call(any(), body: any(named: 'body'))).thenAnswer(
          (_) async => {
            'uri': 'at://did:plc:actor/app.bsky.graph.follow/rkey123',
            'cid': 'cid123',
          },
        );

        final uri = await repository.follow('did:plc:actor', 'did:plc:subject');

        expect(uri, 'at://did:plc:actor/app.bsky.graph.follow/rkey123');

        final cached = await repository.getCachedFollow('did:plc:actor', 'did:plc:subject');
        expect(cached, isNotNull);
        expect(cached!.uri, uri);
      });

      test('logs error and rethrows on API failure', () async {
        final exception = Exception('Network error');
        when(() => mockApi.call(any(), body: any(named: 'body'))).thenThrow(exception);

        expect(
          () => repository.follow('did:plc:actor', 'did:plc:subject'),
          throwsA(isA<Exception>()),
        );

        verify(() => mockLogger.error(any(), exception, any())).called(1);
      });
    });

    group('unfollow', () {
      test('deletes follow record and removes from cache', () async {
        when(
          () => mockApi.call('com.atproto.repo.createRecord', body: any(named: 'body')),
        ).thenAnswer(
          (_) async => {
            'uri': 'at://did:plc:actor/app.bsky.graph.follow/rkey123',
            'cid': 'cid123',
          },
        );
        await repository.follow('did:plc:actor', 'did:plc:subject');

        when(
          () => mockApi.call('com.atproto.repo.deleteRecord', body: any(named: 'body')),
        ).thenAnswer((_) async => <String, dynamic>{});

        await repository.unfollow(
          'did:plc:actor',
          'at://did:plc:actor/app.bsky.graph.follow/rkey123',
        );

        final cached = await repository.getCachedFollow('did:plc:actor', 'did:plc:subject');
        expect(cached, isNull);
      });

      test('throws on invalid follow URI format', () async {
        expect(
          () => repository.unfollow('did:plc:actor', 'invalid-uri'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('blockActor', () {
      test('creates block record and updates local cache', () async {
        await db.profileRelationshipDao.upsertRelationship(
          ProfileRelationshipsCompanion.insert(
            profileDid: 'did:plc:subject',
            updatedAt: DateTime.now(),
            ownerDid: 'did:plc:actor',
          ),
        );

        when(() => mockApi.call(any(), body: any(named: 'body'))).thenAnswer(
          (_) async => {'uri': 'at://did:plc:actor/app.bsky.graph.block/rkey123', 'cid': 'cid123'},
        );

        final uri = await repository.blockActor('did:plc:actor', 'did:plc:subject');
        expect(uri, 'at://did:plc:actor/app.bsky.graph.block/rkey123');

        final rel = await db.profileRelationshipDao.getRelationship(
          'did:plc:subject',
          'did:plc:actor',
        );
        expect(rel, isNotNull);
        expect(rel!.blocked, isTrue);
        expect(rel.blockingUri, uri);
      });
    });

    group('unblockActor', () {
      test('deletes block record and updates local cache if subjectDid provided', () async {
        await db.profileRelationshipDao.upsertRelationship(
          ProfileRelationshipsCompanion.insert(
            profileDid: 'did:plc:subject',
            blocked: const Value(true),
            blockingUri: const Value('at://did:plc:actor/app.bsky.graph.block/rkey123'),
            updatedAt: DateTime.now(),
            ownerDid: 'did:plc:actor',
          ),
        );

        when(
          () => mockApi.call('com.atproto.repo.deleteRecord', body: any(named: 'body')),
        ).thenAnswer((_) async => <String, dynamic>{});

        await repository.unblockActor(
          'did:plc:actor',
          'at://did:plc:actor/app.bsky.graph.block/rkey123',
          subjectDid: 'did:plc:subject',
        );

        verify(
          () => mockApi.call(
            'com.atproto.repo.deleteRecord',
            body: {
              'repo': 'did:plc:actor',
              'collection': 'app.bsky.graph.block',
              'rkey': 'rkey123',
            },
          ),
        ).called(1);

        final rel = await db.profileRelationshipDao.getRelationship(
          'did:plc:subject',
          'did:plc:actor',
        );
        expect(rel, isNotNull);
        expect(rel!.blocked, isFalse);
        expect(rel.blockingUri, isNull);
      });

      test('does not update local cache if subjectDid is null', () async {
        await db.profileRelationshipDao.upsertRelationship(
          ProfileRelationshipsCompanion.insert(
            profileDid: 'did:plc:subject',
            blocked: const Value(true),
            blockingUri: const Value('at://did:plc:actor/app.bsky.graph.block/rkey123'),
            updatedAt: DateTime.now(),
            ownerDid: 'did:plc:actor',
          ),
        );

        when(
          () => mockApi.call('com.atproto.repo.deleteRecord', body: any(named: 'body')),
        ).thenAnswer((_) async => <String, dynamic>{});

        await repository.unblockActor(
          'did:plc:actor',
          'at://did:plc:actor/app.bsky.graph.block/rkey123',
        );

        final rel = await db.profileRelationshipDao.getRelationship(
          'did:plc:subject',
          'did:plc:actor',
        );
        expect(rel, isNotNull);
        expect(rel!.blocked, isTrue);
      });
    });

    group('getPost', () {
      test('fetches post and parses it correctly', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockGetPostsResponse());

        final post = await repository.getPost('at://did:plc:test123/app.bsky.feed.post/1');

        expect(post, isNotNull);
        expect(post!.uri, 'at://did:plc:test123/app.bsky.feed.post/1');
        expect(post.text, 'Hello world');
        expect(post.author.did, 'did:plc:test123');
        expect(post.replyCount, 5);
      });

      test('returns null if no posts found', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => {'posts': <dynamic>[]});

        final post = await repository.getPost('at://did:plc:test123/app.bsky.feed.post/1');

        expect(post, isNull);
      });
    });
  });
}

Map<String, dynamic> _mockGetPostsResponse() => {
  'posts': [
    {
      'uri': 'at://did:plc:test123/app.bsky.feed.post/1',
      'cid': 'cid1',
      'author': {
        'did': 'did:plc:test123',
        'handle': 'testuser.bsky.social',
        'displayName': 'Test User',
        'avatar': 'https://example.com/avatar.jpg',
      },
      'record': {'text': 'Hello world', 'createdAt': '2024-01-01T12:00:00.000Z'},
      'indexedAt': '2024-01-01T12:00:00.000Z',
      'replyCount': 5,
      'repostCount': 3,
      'likeCount': 10,
      'viewer': {'like': 'at://did:plc:viewer/app.bsky.feed.like/123'},
    },
  ],
};

Map<String, dynamic> _mockProfileResponse({bool withViewer = false}) => {
  'did': 'did:plc:test123',
  'handle': 'testuser.bsky.social',
  'displayName': 'Test User',
  'description': 'A test user profile',
  'avatar': 'https://example.com/avatar.jpg',
  'banner': 'https://example.com/banner.jpg',
  'followersCount': 100,
  'followsCount': 50,
  'postsCount': 25,
  'indexedAt': '2024-01-01T12:00:00.000Z',
  'pronouns': 'they/them',
  'website': 'https://example.com',
  'verification': {'type': 'verified'},
  'pinnedPost': {'uri': 'at://did:plc:test123/app.bsky.feed.post/pinned123', 'cid': 'cid123'},
  if (withViewer)
    'viewer': {
      'following': 'at://did:plc:viewer/app.bsky.graph.follow/abc123',
      'muted': false,
      'blockedBy': false,
    },
};

Map<String, dynamic> _mockAuthorFeedResponse({String? cursor = 'next_cursor'}) => {
  'feed': [
    {
      'post': {
        'uri': 'at://did:plc:test123/app.bsky.feed.post/1',
        'cid': 'cid1',
        'author': {
          'did': 'did:plc:test123',
          'handle': 'testuser.bsky.social',
          'displayName': 'Test User',
        },
        'record': {'text': 'Hello world'},
        'indexedAt': '2024-01-01T12:00:00.000Z',
        'replyCount': 5,
        'repostCount': 3,
        'likeCount': 10,
      },
    },
    {
      'post': {
        'uri': 'at://did:plc:test123/app.bsky.feed.post/2',
        'cid': 'cid2',
        'author': {'did': 'did:plc:test123', 'handle': 'testuser.bsky.social'},
        'record': {'text': 'Second post'},
        'indexedAt': '2024-01-02T12:00:00.000Z',
      },
    },
  ],
  if (cursor != null) 'cursor': cursor,
};

Map<String, dynamic> _mockFollowersResponse({String? cursor}) => {
  'followers': [
    {
      'did': 'did:plc:follower1',
      'handle': 'follower1.bsky.social',
      'displayName': 'Follower One',
      'avatar': 'https://example.com/f1.jpg',
    },
    {'did': 'did:plc:follower2', 'handle': 'follower2.bsky.social'},
  ],
  if (cursor != null) 'cursor': cursor,
};

Map<String, dynamic> _mockFollowsResponse({String? cursor}) => {
  'follows': [
    {
      'did': 'did:plc:following1',
      'handle': 'following1.bsky.social',
      'displayName': 'Following One',
    },
  ],
  if (cursor != null) 'cursor': cursor,
};
