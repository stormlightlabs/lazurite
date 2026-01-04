import 'package:dio/dio.dart';

import '../proxy_kind.dart';

/// Interceptor that adds the atproto-proxy header for chat requests.
///
/// When a request is marked as requiring the chat proxy, this interceptor adds the appropriate
/// `atproto-proxy` header to route the request through the user's PDS to the Bluesky chat service.
class ProxyInterceptor extends Interceptor {
  ProxyInterceptor();

  /// Key used to specify proxy kind in request options.extra.
  static const proxyKindKey = 'proxyKind';

  /// Header name for ATProto service proxy.
  static const proxyHeader = 'atproto-proxy';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final proxyKind = options.extra[proxyKindKey];

    if (proxyKind is ProxyKind && proxyKind != ProxyKind.none) {
      final headerValue = proxyKind.headerValue;
      if (headerValue != null) {
        options.headers[proxyHeader] = headerValue;
      }
    }

    handler.next(options);
  }
}
