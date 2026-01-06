import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/network/interceptors/proxy_interceptor.dart';
import 'package:lazurite/src/infrastructure/network/proxy_kind.dart';

void main() {
  late ProxyInterceptor interceptor;

  setUp(() {
    interceptor = ProxyInterceptor();
  });

  group('ProxyInterceptor', () {
    test('adds atproto-proxy header for chat proxy kind', () async {
      final options = RequestOptions(
        path: '/xrpc/chat.bsky.convo.listConvos',
        extra: {ProxyInterceptor.proxyKindKey: ProxyKind.chat},
      );

      final handler = RequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      expect(
        options.headers[ProxyInterceptor.proxyHeader],
        equals('did:web:api.bsky.chat#bsky_chat'),
      );
    });

    test('does not add header for ProxyKind.none', () async {
      final options = RequestOptions(
        path: '/xrpc/app.bsky.feed.getTimeline',
        extra: {ProxyInterceptor.proxyKindKey: ProxyKind.none},
      );

      interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers[ProxyInterceptor.proxyHeader], isNull);
    });

    test('does not add header when proxy kind is not specified', () async {
      final options = RequestOptions(path: '/xrpc/app.bsky.feed.getTimeline');
      interceptor.onRequest(options, RequestInterceptorHandler());
      expect(options.headers[ProxyInterceptor.proxyHeader], isNull);
    });

    test('does not add header when extra contains non-ProxyKind value', () async {
      final options = RequestOptions(
        path: '/xrpc/test',
        extra: {ProxyInterceptor.proxyKindKey: 'invalid'},
      );

      interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers[ProxyInterceptor.proxyHeader], isNull);
    });

    test('preserves existing headers', () async {
      final options = RequestOptions(
        path: '/xrpc/chat.bsky.convo.listConvos',
        headers: {'Authorization': 'Bearer token123', 'Content-Type': 'application/json'},
        extra: {ProxyInterceptor.proxyKindKey: ProxyKind.chat},
      );

      interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers['Authorization'], equals('Bearer token123'));
      expect(options.headers['Content-Type'], equals('application/json'));
      expect(
        options.headers[ProxyInterceptor.proxyHeader],
        equals('did:web:api.bsky.chat#bsky_chat'),
      );
    });
  });

  group('ProxyInterceptor constants', () {
    test('proxyKindKey has expected value', () {
      expect(ProxyInterceptor.proxyKindKey, equals('proxyKind'));
    });

    test('proxyHeader has expected value', () {
      expect(ProxyInterceptor.proxyHeader, equals('atproto-proxy'));
    });
  });
}
