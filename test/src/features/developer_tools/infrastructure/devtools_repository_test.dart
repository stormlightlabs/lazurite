import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/developer_tools/domain/repo_record.dart';
import 'package:lazurite/src/features/developer_tools/infrastructure/devtools_repository.dart';
import 'package:lazurite/src/infrastructure/network/network_failure.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';
import 'package:mocktail/mocktail.dart';

class MockXrpcClient extends Mock implements XrpcClient {}

class MockLogger extends Mock implements Logger {}

void main() {
  group('DevtoolsRepository', () {
    late MockXrpcClient mockXrpc;
    late MockLogger mockLogger;
    late DevtoolsRepository repository;

    setUp(() {
      mockXrpc = MockXrpcClient();
      mockLogger = MockLogger();
      repository = DevtoolsRepository(mockXrpc, mockLogger);
    });

    group('describeRepo', () {
      const testDid = 'did:plc:test123';

      test('returns list of collections on success', () async {
        final responseData = {
          'collections': [
            {'nsid': 'app.bsky.feed.post', 'count': 42},
            {'nsid': 'app.bsky.actor.profile', 'count': 1},
            {'nsid': 'app.bsky.graph.follow', 'count': 100},
          ],
        };

        when(
          () => mockXrpc.call('com.atproto.repo.describeRepo', params: {'repo': testDid}),
        ).thenAnswer((_) async => responseData);

        final result = await repository.describeRepo(testDid);

        expect(result, hasLength(3));
        expect(result[0].nsid, 'app.bsky.feed.post');
        expect(result[0].count, 42);
        expect(result[1].nsid, 'app.bsky.actor.profile');
        expect(result[1].count, 1);
        expect(result[2].nsid, 'app.bsky.graph.follow');
        expect(result[2].count, 100);

        verify(
          () => mockXrpc.call('com.atproto.repo.describeRepo', params: {'repo': testDid}),
        ).called(1);
      });

      test('returns empty list when collections field is missing', () async {
        when(
          () => mockXrpc.call('com.atproto.repo.describeRepo', params: {'repo': testDid}),
        ).thenAnswer((_) async => {});

        final result = await repository.describeRepo(testDid);

        expect(result, isEmpty);
        verify(
          () => mockLogger.warning('No collections field in describeRepo response', any(), any()),
        ).called(1);
      });

      test('returns empty list when collections is null', () async {
        when(
          () => mockXrpc.call('com.atproto.repo.describeRepo', params: {'repo': testDid}),
        ).thenAnswer((_) async => {'collections': null});

        final result = await repository.describeRepo(testDid);

        expect(result, isEmpty);
        verify(
          () => mockLogger.warning('No collections field in describeRepo response', any(), any()),
        ).called(1);
      });

      test('rethrows network failures', () async {
        const failure = ServerFailure(message: 'Server error', statusCode: 500);

        when(
          () => mockXrpc.call('com.atproto.repo.describeRepo', params: {'repo': testDid}),
        ).thenThrow(failure);

        expect(() => repository.describeRepo(testDid), throwsA(isA<NetworkFailure>()));

        verify(
          () => mockLogger.error('Failed to describe repo for DID: $testDid', failure, any()),
        ).called(1);
      });
    });

    group('listRecords', () {
      const testDid = 'did:plc:test123';
      const testCollection = 'app.bsky.feed.post';

      test('returns records and cursor on success', () async {
        final responseData = {
          'records': [
            {
              'uri': 'at://$testDid/$testCollection/abc123',
              'cid': 'bafyreiabc123',
              'value': {'text': 'Hello world', 'createdAt': '2024-01-01T12:00:00Z'},
            },
            {
              'uri': 'at://$testDid/$testCollection/def456',
              'cid': 'bafyreide456',
              'value': {'text': 'Another post', 'createdAt': '2024-01-01T13:00:00Z'},
            },
          ],
          'cursor': 'next-page-cursor',
        };

        when(
          () => mockXrpc.call('com.atproto.repo.listRecords', params: any(named: 'params')),
        ).thenAnswer((_) async => responseData);

        final result = await repository.listRecords(repo: testDid, collection: testCollection);

        final records = result['records'] as List<RepoRecord>;
        final cursor = result['cursor'] as String?;

        expect(records, hasLength(2));
        expect(records[0].uri, 'at://$testDid/$testCollection/abc123');
        expect(records[0].cid, 'bafyreiabc123');
        expect(records[0].value['text'], 'Hello world');
        expect(cursor, 'next-page-cursor');
      });

      test('returns empty list and null cursor when no records', () async {
        when(
          () => mockXrpc.call('com.atproto.repo.listRecords', params: any(named: 'params')),
        ).thenAnswer((_) async => {'records': []});

        final result = await repository.listRecords(repo: testDid, collection: testCollection);

        final records = result['records'] as List<RepoRecord>;
        final cursor = result['cursor'] as String?;

        expect(records, isEmpty);
        expect(cursor, isNull);
      });

      test('includes all pagination parameters in request', () async {
        when(
          () => mockXrpc.call('com.atproto.repo.listRecords', params: any(named: 'params')),
        ).thenAnswer((_) async => {'records': []});

        await repository.listRecords(
          repo: testDid,
          collection: testCollection,
          limit: 25,
          cursor: 'test-cursor',
          rkeyStart: 'abc',
          rkeyEnd: 'xyz',
          reverse: true,
        );

        verify(
          () => mockXrpc.call(
            'com.atproto.repo.listRecords',
            params: {
              'repo': testDid,
              'collection': testCollection,
              'limit': 25,
              'cursor': 'test-cursor',
              'rkeyStart': 'abc',
              'rkeyEnd': 'xyz',
              'reverse': true,
            },
          ),
        ).called(1);
      });

      test('throws ArgumentError for invalid limit', () async {
        expect(
          () => repository.listRecords(repo: testDid, collection: testCollection, limit: 0),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => repository.listRecords(repo: testDid, collection: testCollection, limit: 101),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => repository.listRecords(repo: testDid, collection: testCollection, limit: -1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('rethrows network failures', () async {
        const failure = AuthFailure(message: 'Unauthorized');

        when(
          () => mockXrpc.call('com.atproto.repo.listRecords', params: any(named: 'params')),
        ).thenThrow(failure);

        expect(
          () => repository.listRecords(repo: testDid, collection: testCollection),
          throwsA(isA<NetworkFailure>()),
        );

        verify(
          () => mockLogger.error(
            'Failed to list records for $testDid/$testCollection',
            failure,
            any(),
          ),
        ).called(1);
      });
    });

    group('getRecord', () {
      const testDid = 'did:plc:test123';
      const testCollection = 'app.bsky.feed.post';
      const testRkey = 'abc123';

      test('returns record on success', () async {
        final responseData = {
          'uri': 'at://$testDid/$testCollection/$testRkey',
          'cid': 'bafyreiabc123',
          'value': {'text': 'Hello world', 'createdAt': '2024-01-01T12:00:00Z'},
          'indexedAt': '2024-01-01T12:01:00Z',
        };

        when(
          () => mockXrpc.call('com.atproto.repo.getRecord', params: any(named: 'params')),
        ).thenAnswer((_) async => responseData);

        final result = await repository.getRecord(
          repo: testDid,
          collection: testCollection,
          rkey: testRkey,
        );

        expect(result, isNotNull);
        expect(result!.uri, 'at://$testDid/$testCollection/$testRkey');
        expect(result.cid, 'bafyreiabc123');
        expect(result.value['text'], 'Hello world');
        expect(result.indexedAt, DateTime.parse('2024-01-01T12:01:00Z'));
      });

      test('includes CID parameter when provided', () async {
        when(
          () => mockXrpc.call('com.atproto.repo.getRecord', params: any(named: 'params')),
        ).thenAnswer(
          (_) async => <String, dynamic>{
            'uri': 'at://$testDid/$testCollection/$testRkey',
            'cid': 'bafyreiabc123',
            'value': <String, dynamic>{},
          },
        );

        await repository.getRecord(
          repo: testDid,
          collection: testCollection,
          rkey: testRkey,
          cid: 'specific-cid',
        );

        verify(
          () => mockXrpc.call(
            'com.atproto.repo.getRecord',
            params: {
              'repo': testDid,
              'collection': testCollection,
              'rkey': testRkey,
              'cid': 'specific-cid',
            },
          ),
        ).called(1);
      });

      test('returns null for incomplete response data', () async {
        when(
          () => mockXrpc.call('com.atproto.repo.getRecord', params: any(named: 'params')),
        ).thenAnswer((_) async => {'uri': 'at://test'});

        final result = await repository.getRecord(
          repo: testDid,
          collection: testCollection,
          rkey: testRkey,
        );

        expect(result, isNull);
        verify(
          () => mockLogger.warning('Incomplete record data in getRecord response', any(), any()),
        ).called(1);
      });

      test('handles missing indexedAt field', () async {
        final responseData = {
          'uri': 'at://$testDid/$testCollection/$testRkey',
          'cid': 'bafyreiabc123',
          'value': {'text': 'Hello world'},
        };

        when(
          () => mockXrpc.call('com.atproto.repo.getRecord', params: any(named: 'params')),
        ).thenAnswer((_) async => responseData);

        final result = await repository.getRecord(
          repo: testDid,
          collection: testCollection,
          rkey: testRkey,
        );

        expect(result, isNotNull);
        expect(result!.indexedAt, isNull);
      });

      test('rethrows network failures', () async {
        const failure = ClientFailure(message: 'Record not found', statusCode: 404);

        when(
          () => mockXrpc.call('com.atproto.repo.getRecord', params: any(named: 'params')),
        ).thenThrow(failure);

        expect(
          () => repository.getRecord(repo: testDid, collection: testCollection, rkey: testRkey),
          throwsA(isA<NetworkFailure>()),
        );

        verify(
          () => mockLogger.error(
            'Failed to get record $testDid/$testCollection/$testRkey',
            failure,
            any(),
          ),
        ).called(1);
      });
    });
  });
}
