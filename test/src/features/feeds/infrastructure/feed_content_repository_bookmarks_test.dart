import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_content_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/feed_content_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';
import 'package:mocktail/mocktail.dart';

class MockXrpcClient extends Mock implements XrpcClient {}

class MockFeedContentDao extends Mock implements FeedContentDao {}

class MockLogger extends Mock implements Logger {}

void main() {
  late MockXrpcClient mockApi;
  late MockFeedContentDao mockDao;
  late MockLogger mockLogger;
  late FeedContentRepository repository;

  setUp(() {
    mockApi = MockXrpcClient();
    mockDao = MockFeedContentDao();
    mockLogger = MockLogger();
    repository = FeedContentRepository(mockApi, mockDao, mockLogger);
    registerFallbackValue(PostsCompanion.insert(uri: 'a', cid: 'b', authorDid: 'c', record: '{}'));
  });

  group('fetchBookmarks', () {
    test('fetches and caches bookmarks successfully', () async {
      final bookmarkItem = {
        'uri': 'at://did:plc:123/app.bsky.feed.post/456',
        'cid': 'cid-123',
        'author': {
          'did': 'did:plc:author',
          'handle': 'author.bsky.social',
          'displayName': 'Author',
          'avatar': 'avatar.jpg',
        },
        'record': {'text': 'Hello world', 'createdAt': '2023-01-01T00:00:00Z'},
        'indexedAt': '2023-01-01T00:00:00Z',
        'replyCount': 0,
        'repostCount': 0,
        'likeCount': 0,
      };

      when(() => mockApi.call(any(), params: any(named: 'params'))).thenAnswer(
        (_) async => {
          'bookmarks': [
            {'post': bookmarkItem},
          ],
          'cursor': 'next-cursor',
        },
      );

      when(
        () => mockDao.insertFeedContentBatch(
          feedKey: any(named: 'feedKey'),
          ownerDid: any(named: 'ownerDid'),
          newPosts: any(named: 'newPosts'),
          newProfiles: any(named: 'newProfiles'),
          newRelationships: any(named: 'newRelationships'),
          newItems: any(named: 'newItems'),
          newCursor: any(named: 'newCursor'),
        ),
      ).thenAnswer((_) async {});

      await repository.fetchBookmarks(ownerDid: 'did:plc:me');

      verify(
        () => mockApi.call('app.bsky.bookmark.getBookmarks', params: {'limit': 50}),
      ).called(1);

      verify(
        () => mockDao.insertFeedContentBatch(
          feedKey: '__internal:bookmarks',
          ownerDid: 'did:plc:me',
          newPosts: any(named: 'newPosts'),
          newProfiles: any(named: 'newProfiles'),
          newRelationships: any(named: 'newRelationships'),
          newItems: any(named: 'newItems'),
          newCursor: 'next-cursor',
        ),
      ).called(1);
    });
  });
}
