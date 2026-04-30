enum AppBskyProxyMode { useProxy, bypassProxy }

/// Central routing policy for explicit `atproto-proxy` header attachment on
/// authenticated `app.bsky.*` requests.
///
/// Policy intent:
/// - Default to [AppBskyProxyMode.useProxy] so provider-routed reads continue
///   to honor the selected AppView.
/// - Explicitly bypass proxy for known account/PDS-oriented mutation paths and
///   preference sync calls where forcing proxy has caused regressions.
abstract final class AppBskyRoutingPolicy {
  /// Endpoint identifiers are lexicon IDs.
  ///
  /// Preferences: keep PDS-routed without explicit proxy.
  ///
  ///  Graph record/private mutations: avoid explicit proxy.
  ///
  /// Feed/bookmark mutations: avoid explicit proxy.
  static const Map<String, AppBskyProxyMode> _policyByEndpoint = {
    'app.bsky.actor.getPreferences': AppBskyProxyMode.bypassProxy,
    'app.bsky.actor.putPreferences': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.follow': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.block': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.muteActor': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.unmuteActor': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.listitem': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.listblock': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.muteActorList': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.unmuteActorList': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.starterpack': AppBskyProxyMode.bypassProxy,
    'app.bsky.feed.like': AppBskyProxyMode.bypassProxy,
    'app.bsky.feed.repost': AppBskyProxyMode.bypassProxy,
    'app.bsky.feed.post': AppBskyProxyMode.bypassProxy,
    'app.bsky.bookmark.createBookmark': AppBskyProxyMode.bypassProxy,
    'app.bsky.bookmark.deleteBookmark': AppBskyProxyMode.bypassProxy,
  };

  static AppBskyProxyMode modeForEndpoint(String endpointId) {
    final normalized = endpointId.trim();
    if (normalized.isEmpty) {
      return AppBskyProxyMode.useProxy;
    }
    return _policyByEndpoint[normalized] ?? AppBskyProxyMode.useProxy;
  }

  static bool shouldUseProxy(String endpointId) => modeForEndpoint(endpointId) == AppBskyProxyMode.useProxy;
}
