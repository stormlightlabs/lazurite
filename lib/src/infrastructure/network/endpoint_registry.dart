import 'endpoint_meta.dart';
import 'host_kind.dart';
import 'http_method.dart';
import 'proxy_kind.dart';

/// Registry mapping NSIDs to their endpoint metadata.
///
/// This is the single source of truth for how to route XRPC requests.
/// Each endpoint is defined with its method, host, auth requirements,
/// and proxy configuration.
class EndpointRegistry {
  EndpointRegistry._();

  static final EndpointRegistry instance = EndpointRegistry._();

  /// The endpoint registry mapping NSID to metadata.
  ///
  /// Following ATProto/Bluesky routing rules:
  /// - Public reads (getPostThread, getProfile, searchPosts) → public.api.bsky.app
  /// - Auth-required reads (getTimeline) → user's PDS
  /// - Writes (createRecord, uploadBlob) → user's PDS
  /// - Chat endpoints → user's PDS with proxy header
  static final Map<String, EndpointMeta> _endpoints = {
    'app.bsky.feed.getPostThread': const EndpointMeta(
      nsid: 'app.bsky.feed.getPostThread',
      method: HttpMethod.get,
      hostKind: HostKind.publicApi,
    ),
    'app.bsky.feed.getPosts': const EndpointMeta(
      nsid: 'app.bsky.feed.getPosts',
      method: HttpMethod.get,
      hostKind: HostKind.publicApi,
    ),
    'app.bsky.feed.searchPosts': const EndpointMeta(
      nsid: 'app.bsky.feed.searchPosts',
      method: HttpMethod.get,
      hostKind: HostKind.publicApi,
    ),
    'app.bsky.feed.getAuthorFeed': const EndpointMeta(
      nsid: 'app.bsky.feed.getAuthorFeed',
      method: HttpMethod.get,
      hostKind: HostKind.publicApi,
    ),
    'app.bsky.feed.getLikes': const EndpointMeta(
      nsid: 'app.bsky.feed.getLikes',
      method: HttpMethod.get,
      hostKind: HostKind.publicApi,
    ),
    'app.bsky.feed.getRepostedBy': const EndpointMeta(
      nsid: 'app.bsky.feed.getRepostedBy',
      method: HttpMethod.get,
      hostKind: HostKind.publicApi,
    ),

    'app.bsky.feed.getTimeline': const EndpointMeta(
      nsid: 'app.bsky.feed.getTimeline',
      method: HttpMethod.get,
      hostKind: HostKind.pds,
      requiresAuth: true,
    ),
    'app.bsky.feed.getFeed': const EndpointMeta(
      nsid: 'app.bsky.feed.getFeed',
      method: HttpMethod.get,
      hostKind: HostKind.publicApi,
      requiresAuth: false,
    ),

    'app.bsky.actor.getProfile': const EndpointMeta(
      nsid: 'app.bsky.actor.getProfile',
      method: HttpMethod.get,
      hostKind: HostKind.publicApi,
    ),
    'app.bsky.actor.getProfiles': const EndpointMeta(
      nsid: 'app.bsky.actor.getProfiles',
      method: HttpMethod.get,
      hostKind: HostKind.publicApi,
    ),
    'app.bsky.actor.searchActors': const EndpointMeta(
      nsid: 'app.bsky.actor.searchActors',
      method: HttpMethod.get,
      hostKind: HostKind.publicApi,
    ),
    'app.bsky.actor.searchActorsTypeahead': const EndpointMeta(
      nsid: 'app.bsky.actor.searchActorsTypeahead',
      method: HttpMethod.get,
      hostKind: HostKind.publicApi,
    ),

    'app.bsky.actor.getPreferences': const EndpointMeta(
      nsid: 'app.bsky.actor.getPreferences',
      method: HttpMethod.get,
      hostKind: HostKind.pds,
      requiresAuth: true,
    ),
    'app.bsky.actor.putPreferences': const EndpointMeta(
      nsid: 'app.bsky.actor.putPreferences',
      method: HttpMethod.post,
      hostKind: HostKind.pds,
      requiresAuth: true,
    ),

    'app.bsky.graph.getFollowers': const EndpointMeta(
      nsid: 'app.bsky.graph.getFollowers',
      method: HttpMethod.get,
      hostKind: HostKind.publicApi,
    ),
    'app.bsky.graph.getFollows': const EndpointMeta(
      nsid: 'app.bsky.graph.getFollows',
      method: HttpMethod.get,
      hostKind: HostKind.publicApi,
    ),
    'app.bsky.graph.muteActor': const EndpointMeta(
      nsid: 'app.bsky.graph.muteActor',
      method: HttpMethod.post,
      hostKind: HostKind.pds,
      requiresAuth: true,
    ),
    'app.bsky.graph.unmuteActor': const EndpointMeta(
      nsid: 'app.bsky.graph.unmuteActor',
      method: HttpMethod.post,
      hostKind: HostKind.pds,
      requiresAuth: true,
    ),

    'app.bsky.notification.listNotifications': const EndpointMeta(
      nsid: 'app.bsky.notification.listNotifications',
      method: HttpMethod.get,
      hostKind: HostKind.pds,
      requiresAuth: true,
    ),
    'app.bsky.notification.getUnreadCount': const EndpointMeta(
      nsid: 'app.bsky.notification.getUnreadCount',
      method: HttpMethod.get,
      hostKind: HostKind.pds,
      requiresAuth: true,
    ),
    'app.bsky.notification.updateSeen': const EndpointMeta(
      nsid: 'app.bsky.notification.updateSeen',
      method: HttpMethod.post,
      hostKind: HostKind.pds,
      requiresAuth: true,
    ),

    'com.atproto.server.createSession': const EndpointMeta(
      nsid: 'com.atproto.server.createSession',
      method: HttpMethod.post,
      hostKind: HostKind.pds,
      requiresAuth: false,
    ),

    'com.atproto.repo.createRecord': const EndpointMeta(
      nsid: 'com.atproto.repo.createRecord',
      method: HttpMethod.post,
      hostKind: HostKind.pds,
      requiresAuth: true,
    ),
    'com.atproto.repo.deleteRecord': const EndpointMeta(
      nsid: 'com.atproto.repo.deleteRecord',
      method: HttpMethod.post,
      hostKind: HostKind.pds,
      requiresAuth: true,
    ),
    'com.atproto.repo.uploadBlob': const EndpointMeta(
      nsid: 'com.atproto.repo.uploadBlob',
      method: HttpMethod.post,
      hostKind: HostKind.pds,
      requiresAuth: true,
    ),
    'com.atproto.repo.getRecord': const EndpointMeta(
      nsid: 'com.atproto.repo.getRecord',
      method: HttpMethod.get,
      hostKind: HostKind.publicApi,
    ),

    'com.atproto.identity.resolveHandle': const EndpointMeta(
      nsid: 'com.atproto.identity.resolveHandle',
      method: HttpMethod.get,
      hostKind: HostKind.publicApi,
    ),

    'chat.bsky.convo.listConvos': const EndpointMeta(
      nsid: 'chat.bsky.convo.listConvos',
      method: HttpMethod.get,
      hostKind: HostKind.pds,
      requiresAuth: true,
      proxyKind: ProxyKind.chat,
    ),
    'chat.bsky.convo.getConvo': const EndpointMeta(
      nsid: 'chat.bsky.convo.getConvo',
      method: HttpMethod.get,
      hostKind: HostKind.pds,
      requiresAuth: true,
      proxyKind: ProxyKind.chat,
    ),
    'chat.bsky.convo.getMessages': const EndpointMeta(
      nsid: 'chat.bsky.convo.getMessages',
      method: HttpMethod.get,
      hostKind: HostKind.pds,
      requiresAuth: true,
      proxyKind: ProxyKind.chat,
    ),
    'chat.bsky.convo.sendMessage': const EndpointMeta(
      nsid: 'chat.bsky.convo.sendMessage',
      method: HttpMethod.post,
      hostKind: HostKind.pds,
      requiresAuth: true,
      proxyKind: ProxyKind.chat,
    ),
    'chat.bsky.convo.updateRead': const EndpointMeta(
      nsid: 'chat.bsky.convo.updateRead',
      method: HttpMethod.post,
      hostKind: HostKind.pds,
      requiresAuth: true,
      proxyKind: ProxyKind.chat,
    ),
    'chat.bsky.convo.getConvoForMembers': const EndpointMeta(
      nsid: 'chat.bsky.convo.getConvoForMembers',
      method: HttpMethod.get,
      hostKind: HostKind.pds,
      requiresAuth: true,
      proxyKind: ProxyKind.chat,
    ),
  };

  /// Looks up endpoint metadata by NSID.
  ///
  /// Returns null if the endpoint is not registered.
  EndpointMeta? lookup(String nsid) => _endpoints[nsid];

  /// Looks up endpoint metadata by NSID, throwing if not found.
  ///
  /// Use [lookup] if you want to handle missing endpoints gracefully.
  EndpointMeta get(String nsid) {
    final meta = _endpoints[nsid];
    if (meta == null) {
      throw ArgumentError.value(nsid, 'nsid', 'Unknown endpoint');
    }
    return meta;
  }

  /// Returns all registered NSIDs.
  Iterable<String> get allNsids => _endpoints.keys;

  /// Returns all registered endpoints.
  Iterable<EndpointMeta> get allEndpoints => _endpoints.values;

  /// Checks if an NSID is registered.
  bool contains(String nsid) => _endpoints.containsKey(nsid);

  /// Returns all endpoints that match the given predicate.
  Iterable<EndpointMeta> where(bool Function(EndpointMeta) test) => _endpoints.values.where(test);

  /// Returns all public endpoints (no auth required).
  Iterable<EndpointMeta> get publicEndpoints => where((e) => !e.requiresAuth);

  /// Returns all authenticated endpoints.
  Iterable<EndpointMeta> get authEndpoints => where((e) => e.requiresAuth);

  /// Returns all chat endpoints.
  Iterable<EndpointMeta> get chatEndpoints => where((e) => e.proxyKind == ProxyKind.chat);
}
