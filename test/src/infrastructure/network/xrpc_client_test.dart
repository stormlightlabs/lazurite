import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:lazurite/src/infrastructure/network/network_failure.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late Dio publicDio;
  late Dio pdsDio;
  late Dio videoServiceDio;
  late Dio klipyDio;
  late DioAdapter publicAdapter;
  late DioAdapter pdsAdapter;
  late XrpcClient client;

  setUp(() {
    publicDio = Dio(BaseOptions(baseUrl: 'https://public.api.bsky.app'));
    pdsDio = Dio(BaseOptions(baseUrl: 'https://user.pds.example'));
    videoServiceDio = Dio(BaseOptions(baseUrl: 'https://video.bsky.app'));
    klipyDio = Dio(BaseOptions(baseUrl: 'https://api.klipy.com'));
    publicAdapter = DioAdapter(dio: publicDio);
    pdsAdapter = DioAdapter(dio: pdsDio);
    DioAdapter(dio: videoServiceDio);
    client = XrpcClient(
      publicDio: publicDio,
      pdsDio: pdsDio,
      videoServiceDio: videoServiceDio,
      klipyDio: klipyDio,
      logger: MockLogger(),
    );
  });

  group('XrpcClient routing (Unauthenticated)', () {
    late XrpcClient unauthedClient;

    setUp(() {
      unauthedClient = XrpcClient(
        publicDio: publicDio,
        pdsDio: null,
        videoServiceDio: videoServiceDio,
        klipyDio: klipyDio,
        logger: MockLogger(),
      );
    });

    test('routes public endpoints to public Dio', () async {
      publicAdapter.onGet(
        '/xrpc/app.bsky.feed.getPostThread',
        (server) => server.reply(200, {
          'thread': {'post': {}},
        }),
        queryParameters: {'uri': 'at://did:plc:test/app.bsky.feed.post/123'},
      );

      final result = await unauthedClient.call(
        'app.bsky.feed.getPostThread',
        params: {'uri': 'at://did:plc:test/app.bsky.feed.post/123'},
      );

      expect(result, containsPair('thread', isA<Map>()));
    });

    test('throws StateError for pds endpoints', () {
      expect(() => unauthedClient.call('app.bsky.feed.getTimeline'), throwsA(isA<StateError>()));
    });
  });

  group('XrpcClient routing (Authenticated)', () {
    test('prefers PDS for public endpoints when authed', () async {
      pdsAdapter.onGet(
        '/xrpc/app.bsky.feed.getPostThread',
        (server) => server.reply(200, {
          'thread': {'post': {}},
        }),
        queryParameters: {'uri': 'at://did:plc:test/app.bsky.feed.post/123'},
      );

      final result = await client.call(
        'app.bsky.feed.getPostThread',
        params: {'uri': 'at://did:plc:test/app.bsky.feed.post/123'},
      );

      expect(result, containsPair('thread', isA<Map>()));
    });

    test('routes to PDS for authenticated endpoints', () async {
      pdsAdapter.onGet(
        '/xrpc/app.bsky.feed.getTimeline',
        (server) => server.reply(200, {'feed': []}),
      );

      await client.call('app.bsky.feed.getTimeline');
    });

    test('routes POST endpoints correctly', () async {
      pdsAdapter.onPost(
        '/xrpc/com.atproto.repo.createRecord',
        (server) => server.reply(200, {
          'uri': 'at://did:plc:test/app.bsky.feed.post/456',
          'cid': 'bafyreib...',
        }),
        data: Matchers.any,
      );

      final result = await client.call(
        'com.atproto.repo.createRecord',
        body: {
          'repo': 'did:plc:test',
          'collection': 'app.bsky.feed.post',
          'record': {'text': 'Hello world'},
        },
      );

      expect(result, containsPair('uri', startsWith('at://')));
      expect(result, containsPair('cid', startsWith('bafyrei')));
    });
  });

  group('XrpcClient error handling', () {
    test('throws ArgumentError for unknown NSID', () {
      expect(() => client.call('unknown.endpoint'), throwsA(isA<ArgumentError>()));
    });

    test('throws StateError when PDS not configured for auth endpoint', () {
      final publicOnlyClient = XrpcClient(
        publicDio: publicDio,
        pdsDio: null,
        videoServiceDio: videoServiceDio,
        klipyDio: klipyDio,
        logger: MockLogger(),
      );

      expect(() => publicOnlyClient.call('app.bsky.feed.getTimeline'), throwsA(isA<StateError>()));
    });

    test('converts 401 to AuthFailure', () async {
      pdsAdapter.onGet(
        '/xrpc/app.bsky.feed.getTimeline',
        (server) => server.reply(401, {'error': 'AuthFailed'}),
      );

      expect(() => client.call('app.bsky.feed.getTimeline'), throwsA(isA<AuthFailure>()));
    });

    test('converts 429 to RateLimitFailure', () async {
      pdsAdapter.onGet(
        '/xrpc/app.bsky.feed.getTimeline',
        (server) => server.reply(429, {'error': 'RateLimited', 'message': 'Too many requests'}),
      );

      expect(() => client.call('app.bsky.feed.getTimeline'), throwsA(isA<RateLimitFailure>()));
    });

    test('includes retry-after from header', () async {
      pdsAdapter.onGet(
        '/xrpc/app.bsky.feed.getTimeline',
        (server) => server.reply(429, {'error': 'RateLimited'}),
      );

      expect(() => client.call('app.bsky.feed.getTimeline'), throwsA(isA<RateLimitFailure>()));
    });

    test('converts 400 to ClientFailure', () async {
      pdsAdapter.onGet(
        '/xrpc/app.bsky.feed.getTimeline',
        (server) => server.reply(400, {'error': 'BadRequest'}),
      );

      expect(() => client.call('app.bsky.feed.getTimeline'), throwsA(isA<ClientFailure>()));
    });

    test('converts 500 to ServerFailure', () async {
      pdsAdapter.onGet('/xrpc/app.bsky.feed.getTimeline', (server) => server.reply(500, {}));

      expect(() => client.call('app.bsky.feed.getTimeline'), throwsA(isA<ServerFailure>()));
    });

    test('includes error message from response', () async {
      pdsAdapter.onGet(
        '/xrpc/app.bsky.feed.getTimeline',
        (server) => server.reply(400, {'error': 'InvalidRequest', 'message': 'Bad query'}),
      );

      try {
        await client.call('app.bsky.feed.getTimeline');
        fail('Should have thrown ClientFailure');
      } on ClientFailure catch (e) {
        expect(e.message, equals('Bad query'));
      }
    });
  });

  group('XrpcClient response parsing', () {
    test('returns empty map for null response', () async {
      pdsAdapter.onGet('/xrpc/app.bsky.feed.getTimeline', (server) => server.reply(200, null));

      final result = await client.call('app.bsky.feed.getTimeline');
      expect(result, equals({}));
    });

    test('returns map for object response', () async {
      pdsAdapter.onGet(
        '/xrpc/app.bsky.feed.getTimeline',
        (server) => server.reply(200, {'feed': []}),
      );

      final result = await client.call('app.bsky.feed.getTimeline');
      expect(result, isA<Map<String, dynamic>>());
    });

    test('converts non-string-keyed map', () async {
      final mockDio = MockDio();
      final mockResponse = Response<dynamic>(
        data: {1: 'one', 2: 'two'},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/xrpc/app.bsky.feed.getTimeline'),
      );

      when(
        () => mockDio.get<dynamic>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final testClient = XrpcClient(
        publicDio: mockDio,
        pdsDio: mockDio,
        videoServiceDio: videoServiceDio,
        klipyDio: klipyDio,
        logger: MockLogger(),
      );

      final result = await testClient.call('app.bsky.feed.getTimeline');
      expect(result, containsPair('1', 'one'));
      expect(result, containsPair('2', 'two'));
    });

    test('throws DecodeFailure for unexpected response type', () async {
      pdsAdapter.onGet(
        '/xrpc/app.bsky.feed.getTimeline',
        (server) => server.reply(200, 'string response'),
      );

      expect(() => client.call('app.bsky.feed.getTimeline'), throwsA(isA<DecodeFailure>()));
    });
  });

  group('XrpcClient.callRaw', () {
    test('returns raw Response object', () async {
      pdsAdapter.onGet(
        '/xrpc/app.bsky.feed.getTimeline',
        (server) => server.reply(200, {'feed': []}),
      );

      final response = await client.callRaw<Map<String, dynamic>>('app.bsky.feed.getTimeline');

      expect(response, isA<Response>());
      expect(response.statusCode, equals(200));
      expect(response.data, isA<Map>());
    });

    test('supports custom response type', () async {
      pdsAdapter.onGet(
        '/xrpc/app.bsky.feed.getTimeline',
        (server) => server.reply(200, '{"feed": []}'),
      );

      final response = await client.callRaw<String>(
        'app.bsky.feed.getTimeline',
        responseType: ResponseType.plain,
      );

      expect(response.data, isA<String>());
    });
  });
}
