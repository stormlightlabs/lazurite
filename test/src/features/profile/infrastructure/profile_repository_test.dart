import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';
import 'package:mocktail/mocktail.dart';

class MockXrpcClient extends Mock implements XrpcClient {}

class MockLogger extends Mock implements Logger {}

void main() {
  late MockXrpcClient mockApi;
  late AppDatabase db;
  late MockLogger mockLogger;
  late ProfileRepository repository;

  setUp(() {
    mockApi = MockXrpcClient();
    db = AppDatabase(NativeDatabase.memory());
    mockLogger = MockLogger();
    repository = ProfileRepository(mockApi, db.profileDao, mockLogger);
  });

  tearDown(() async {
    await db.close();
  });

  group('ProfileRepository', () {
    group('getProfile', () {
      test('fetches profile from API and caches it', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockProfileResponse());

        final profile = await repository.getProfile('testuser.bsky.social');

        expect(profile.did, 'did:plc:test123');
        expect(profile.handle, 'testuser.bsky.social');
        expect(profile.displayName, 'Test User');
        expect(profile.followersCount, 100);
        expect(profile.followsCount, 50);
        expect(profile.postsCount, 25);

        verify(
          () =>
              mockApi.call('app.bsky.actor.getProfile', params: {'actor': 'testuser.bsky.social'}),
        ).called(1);

        // Verify cached in DB
        final cached = await db.profileDao.getProfile('did:plc:test123');
        expect(cached, isNotNull);
        expect(cached!.handle, 'testuser.bsky.social');
      });

      test('handles profile without optional fields', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => {'did': 'did:plc:minimal', 'handle': 'minimal.bsky.social'});

        final profile = await repository.getProfile('minimal.bsky.social');

        expect(profile.did, 'did:plc:minimal');
        expect(profile.handle, 'minimal.bsky.social');
        expect(profile.displayName, isNull);
        expect(profile.description, isNull);
        expect(profile.followersCount, 0);
      });

      test('logs error and rethrows on API failure', () async {
        final exception = Exception('Network error');
        when(() => mockApi.call(any(), params: any(named: 'params'))).thenThrow(exception);

        expect(() => repository.getProfile('testuser'), throwsA(isA<Exception>()));

        verify(() => mockLogger.error(any(), exception, any())).called(1);
      });
    });

    group('getCachedProfile', () {
      test('returns cached profile from DAO', () async {
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => _mockProfileResponse());

        await repository.getProfile('testuser.bsky.social');

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

        await repository.getProfile('testuser.bsky.social');

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
  });
}

Map<String, dynamic> _mockProfileResponse() => {
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
