/// Defines the type of host to use for XRPC requests.
///
/// ATProto/Bluesky uses different hosts depending on the operation:
/// - Public reads can use the public AppView
/// - Authenticated operations go through the user's PDS
/// - Chat operations are proxied through the PDS to the chat service
enum HostKind {
  /// Public API endpoint for unauthenticated reads.
  ///
  /// Base URL: `https://public.api.bsky.app`
  publicApi,

  /// User's Personal Data Server for authenticated operations.
  ///
  /// Base URL: Resolved from user's DID document.
  pds,
}

/// Extension to get host-related properties.
extension HostKindExtension on HostKind {
  /// Returns the base URL for this host kind.
  ///
  /// Note: For [HostKind.pds], this returns null since the URL must be resolved from the
  /// user's DID document.
  String? get baseUrl {
    return switch (this) {
      HostKind.publicApi => 'https://public.api.bsky.app',
      HostKind.pds => null,
    };
  }

  /// Whether this host requires authentication.
  bool get requiresSession {
    return switch (this) {
      HostKind.publicApi => false,
      HostKind.pds => true,
    };
  }
}
