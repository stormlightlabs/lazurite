import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lazurite/core/network/actor_repository_service_resolver.dart';

import '../../helpers/fixtures/network.dart';

void main() {
  group('ActorRepositoryServiceResolver', () {
    test('resolves handle through public identity host and then DID doc', () async {
      final requestedUris = <Uri>[];
      final resolver = ActorRepositoryServiceResolver(
        resolveHandleHost: 'bsky.social',
        httpClient: MockClient((request) async {
          requestedUris.add(request.url);
          if (request.url.host == 'bsky.social' && request.url.path == '/xrpc/com.atproto.identity.resolveHandle') {
            return http.Response(jsonEncode({'did': 'did:plc:alice'}), 200);
          }
          if (request.url.host == 'plc.directory' && request.url.path == '/did:plc:alice') {
            return http.Response(
              jsonEncode(testDidDocument(serviceEndpoint: 'https://alice.us-east.host.bsky.network')),
              200,
            );
          }
          return http.Response('not found', 404);
        }),
      );

      final result = await resolver.resolve('alice.bsky.social');

      expect(result.did, 'did:plc:alice');
      expect(result.pdsHost, 'alice.us-east.host.bsky.network');
      expect(requestedUris, hasLength(2));
      expect(requestedUris.first.host, 'bsky.social');
      expect(requestedUris.first.queryParameters['handle'], 'alice.bsky.social');
      expect(requestedUris.last.host, 'plc.directory');
    });

    test('resolves did:web documents using did:web path mapping', () async {
      final requestedUris = <Uri>[];
      final resolver = ActorRepositoryServiceResolver(
        httpClient: MockClient((request) async {
          requestedUris.add(request.url);
          if (request.url.host == 'example.com' && request.url.path == '/users/alice/did.json') {
            return http.Response(jsonEncode(testDidDocument(serviceEndpoint: 'https://pds.example.com')), 200);
          }
          return http.Response('not found', 404);
        }),
      );

      final result = await resolver.resolve('did:web:example.com:users:alice');

      expect(result.did, 'did:web:example.com:users:alice');
      expect(result.pdsHost, 'pds.example.com');
      expect(requestedUris, hasLength(1));
      expect(requestedUris.single.host, 'example.com');
      expect(requestedUris.single.path, '/users/alice/did.json');
    });

    test('tries fallback identity hosts when preferred host fails', () async {
      final requestedHosts = <String>[];
      final resolver = ActorRepositoryServiceResolver(
        resolveHandleHost: 'identity.invalid',
        httpClient: MockClient((request) async {
          requestedHosts.add(request.url.host);
          if (request.url.host == 'identity.invalid') {
            return http.Response('bad gateway', 502);
          }
          if (request.url.host == 'bsky.social') {
            return http.Response(jsonEncode({'did': 'did:plc:fallback'}), 200);
          }
          if (request.url.host == 'plc.directory' && request.url.path == '/did:plc:fallback') {
            return http.Response(jsonEncode(testDidDocument(serviceEndpoint: 'https://fallback.host')), 200);
          }
          return http.Response('not found', 404);
        }),
      );

      final result = await resolver.resolve('fallback.bsky.social');

      expect(result.did, 'did:plc:fallback');
      expect(result.pdsHost, 'fallback.host');
      expect(requestedHosts.first, 'identity.invalid');
      expect(requestedHosts.where((host) => host == 'bsky.social').isNotEmpty, isTrue);
    });

    test('caches actor resolution and avoids duplicate network requests', () async {
      var callCount = 0;
      final resolver = ActorRepositoryServiceResolver(
        httpClient: MockClient((request) async {
          callCount++;
          if (request.url.host == 'bsky.social') {
            return http.Response(jsonEncode({'did': 'did:plc:cache'}), 200);
          }
          if (request.url.host == 'plc.directory') {
            return http.Response(jsonEncode(testDidDocument(serviceEndpoint: 'https://cache.host')), 200);
          }
          return http.Response('not found', 404);
        }),
      );

      final first = await resolver.resolve('cache.bsky.social');
      final second = await resolver.resolve('cache.bsky.social');

      expect(first.did, second.did);
      expect(first.pdsHost, second.pdsHost);
      expect(callCount, 2);
    });
  });
}
