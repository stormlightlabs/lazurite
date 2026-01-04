/// Defines service proxy targets for ATProto XRPC requests.
///
/// Some endpoints require proxying through the user's PDS to a specific
/// service. This is controlled via the `atproto-proxy` header.
enum ProxyKind {
  /// No proxying required.
  none,

  /// Proxy to the Bluesky chat service.
  ///
  /// Sets header: `atproto-proxy: did:web:api.bsky.chat#bsky_chat`
  chat,
}

/// Extension to get the proxy header value.
extension ProxyKindExtension on ProxyKind {
  /// Returns the atproto-proxy header value, or null if no proxy is needed.
  String? get headerValue {
    return switch (this) {
      ProxyKind.none => null,
      ProxyKind.chat => 'did:web:api.bsky.chat#bsky_chat',
    };
  }

  /// Whether this proxy kind requires a header to be set.
  bool get requiresHeader => this != ProxyKind.none;
}
