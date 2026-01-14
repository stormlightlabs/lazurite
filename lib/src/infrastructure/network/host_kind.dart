/// Defines type of host to use for XRPC requests.
///
/// ATProto/Bluesky uses different hosts depending on operation:
/// - Public reads can use public AppView
/// - Authenticated operations go through user's PDS
/// - Chat operations are proxied through PDS to chat service
/// - Video uploads go to dedicated video service with service auth
/// - Tenor API for GIF search and selection
enum HostKind {
  /// Public API endpoint for unauthenticated reads.
  ///
  /// Base URL: `https://public.api.bsky.app`
  publicApi,

  /// User's Personal Data Server for authenticated operations.
  ///
  /// Base URL: Resolved from user's DID document.
  pds,

  /// Video service endpoint for video uploads with service auth.
  ///
  /// Base URL: `https://video.bsky.app`
  video,

  /// Tenor API endpoint for GIF search and selection.
  ///
  /// Base URL: `https://tenor.googleapis.com/v2`
  tenor,
}

/// Extension to get host-related properties.
extension HostKindExtension on HostKind {
  /// Returns base URL for this host kind.
  ///
  /// Note: For [HostKind.pds], this returns null since URL must be resolved from
  /// user's DID document.
  String? get baseUrl {
    return switch (this) {
      HostKind.publicApi => 'https://public.api.bsky.app',
      HostKind.pds => null,
      HostKind.video => 'https://video.bsky.app',
      HostKind.tenor => 'https://tenor.googleapis.com/v2',
    };
  }

  /// Whether this host requires authentication.
  bool get requiresSession {
    return switch (this) {
      HostKind.publicApi => false,
      HostKind.pds => true,
      HostKind.video => true,
      HostKind.tenor => false,
    };
  }
}
