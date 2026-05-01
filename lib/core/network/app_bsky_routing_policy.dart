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
    /// Explicit service-routed endpoints (non-appview service fragments)
    ///
    /// #bsky_chat
    'chat.bsky.convo.listConvos': AppBskyProxyMode.useProxy,
    'chat.bsky.convo.getConvoForMembers': AppBskyProxyMode.useProxy,
    'chat.bsky.convo.getMessages': AppBskyProxyMode.useProxy,
    'chat.bsky.convo.sendMessage': AppBskyProxyMode.useProxy,
    'chat.bsky.convo.deleteMessageForSelf': AppBskyProxyMode.useProxy,
    'chat.bsky.convo.muteConvo': AppBskyProxyMode.useProxy,
    'chat.bsky.convo.unmuteConvo': AppBskyProxyMode.useProxy,
    'chat.bsky.convo.updateRead': AppBskyProxyMode.useProxy,

    /// #bsky_fg (feed generator management)
    'app.bsky.feed.sendInteractions': AppBskyProxyMode.useProxy,

    /// #bsky_notif
    'app.bsky.notification.registerPush': AppBskyProxyMode.useProxy,
    'app.bsky.notification.unregisterPush': AppBskyProxyMode.useProxy,
    'app.bsky.notification.updateSeen': AppBskyProxyMode.useProxy,
    'app.bsky.notification.listNotifications': AppBskyProxyMode.useProxy,
    'app.bsky.notification.getUnreadCount': AppBskyProxyMode.useProxy,

    /// #atproto_labeler
    'app.bsky.labeler.getServices': AppBskyProxyMode.useProxy,

    /// Explicit provider-sensitive endpoints.
    'app.bsky.feed.getTimeline': AppBskyProxyMode.useProxy,
    'app.bsky.feed.getFeed': AppBskyProxyMode.useProxy,
    'app.bsky.feed.searchPosts': AppBskyProxyMode.useProxy,
    'app.bsky.feed.getPostThread': AppBskyProxyMode.useProxy,
    'app.bsky.feed.getAuthorFeed': AppBskyProxyMode.useProxy,

    /// Actor/profile endpoints (public or account-context reads).
    'app.bsky.actor.getProfile': AppBskyProxyMode.bypassProxy,
    'app.bsky.actor.getProfiles': AppBskyProxyMode.bypassProxy,
    'app.bsky.actor.getPreferences': AppBskyProxyMode.bypassProxy,
    'app.bsky.actor.putPreferences': AppBskyProxyMode.bypassProxy,
    'app.bsky.actor.searchActors': AppBskyProxyMode.bypassProxy,
    'app.bsky.actor.searchActorsTypeahead': AppBskyProxyMode.bypassProxy,

    /// Graph endpoints tied to account graph records, list management, and starter packs.
    'app.bsky.graph.follow': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.block': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.muteActor': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.unmuteActor': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.getSuggestedFollowsByActor': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.getLists': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.getList': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.getListsWithMembership': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.getActorStarterPacks': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.getStarterPack': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.listitem': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.listblock': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.muteActorList': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.unmuteActorList': AppBskyProxyMode.bypassProxy,
    'app.bsky.graph.starterpack': AppBskyProxyMode.bypassProxy,

    /// Feed/bookmark endpoints with account-local semantics.
    'app.bsky.feed.like': AppBskyProxyMode.bypassProxy,
    'app.bsky.feed.repost': AppBskyProxyMode.bypassProxy,
    'app.bsky.feed.post': AppBskyProxyMode.bypassProxy,
    'app.bsky.feed.getLikes': AppBskyProxyMode.bypassProxy,
    'app.bsky.feed.getQuotes': AppBskyProxyMode.bypassProxy,
    'app.bsky.feed.getRepostedBy': AppBskyProxyMode.bypassProxy,
    'app.bsky.feed.getActorLikes': AppBskyProxyMode.bypassProxy,
    'app.bsky.feed.getListFeed': AppBskyProxyMode.bypassProxy,
    'app.bsky.feed.getPosts': AppBskyProxyMode.bypassProxy,
    'app.bsky.bookmark.createBookmark': AppBskyProxyMode.bypassProxy,
    'app.bsky.bookmark.deleteBookmark': AppBskyProxyMode.bypassProxy,
    'app.bsky.bookmark.getBookmarks': AppBskyProxyMode.bypassProxy,

    /// Public unspecced endpoints should avoid proxy header attachment.
    'app.bsky.unspecced.getTopicFeed': AppBskyProxyMode.bypassProxy,
    'app.bsky.unspecced.getTrends': AppBskyProxyMode.bypassProxy,
    'app.bsky.unspecced.getTrendingTopics': AppBskyProxyMode.bypassProxy,
    'app.bsky.unspecced.getPopularFeedGenerators': AppBskyProxyMode.bypassProxy,

    /// Feed metadata reads that are effectively public and can tolerate default AppView routing.
    'app.bsky.feed.getFeedGenerator': AppBskyProxyMode.bypassProxy,
    'app.bsky.feed.getFeedGenerators': AppBskyProxyMode.bypassProxy,
    'app.bsky.feed.getSuggestedFeeds': AppBskyProxyMode.bypassProxy,
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
