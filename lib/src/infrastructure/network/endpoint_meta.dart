import 'host_kind.dart';
import 'http_method.dart';
import 'proxy_kind.dart';

/// Metadata for an XRPC endpoint.
///
/// Encapsulates all the routing information needed to make a request
/// to a specific XRPC endpoint, including host selection, authentication
/// requirements, and proxy configuration.
class EndpointMeta {
  /// Creates endpoint metadata.
  const EndpointMeta({
    required this.nsid,
    required this.method,
    required this.hostKind,
    this.requiresAuth = false,
    this.proxyKind = ProxyKind.none,
  });

  /// The Namespaced Identifier for this endpoint.
  ///
  /// Example: `app.bsky.feed.getTimeline`
  final String nsid;

  /// The HTTP method for this endpoint.
  final HttpMethod method;

  /// Which host should handle this request.
  final HostKind hostKind;

  /// Whether this endpoint requires authentication.
  ///
  /// If true, the auth interceptor will attach the access token.
  final bool requiresAuth;

  /// Service proxy configuration for this endpoint.
  ///
  /// Used for endpoints like chat that need to be proxied
  /// through the PDS to a specific service.
  final ProxyKind proxyKind;

  /// Converts the NSID to its XRPC path.
  ///
  /// Example: `app.bsky.feed.getTimeline` -> `/xrpc/app.bsky.feed.getTimeline`
  String get path => '/xrpc/$nsid';

  @override
  String toString() =>
      'EndpointMeta(nsid: $nsid, method: $method, hostKind: $hostKind, '
      'requiresAuth: $requiresAuth, proxyKind: $proxyKind)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EndpointMeta &&
          runtimeType == other.runtimeType &&
          nsid == other.nsid &&
          method == other.method &&
          hostKind == other.hostKind &&
          requiresAuth == other.requiresAuth &&
          proxyKind == other.proxyKind;

  @override
  int get hashCode => Object.hash(nsid, method, hostKind, requiresAuth, proxyKind);
}
