import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lazurite/core/network/slingshot_client.dart';

void main() {
  group('SlingshotClient', () {
    test('uses default base URL when none provided', () async {
      Uri? capturedUri;
      final client = SlingshotClient(
        httpClient: MockClient((request) async {
          capturedUri = request.url;
          return http.Response(
            jsonEncode({'did': 'did:plc:test', 'handle': 'test.bsky.social', 'pds': 'bsky.social'}),
            200,
          );
        }),
      );

      await client.resolveMiniDoc('test.bsky.social');
      expect(capturedUri?.host, equals('slingshot.microcosm.blue'));
    });

    test('sends identifier query parameter and user-agent header', () async {
      Uri? capturedUri;
      Map<String, String>? capturedHeaders;
      final client = SlingshotClient(
        baseUrl: 'https://example.com/',
        httpClient: MockClient((request) async {
          capturedUri = request.url;
          capturedHeaders = request.headers;
          return http.Response(
            jsonEncode({'did': 'did:plc:test', 'handle': 'test.bsky.social', 'pds': 'bsky.social'}),
            200,
          );
        }),
      );

      await client.resolveMiniDoc('test.bsky.social');
      expect(capturedUri?.path, equals('/xrpc/com.bad-example.identity.resolveMiniDoc'));
      expect(capturedUri?.queryParameters['identifier'], equals('test.bsky.social'));
      expect(capturedHeaders?['User-Agent'], equals('lazurite'));
    });

    test('parses required fields', () async {
      final client = SlingshotClient(
        httpClient: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'did': 'did:plc:test',
              'handle': 'test.bsky.social',
              'pds': 'https://pds.example.com',
              'signing_key': 'did:key:z123',
            }),
            200,
          ),
        ),
      );

      final miniDoc = await client.resolveMiniDoc('test.bsky.social');
      expect(miniDoc.did, equals('did:plc:test'));
      expect(miniDoc.handle, equals('test.bsky.social'));
      expect(miniDoc.pds, equals('https://pds.example.com'));
      expect(miniDoc.signingKey, equals('did:key:z123'));
    });

    test('throws SlingshotException on non-200 response', () async {
      final client = SlingshotClient(httpClient: MockClient((_) async => http.Response('upstream error', 503)));

      expect(() => client.resolveMiniDoc('test.bsky.social'), throwsA(isA<SlingshotException>()));
    });

    test('throws SlingshotException when payload is missing required fields', () async {
      final client = SlingshotClient(
        httpClient: MockClient(
          (_) async => http.Response(jsonEncode({'did': 'did:plc:test', 'handle': 'test.bsky.social'}), 200),
        ),
      );

      expect(() => client.resolveMiniDoc('test.bsky.social'), throwsA(isA<SlingshotException>()));
    });
  });
}
