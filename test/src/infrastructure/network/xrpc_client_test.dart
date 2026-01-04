import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:lazurite/src/infrastructure/network/endpoint_registry.dart';
import 'package:lazurite/src/infrastructure/network/host_kind.dart';
import 'package:lazurite/src/infrastructure/network/network_failure.dart';
import 'package:lazurite/src/infrastructure/network/proxy_kind.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

void main() {
  late Dio publicDio;
  late Dio pdsDio;
  late DioAdapter publicAdapter;
  late DioAdapter pdsAdapter;
  late XrpcClient client;

  setUp(() {
    publicDio = Dio(BaseOptions(baseUrl: 'https://public.api.bsky.app'));
    pdsDio = Dio(BaseOptions(baseUrl: 'https://user.pds.example'));
    publicAdapter = DioAdapter(dio: publicDio);
    pdsAdapter = DioAdapter(dio: pdsDio);
    client = XrpcClient(publicDio: publicDio, pdsDio: pdsDio);
  });

  group('XrpcClient routing', () {
    test('routes public endpoints to public Dio', () async {
      publicAdapter.onGet(
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

    test('routes authenticated endpoints to PDS Dio', () async {
      pdsAdapter.onGet(
        '/xrpc/app.bsky.feed.getTimeline',
        (server) => server.reply(200, {'feed': [], 'cursor': 'next'}),
      );

      final result = await client.call('app.bsky.feed.getTimeline');

      expect(result, containsPair('feed', isA<List>()));
      expect(result, containsPair('cursor', 'next'));
    });

    test('routes chat endpoints to PDS with proxy metadata', () async {
      pdsAdapter.onGet(
        '/xrpc/chat.bsky.convo.listConvos',
        (server) => server.reply(200, {'convos': []}),
      );

      final result = await client.call('chat.bsky.convo.listConvos');

      expect(result, containsPair('convos', isA<List>()));
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
      final publicOnlyClient = XrpcClient(publicDio: publicDio, pdsDio: null);

      expect(() => publicOnlyClient.call('app.bsky.feed.getTimeline'), throwsA(isA<StateError>()));
    });

    test('converts 401 to AuthFailure', () async {
      pdsAdapter.onGet(
        '/xrpc/app.bsky.feed.getTimeline',
        (server) =>
            server.reply(401, {'error': 'AuthenticationRequired', 'message': 'Token expired'}),
      );

      expect(() => client.call('app.bsky.feed.getTimeline'), throwsA(isA<AuthFailure>()));
    });

    test('converts 429 to RateLimitFailure', () async {
      pdsAdapter.onGet(
        '/xrpc/app.bsky.feed.getTimeline',
        (server) =>
            server.reply(429, {'error': 'RateLimitExceeded', 'message': 'Too many requests'}),
      );

      expect(() => client.call('app.bsky.feed.getTimeline'), throwsA(isA<RateLimitFailure>()));
    });

    test('converts 400 to ClientFailure', () async {
      publicAdapter.onGet(
        '/xrpc/app.bsky.feed.getPostThread',
        (server) => server.reply(400, {
          'error': 'InvalidRequest',
          'message': 'Missing required parameter: uri',
        }),
        queryParameters: {'uri': 'test'},
      );

      expect(
        () => client.call('app.bsky.feed.getPostThread', params: {'uri': 'test'}),
        throwsA(isA<ClientFailure>()),
      );
    });

    test('converts 500 to ServerFailure', () async {
      publicAdapter.onGet(
        '/xrpc/app.bsky.feed.getPostThread',
        (server) =>
            server.reply(500, {'error': 'InternalServerError', 'message': 'Something went wrong'}),
        queryParameters: {'uri': 'test'},
      );

      expect(
        () => client.call('app.bsky.feed.getPostThread', params: {'uri': 'test'}),
        throwsA(isA<ServerFailure>()),
      );
    });
  });

  group('XrpcClient response parsing', () {
    test('parses Map<String, dynamic> response', () async {
      publicAdapter.onGet(
        '/xrpc/app.bsky.actor.getProfile',
        (server) => server.reply(200, {'did': 'did:plc:test', 'handle': 'test.bsky.social'}),
        queryParameters: {'actor': 'test.bsky.social'},
      );

      final result = await client.call(
        'app.bsky.actor.getProfile',
        params: {'actor': 'test.bsky.social'},
      );

      expect(result['did'], equals('did:plc:test'));
      expect(result['handle'], equals('test.bsky.social'));
    });

    test('returns empty map for null response', () async {
      publicAdapter.onGet(
        '/xrpc/com.atproto.identity.resolveHandle',
        (server) => server.reply(204, null),
        queryParameters: {'handle': 'test'},
      );

      final result = await client.call(
        'com.atproto.identity.resolveHandle',
        params: {'handle': 'test'},
      );

      expect(result, isEmpty);
    });
  });

  group('XrpcClient.callRaw', () {
    test('returns raw Response object', () async {
      publicAdapter.onGet(
        '/xrpc/app.bsky.feed.getPostThread',
        (server) => server.reply(200, {'thread': {}}),
        queryParameters: {'uri': 'test'},
      );

      final response = await client.callRaw<Map<String, dynamic>>(
        'app.bsky.feed.getPostThread',
        params: {'uri': 'test'},
      );

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

  group('Endpoint metadata propagation', () {
    test('verifies public endpoints do not require auth', () {
      final registry = EndpointRegistry.instance;
      final publicEndpoint = registry.get('app.bsky.feed.getPostThread');

      expect(publicEndpoint.hostKind, equals(HostKind.publicApi));
      expect(publicEndpoint.requiresAuth, isFalse);
    });

    test('verifies auth endpoints require auth', () {
      final registry = EndpointRegistry.instance;
      final authEndpoint = registry.get('app.bsky.feed.getTimeline');

      expect(authEndpoint.hostKind, equals(HostKind.pds));
      expect(authEndpoint.requiresAuth, isTrue);
    });

    test('verifies chat endpoints use proxy', () {
      final registry = EndpointRegistry.instance;
      final chatEndpoint = registry.get('chat.bsky.convo.listConvos');

      expect(chatEndpoint.hostKind, equals(HostKind.pds));
      expect(chatEndpoint.requiresAuth, isTrue);
      expect(chatEndpoint.proxyKind, equals(ProxyKind.chat));
    });
  });
}
