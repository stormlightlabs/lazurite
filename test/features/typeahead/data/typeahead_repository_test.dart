import 'dart:convert';
import 'dart:io';

import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/actor/search_actors_typeahead.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lazurite/core/network/poptart_client_adapter.dart' show Bluesky;
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_result.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_bluesky_client.dart';

class MockModerationService extends Mock implements ModerationService {}

void main() {
  late MockModerationService moderationService;

  setUpAll(() {
    registerFallbackValue(const ProfileViewBasic(did: 'did:plc:fallback', handle: 'fallback.bsky.social'));
  });

  setUp(() {
    moderationService = MockModerationService();
    when(() => moderationService.headersForRequest()).thenAnswer((_) async => const {'x-test': 'moderation'});
    when(() => moderationService.shouldFilterProfileBasicInList(any())).thenReturn(false);
  });

  group('TypeaheadRepository', () {
    test('bluesky provider uses public HTTP endpoint and applies moderation filtering', () async {
      Uri? requestedUri;
      Map<String, String>? requestHeaders;
      final client = _CallbackClient((request) async {
        requestedUri = request.url;
        requestHeaders = request.headers;
        return http.Response(
          jsonEncode({
            'actors': [
              {'did': 'did:plc:keep', 'handle': 'keep.bsky.social'},
              {'did': 'did:plc:hide', 'handle': 'hide.bsky.social'},
            ],
          }),
          200,
        );
      });

      when(
        () => moderationService.shouldFilterProfileBasicInList(
          any(that: isA<ProfileViewBasic>().having((p) => p.did, 'did', 'did:plc:hide')),
        ),
      ).thenReturn(true);

      final repository = TypeaheadRepository(
        bluesky: _fakeBlueskyClient(actor: _FakeActorService()),
        provider: TypeaheadRepository.blueskyProvider,
        moderationService: moderationService,
        httpClient: client,
      );

      final results = await repository.search(query: 'keep', limit: 5);

      expect(results.map((actor) => actor.did).toList(), ['did:plc:keep']);
      expect(requestedUri?.host, 'public.api.bsky.app');
      expect(requestedUri?.path, '/xrpc/app.bsky.actor.searchActorsTypeahead');
      expect(requestedUri?.queryParameters['q'], 'keep');
      expect(requestedUri?.queryParameters['limit'], '5');
      expect(requestHeaders?['x-test'], 'moderation');
      expect(requestHeaders?['atproto-proxy'], isNull);
    });

    test('community provider makes HTTP request, parses JSON, and applies local moderation', () async {
      Uri? requestedUri;
      Map<String, String>? requestHeaders;

      final client = _CallbackClient((request) async {
        requestedUri = request.url;
        requestHeaders = request.headers;

        return http.Response(
          jsonEncode({
            'actors': [
              {
                'did': 'did:plc:keep',
                'handle': 'keep.bsky.social',
                'displayName': 'Keep',
                'avatar': 'https://cdn.example/keep.png',
                'labels': [
                  {
                    r'$type': 'com.atproto.label.defs#label',
                    'src': 'did:plc:labeler',
                    'uri': 'at://did:plc:keep/app.bsky.actor.profile/self',
                    'val': 'spam',
                    'cts': '2026-04-28T00:00:00.000Z',
                  },
                ],
              },
              {'did': 'did:plc:hide', 'handle': 'hide.bsky.social'},
            ],
          }),
          200,
        );
      });

      when(
        () => moderationService.shouldFilterProfileBasicInList(
          any(that: isA<ProfileViewBasic>().having((p) => p.did, 'did', 'did:plc:hide')),
        ),
      ).thenReturn(true);

      final repository = TypeaheadRepository(
        provider: TypeaheadRepository.communityProvider,
        moderationService: moderationService,
        httpClient: client,
      );

      final results = await repository.search(query: 'keep', limit: 12);

      expect(results, hasLength(1));
      expect(results.single.did, 'did:plc:keep');
      expect(results.single.handle, 'keep.bsky.social');
      expect(results.single.displayName, 'Keep');
      expect(results.single.avatarUrl, 'https://cdn.example/keep.png');
      expect(results.single.labels, isNotEmpty);

      expect(requestedUri, isNotNull);
      expect(requestedUri!.scheme, 'https');
      expect(requestedUri!.host, 'typeahead.waow.tech');
      expect(requestedUri!.path, '/xrpc/app.bsky.actor.searchActorsTypeahead');
      expect(requestedUri!.queryParameters['q'], 'keep');
      expect(requestedUri!.queryParameters['limit'], '12');
      expect(requestHeaders?['X-Client'], 'lazurite');
    });

    test('community fallback triggers on error when Bluesky is available', () async {
      final actorService = _FakeActorService()
        ..searchActorsResult = const _FakeActorsData(
          actors: [ProfileViewBasic(did: 'did:plc:fallback', handle: 'fallback.bsky.social')],
        );

      final client = _CallbackClient((request) async {
        if (request.url.host == 'typeahead.waow.tech') {
          return http.Response('upstream unavailable', 503);
        }
        return http.Response(
          jsonEncode({
            'actors': [
              {'did': 'did:plc:fallback', 'handle': 'fallback.bsky.social'},
            ],
          }),
          200,
        );
      });

      final repository = TypeaheadRepository(
        bluesky: _fakeBlueskyClient(actor: actorService),
        provider: TypeaheadRepository.communityProvider,
        moderationService: moderationService,
        httpClient: client,
      );

      final results = await repository.search(query: 'fallback', limit: 8);

      expect(results.map((actor) => actor.did).toList(), ['did:plc:fallback']);
      expect(actorService.lastQuery, isNull);
    });

    test('provider resolver picks up runtime provider changes without recreating repository', () async {
      var selectedProvider = TypeaheadRepository.communityProvider;
      var communityCalls = 0;

      final actorService = _FakeActorService()
        ..searchActorsResult = const _FakeActorsData(
          actors: [ProfileViewBasic(did: 'did:plc:bluesky', handle: 'bluesky.bsky.social')],
        );
      final client = _CallbackClient((request) async {
        if (request.url.host == 'typeahead.waow.tech') {
          communityCalls += 1;
          return http.Response(
            jsonEncode({
              'actors': [
                {'did': 'did:plc:community', 'handle': 'community.bsky.social'},
              ],
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'actors': [
              {'did': 'did:plc:bluesky', 'handle': 'bluesky.bsky.social'},
            ],
          }),
          200,
        );
      });

      final repository = TypeaheadRepository(
        bluesky: _fakeBlueskyClient(actor: actorService),
        providerResolver: () => selectedProvider,
        moderationService: moderationService,
        httpClient: client,
      );

      final communityResults = await repository.search(query: 'first', limit: 3);
      expect(communityResults.map((actor) => actor.did).toList(), ['did:plc:community']);
      expect(communityCalls, 1);
      expect(actorService.lastQuery, isNull);

      selectedProvider = TypeaheadRepository.blueskyProvider;

      final blueskyResults = await repository.search(query: 'second', limit: 4);
      expect(blueskyResults.map((actor) => actor.did).toList(), ['did:plc:bluesky']);
      expect(communityCalls, 1);
      expect(actorService.lastQuery, isNull);
    });

    test('community fallback does not trigger when no Bluesky session/client exists', () async {
      final client = _CallbackClient((_) async => throw const SocketException('no route to host'));

      final repository = TypeaheadRepository(
        provider: TypeaheadRepository.communityProvider,
        moderationService: moderationService,
        httpClient: client,
      );

      expect(() => repository.search(query: 'alice', limit: 5), throwsA(isA<SocketException>()));
    });

    test('bluesky provider uses public HTTP endpoint when SDK client is unavailable', () async {
      Uri? requestedUri;
      Map<String, String>? requestHeaders;

      final client = _CallbackClient((request) async {
        requestedUri = request.url;
        requestHeaders = request.headers;
        return http.Response(
          jsonEncode({
            'actors': [
              {'did': 'did:plc:public', 'handle': 'public.bsky.social', 'displayName': 'Public'},
            ],
          }),
          200,
        );
      });

      final repository = TypeaheadRepository(
        provider: TypeaheadRepository.blueskyProvider,
        moderationService: moderationService,
        httpClient: client,
      );

      final results = await repository.search(query: 'public', limit: 6);

      expect(results, hasLength(1));
      expect(results.single.did, 'did:plc:public');
      expect(results.single.handle, 'public.bsky.social');
      expect(results.single.displayName, 'Public');
      expect(requestedUri, isNotNull);
      expect(requestedUri!.scheme, 'https');
      expect(requestedUri!.host, 'public.api.bsky.app');
      expect(requestedUri!.path, '/xrpc/app.bsky.actor.searchActorsTypeahead');
      expect(requestedUri!.queryParameters['q'], 'public');
      expect(requestedUri!.queryParameters['limit'], '6');
      expect(requestHeaders?['X-Client'], 'lazurite');
      expect(requestHeaders?['x-test'], 'moderation');
      expect(requestHeaders?['atproto-proxy'], isNull);
    });

    test('search returns empty list for empty/whitespace queries', () async {
      final client = _CallbackClient((_) async => throw StateError('Should not be called'));

      final repository = TypeaheadRepository(
        provider: TypeaheadRepository.communityProvider,
        moderationService: moderationService,
        httpClient: client,
      );

      expect(await repository.search(query: ''), isEmpty);
      expect(await repository.search(query: '   '), isEmpty);
    });
  });

  group('TypeaheadResult', () {
    test('fromJson parses community payload', () {
      final result = TypeaheadResult.fromJson({
        'did': 'did:plc:alice',
        'handle': 'alice.bsky.social',
        'displayName': 'Alice',
        'avatar': 'https://cdn.example/avatar.png',
      });

      expect(result.did, 'did:plc:alice');
      expect(result.handle, 'alice.bsky.social');
      expect(result.displayName, 'Alice');
      expect(result.avatarUrl, 'https://cdn.example/avatar.png');
      expect(result.labels, isEmpty);
    });
  });
}

Bluesky _fakeBlueskyClient({required _FakeActorService actor}) => testBluesky(getClient: actor.get);

class _FakeActorService {
  _FakeActorsData? searchActorsResult;
  String? lastQuery;
  int? lastLimit;
  Map<String, String>? lastHeaders;

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    if (url.pathSegments.last != 'app.bsky.actor.searchActorsTypeahead') {
      return unexpectedGetClient(url, headers: headers);
    }

    lastQuery = url.queryParameters['q'];
    lastLimit = int.tryParse(url.queryParameters['limit'] ?? '');
    lastHeaders = headers;
    return jsonResponse(url, 'GET', ActorSearchActorsTypeaheadOutput(actors: searchActorsResult!.actors).toJson());
  }
}

class _FakeActorsData {
  const _FakeActorsData({required this.actors});

  final List<ProfileViewBasic> actors;
}

class _CallbackClient implements http.Client {
  _CallbackClient(this._handler);

  final Future<http.Response> Function(http.Request request) _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final httpRequest = http.Request(request.method, request.url)
      ..headers.addAll(request.headers)
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..persistentConnection = request.persistentConnection;

    if (request is http.Request) {
      httpRequest.bodyBytes = request.bodyBytes;
    }

    final response = await _handler(httpRequest);
    return http.StreamedResponse(
      Stream<List<int>>.fromIterable([response.bodyBytes]),
      response.statusCode,
      contentLength: response.contentLength,
      request: request,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
    );
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final request = http.Request('GET', url);
    if (headers != null) {
      request.headers.addAll(headers);
    }

    return _handler(request);
  }

  @override
  void close() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
