import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/feeds/infrastructure/post_interaction_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/post_interactions_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';
import 'package:mocktail/mocktail.dart';

class MockXrpcClient extends Mock implements XrpcClient {}

class MockPostInteractionsDao extends Mock implements PostInteractionsDao {}

class MockLogger extends Mock implements Logger {}

void main() {
  late MockXrpcClient api;
  late MockPostInteractionsDao dao;
  late MockLogger logger;
  late PostInteractionRepository repository;

  const ownerDid = 'did:plc:owner';
  const postUri = 'at://did:plc:author/app.bsky.feed.post/123';
  const postCid = 'bafyreih57axcs6fyz2p2y27i3m2j2';

  setUpAll(() {
    registerFallbackValue(
      PostInteractionsCompanion.insert(
        postUri: 'dummy',
        ownerDid: 'dummy',
        updatedAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    api = MockXrpcClient();
    dao = MockPostInteractionsDao();
    logger = MockLogger();
    repository = PostInteractionRepository(api, dao, logger);

    when(() => logger.info(any(), any())).thenReturn(null);
    when(() => logger.error(any(), any(), any())).thenReturn(null);
  });

  group('PostInteractionRepository', () {
    test('like optimistic update and API call success', () async {
      when(() => dao.upsertInteraction(any())).thenAnswer((_) async => {});
      when(
        () => api.call('com.atproto.repo.createRecord', body: any(named: 'body')),
      ).thenAnswer((_) async => {'uri': 'at://did:plc:owner/app.bsky.feed.like/456'});

      await repository.like(postUri, postCid, ownerDid);

      verify(() => dao.upsertInteraction(any())).called(2);
      verify(() => api.call('com.atproto.repo.createRecord', body: any(named: 'body'))).called(1);
    });

    test('like rollback on API failure', () async {
      when(() => dao.upsertInteraction(any())).thenAnswer((_) async => {});
      when(
        () => api.call('com.atproto.repo.createRecord', body: any(named: 'body')),
      ).thenThrow(Exception('API Error'));

      try {
        await repository.like(postUri, postCid, ownerDid);
        fail('Should have thrown');
      } catch (_) {
        /* Expected */
      }

      verify(() => dao.upsertInteraction(any())).called(2);
    });

    test('repost rollback on API failure', () async {
      when(() => dao.upsertInteraction(any())).thenAnswer((_) async => {});
      when(
        () => api.call('com.atproto.repo.createRecord', body: any(named: 'body')),
      ).thenThrow(Exception('API Error'));

      try {
        await repository.repost(postUri, postCid, ownerDid);
        fail('Should have thrown');
      } catch (_) {
        /* Expected */
      }

      verify(() => dao.upsertInteraction(any())).called(2);
    });

    test('bookmark rollback on API failure', () async {
      when(() => dao.upsertInteraction(any())).thenAnswer((_) async => {});
      when(
        () => api.call('app.bsky.bookmark.createBookmark', body: any(named: 'body')),
      ).thenThrow(Exception('API Error'));

      try {
        await repository.bookmark(postUri, postCid, ownerDid);
        fail('Should have thrown');
      } catch (_) {
        /* Expected */
      }

      verify(() => dao.upsertInteraction(any())).called(2);
    });

    test('repost optimistic update and API call success', () async {
      when(() => dao.upsertInteraction(any())).thenAnswer((_) async => {});
      when(
        () => api.call('com.atproto.repo.createRecord', body: any(named: 'body')),
      ).thenAnswer((_) async => {'uri': 'at://did:plc:owner/app.bsky.feed.repost/789'});

      await repository.repost(postUri, postCid, ownerDid);

      verify(() => dao.upsertInteraction(any())).called(2);
      verify(() => api.call('com.atproto.repo.createRecord', body: any(named: 'body'))).called(1);
    });

    test('bookmark optimistic update and API call success', () async {
      when(() => dao.upsertInteraction(any())).thenAnswer((_) async => {});
      when(
        () => api.call('app.bsky.bookmark.createBookmark', body: any(named: 'body')),
      ).thenAnswer((_) async => {'uri': 'at://did:plc:owner/app.bsky.bookmark/abc'});

      await repository.bookmark(postUri, postCid, ownerDid);

      verify(() => dao.upsertInteraction(any())).called(2);
      verify(
        () => api.call('app.bsky.bookmark.createBookmark', body: any(named: 'body')),
      ).called(1);
    });

    test('unbookmark optimistic update and API call success', () async {
      when(() => dao.upsertInteraction(any())).thenAnswer((_) async => {});
      when(
        () => api.call('app.bsky.bookmark.deleteBookmark', body: any(named: 'body')),
      ).thenAnswer((_) async => {});

      await repository.unbookmark(postUri, 'at://did:plc:owner/app.bsky.bookmark/abc', ownerDid);

      verify(() => dao.upsertInteraction(any())).called(1);
      verify(
        () => api.call('app.bsky.bookmark.deleteBookmark', body: any(named: 'body')),
      ).called(1);
    });
  });
}
