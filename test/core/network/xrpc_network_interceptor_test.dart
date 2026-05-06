import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lazurite/core/network/xrpc_network_interceptor.dart';

void main() {
  group('XrpcNetworkInterceptor', () {
    setUp(XrpcNetworkInterceptor.debugResetForcedUnauthorized);
    tearDown(XrpcNetworkInterceptor.debugResetForcedUnauthorized);

    group('metadataFor', () {
      test('extracts pds, appview, and xrpc method', () {
        final metadata = XrpcNetworkInterceptor.metadataFor(
          Uri.parse('https://shaggymane.us-west.host.bsky.network/xrpc/app.bsky.actor.getPreferences?limit=100'),
          headers: {'atproto-proxy': 'did:web:api.blacksky.community#bsky_appview'},
        );

        expect(metadata.pdsHost, 'shaggymane.us-west.host.bsky.network');
        expect(metadata.appView, 'did:web:api.blacksky.community#bsky_appview');
        expect(metadata.xrpcMethod, 'app.bsky.actor.getPreferences');
      });

      test('handles case-insensitive appview header keys', () {
        final metadata = XrpcNetworkInterceptor.metadataFor(
          Uri.parse('https://example.com/xrpc/app.bsky.feed.getFeed'),
          headers: {'AtProto-Proxy': 'did:web:api.bsky.app#bsky_appview'},
        );

        expect(metadata.appView, 'did:web:api.bsky.app#bsky_appview');
      });

      test('returns defaults for non-xrpc paths and missing appview header', () {
        final metadata = XrpcNetworkInterceptor.metadataFor(Uri.parse('https://example.com/.well-known/did.json'));

        expect(metadata.pdsHost, 'example.com');
        expect(metadata.appView, 'none');
        expect(metadata.xrpcMethod, '<unknown>');
      });
    });

    group('wrap clients', () {
      test('debug hook forces one unauthorized response then clears', () async {
        var calls = 0;
        final wrapped = XrpcNetworkInterceptor.wrapGetClient((url, {headers}) async {
          calls += 1;
          return http.Response('ok', 200, request: http.Request('GET', url));
        });

        XrpcNetworkInterceptor.debugForceUnauthorizedOnce();

        final first = await wrapped(Uri.parse('https://example.com/xrpc/app.bsky.feed.getFeed'));
        final second = await wrapped(Uri.parse('https://example.com/xrpc/app.bsky.feed.getFeed'));

        expect(first.statusCode, 401);
        expect(first.body, contains('Unauthorized'));
        expect(second.statusCode, 200);
        expect(calls, 1);
      });

      test('wrapGetClient delegates request and returns response', () async {
        final wrapped = XrpcNetworkInterceptor.wrapGetClient((url, {headers}) async {
          return http.Response('ok', 200, request: http.Request('GET', url));
        });

        final response = await wrapped(
          Uri.parse('https://example.com/xrpc/app.bsky.actor.getProfile'),
          headers: const {'atproto-proxy': 'did:web:api.bsky.app#bsky_appview'},
        );

        expect(response.statusCode, 200);
        expect(response.body, 'ok');
      });

      test('wrapPostClient delegates request and returns response', () async {
        final wrapped = XrpcNetworkInterceptor.wrapPostClient((url, {headers, body, encoding}) async {
          return http.Response('created', 201, request: http.Request('POST', url));
        });

        final response = await wrapped(
          Uri.parse('https://example.com/xrpc/app.bsky.actor.putPreferences'),
          headers: const {'atproto-proxy': 'did:web:api.blacksky.community#bsky_appview'},
          body: const {'k': 'v'},
        );

        expect(response.statusCode, 201);
        expect(response.body, 'created');
      });

      test('normalizes DPoP signature segment to base64url before request dispatch', () async {
        const originalDpop =
            'eyJhbGciOiJFUzI1NiIsInR5cCI6ImRwb3Arand0In0.eyJzdWIiOiJodHRwczovL2xhenVyaXRlLnN0b3JtbGlnaHRsYWJzLm9yZy9jbGllbnQtbWV0YWRhdGEuanNvbiJ9.Bw==';
        late Map<String, String>? forwardedHeaders;

        final wrapped = XrpcNetworkInterceptor.wrapPostClient((url, {headers, body, encoding}) async {
          forwardedHeaders = headers;
          return http.Response('ok', 200, request: http.Request('POST', url));
        });

        await wrapped(
          Uri.parse('https://example.com/xrpc/com.atproto.server.getSession'),
          headers: {'DPoP': originalDpop},
        );

        expect(forwardedHeaders, isNotNull);
        expect(forwardedHeaders!['DPoP'], isNotNull);
        expect(forwardedHeaders!['DPoP'], isNot(equals(originalDpop)));
        expect(forwardedHeaders!['DPoP']!.split('.').last, equals('Bw'));
      });

      test('leaves headers unchanged when DPoP proof is not a compact JWT', () {
        final headers = {'DPoP': 'not-a-jwt-proof'};
        final normalized = XrpcNetworkInterceptor.normalizeOutgoingHeaders(headers);

        expect(identical(normalized, headers), isTrue);
      });
    });
  });
}
