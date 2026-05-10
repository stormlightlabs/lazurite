import 'dart:typed_data';

import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/app/bsky/actor.dart' as actor_methods;
import 'package:poptart_lex/app/bsky/bookmark.dart' as bookmark_methods;
import 'package:poptart_lex/app/bsky/feed.dart' as feed_methods;
import 'package:poptart_lex/app/bsky/graph.dart' as graph_methods;
import 'package:poptart_lex/app/bsky/labeler.dart' as labeler_methods;
import 'package:poptart_lex/app/bsky/notification.dart' as notification_methods;
import 'package:poptart_lex/app/bsky/unspecced.dart' as unspecced_methods;
import 'package:poptart_lex/app/bsky/video.dart' as video_methods;
import 'package:poptart_lex/chat/bsky/convo.dart' as convo_methods;
import 'package:poptart_lex/com/atproto/identity.dart' as identity_methods;
import 'package:poptart_lex/com/atproto/moderation.dart' as moderation_methods;
import 'package:poptart_lex/com/atproto/repo.dart' as repo_methods;
import 'package:poptart_lex/com/atproto/server.dart' as server_methods;
import 'package:poptart_lex/com/atproto/server/create_session/input.dart';
import 'package:poptart_lex/com/atproto/server/create_session/output.dart';
import 'package:poptart_lex/com/atproto/server/refresh_session/output.dart';
import 'package:poptart_oauth/poptart_oauth.dart' show OAuthSession;

export 'package:poptart_core/poptart_core.dart';
export 'package:poptart_oauth/poptart_oauth.dart';
export 'package:poptart_xrpc/poptart_xrpc.dart';

class Bluesky {
  Bluesky._(this._client);

  factory Bluesky.fromSession(
    Session session, {
    Map<String, String>? headers,
    Protocol? protocol,
    String? service,
    String? relayService,
    Duration? timeout,
    RetryConfig? retryConfig,
    GetClient? getClient,
    PostClient? postClient,
  }) {
    return Bluesky._(
      PoptartClient.fromSession(
        session,
        headers: headers,
        protocol: protocol,
        service: service,
        relayService: relayService,
        timeout: timeout,
        retryConfig: retryConfig,
        getClient: getClient,
        postClient: postClient,
      ),
    );
  }

  factory Bluesky.fromOAuthSession(
    OAuthSession session, {
    Map<String, String>? headers,
    Protocol? protocol,
    String? service,
    String? relayService,
    Duration? timeout,
    RetryConfig? retryConfig,
    GetClient? getClient,
    PostClient? postClient,
  }) {
    return Bluesky._(
      PoptartClient.fromOAuthSession(
        session,
        headers: headers,
        protocol: protocol,
        service: service,
        relayService: relayService,
        timeout: timeout,
        retryConfig: retryConfig,
        getClient: getClient,
        postClient: postClient,
      ),
    );
  }

  factory Bluesky.anonymous({
    Map<String, String>? headers,
    Protocol? protocol,
    String? service,
    String? relayService,
    Duration? timeout,
    RetryConfig? retryConfig,
    GetClient? getClient,
    PostClient? postClient,
  }) {
    return Bluesky._(
      PoptartClient.anonymous(
        headers: headers,
        protocol: protocol,
        service: service,
        relayService: relayService,
        timeout: timeout,
        retryConfig: retryConfig,
        getClient: getClient,
        postClient: postClient,
      ),
    );
  }

  final PoptartClient _client;

  Session? get session => _client.session;
  OAuthSession? get oAuthSession => _client.oAuthSession;
  String get service => _client.service;
  Map<String, String> get headers => _client.headers;

  BlueskyAtProto get atproto => BlueskyAtProto._(_client);
  dynamic get actor => _XrpcNamespace(_client, 'app.bsky.actor');
  dynamic get bookmark => _XrpcNamespace(_client, 'app.bsky.bookmark');
  dynamic get feed => _FeedNamespace(_client);
  dynamic get graph => _GraphNamespace(_client);
  dynamic get labeler => _XrpcNamespace(_client, 'app.bsky.labeler');
  dynamic get notification => _XrpcNamespace(_client, 'app.bsky.notification');
  dynamic get unspecced => _XrpcNamespace(_client, 'app.bsky.unspecced');
  dynamic get video => _XrpcNamespace(_client, 'app.bsky.video');

  Future<XRPCResponse<O>> call<P, I, O>(
    XRPCMethod<P, I, O> method, {
    String? service,
    Map<String, String>? headers,
    P? parameters,
    I? input,
  }) {
    return _client.call(method, service: service, headers: headers, parameters: parameters, input: input);
  }

  Future<XRPCResponse<T>> get<T>(
    NSID methodId, {
    String? service,
    Map<String, String>? headers,
    Map<String, dynamic>? parameters,
    ResponseDataBuilder<T>? to,
    ResponseDataAdaptor? adaptor,
  }) {
    return _client.get(methodId, service: service, headers: headers, parameters: parameters, to: to, adaptor: adaptor);
  }

  Future<XRPCResponse<T>> post<T>(
    NSID methodId, {
    String? service,
    Map<String, String>? headers,
    Map<String, dynamic>? parameters,
    dynamic body,
    ResponseDataBuilder<T>? to,
  }) {
    return _client.post(methodId, service: service, headers: headers, parameters: parameters, body: body, to: to);
  }
}

class BlueskyChat extends Bluesky {
  BlueskyChat._(super.client) : super._();

  factory BlueskyChat.fromSession(
    Session session, {
    Map<String, String>? headers,
    Protocol? protocol,
    String? service,
    String? relayService,
    Duration? timeout,
    RetryConfig? retryConfig,
    GetClient? getClient,
    PostClient? postClient,
  }) {
    return BlueskyChat._(
      PoptartClient.fromSession(
        session,
        headers: headers,
        protocol: protocol,
        service: service,
        relayService: relayService,
        timeout: timeout,
        retryConfig: retryConfig,
        getClient: getClient,
        postClient: postClient,
      ),
    );
  }

  factory BlueskyChat.fromOAuthSession(
    OAuthSession session, {
    Map<String, String>? headers,
    Protocol? protocol,
    String? service,
    String? relayService,
    Duration? timeout,
    RetryConfig? retryConfig,
    GetClient? getClient,
    PostClient? postClient,
  }) {
    return BlueskyChat._(
      PoptartClient.fromOAuthSession(
        session,
        headers: headers,
        protocol: protocol,
        service: service,
        relayService: relayService,
        timeout: timeout,
        retryConfig: retryConfig,
        getClient: getClient,
        postClient: postClient,
      ),
    );
  }

  dynamic get convo => _XrpcNamespace(_client, 'chat.bsky.convo');
}

typedef ATProto = BlueskyAtProto;

class BlueskyAtProto {
  BlueskyAtProto._(this._client);

  factory BlueskyAtProto.anonymous({
    Map<String, String>? headers,
    Protocol? protocol,
    String? service,
    String? relayService,
    Duration? timeout,
    RetryConfig? retryConfig,
    GetClient? getClient,
    PostClient? postClient,
  }) {
    return BlueskyAtProto._(
      PoptartClient.anonymous(
        headers: headers,
        protocol: protocol,
        service: service,
        relayService: relayService,
        timeout: timeout,
        retryConfig: retryConfig,
        getClient: getClient,
        postClient: postClient,
      ),
    );
  }

  factory BlueskyAtProto.fromOAuthSession(
    OAuthSession session, {
    Map<String, String>? headers,
    Protocol? protocol,
    String? service,
    String? relayService,
    Duration? timeout,
    RetryConfig? retryConfig,
    GetClient? getClient,
    PostClient? postClient,
  }) {
    return BlueskyAtProto._(
      PoptartClient.fromOAuthSession(
        session,
        headers: headers,
        protocol: protocol,
        service: service,
        relayService: relayService,
        timeout: timeout,
        retryConfig: retryConfig,
        getClient: getClient,
        postClient: postClient,
      ),
    );
  }

  final PoptartClient _client;

  Session? get session => _client.session;
  OAuthSession? get oAuthSession => _client.oAuthSession;
  String get service => _client.service;

  dynamic get identity => _XrpcNamespace(_client, 'com.atproto.identity');
  dynamic get moderation => _XrpcNamespace(_client, 'com.atproto.moderation');
  dynamic get repo => _RepoNamespace(_client);
  dynamic get server => _XrpcNamespace(_client, 'com.atproto.server');

  Future<XRPCResponse<T>> get<T>(
    NSID methodId, {
    String? service,
    Map<String, String>? headers,
    Map<String, dynamic>? parameters,
    ResponseDataBuilder<T>? to,
    ResponseDataAdaptor? adaptor,
  }) {
    return _client.get(methodId, service: service, headers: headers, parameters: parameters, to: to, adaptor: adaptor);
  }
}

Future<XRPCResponse<Session>> createSession({
  required String identifier,
  required String password,
  String? service,
}) async {
  final response = await PoptartClient.anonymous().call(
    server_methods.comAtprotoServerCreateSession,
    service: service,
    input: ServerCreateSessionInput(identifier: identifier, password: password),
  );

  return _sessionResponse(response, _sessionFromCreateSessionOutput(response.data));
}

Future<XRPCResponse<Session>> refreshSession({required String refreshJwt, String? service}) async {
  final response = await PoptartClient.anonymous(
    headers: {'Authorization': 'Bearer $refreshJwt'},
  ).call(server_methods.comAtprotoServerRefreshSession, service: service);

  return _sessionResponse(response, _sessionFromRefreshSessionOutput(response.data));
}

XRPCResponse<Session> _sessionResponse(final XRPCResponse<dynamic> response, final Session session) {
  return XRPCResponse(
    headers: response.headers,
    status: response.status,
    request: response.request,
    rateLimit: response.rateLimit,
    data: session,
  );
}

Session _sessionFromCreateSessionOutput(final ServerCreateSessionOutput output) {
  return Session.fromJson(output.toJson());
}

Session _sessionFromRefreshSessionOutput(final ServerRefreshSessionOutput output) {
  return Session.fromJson(output.toJson());
}

class _FeedNamespace extends _XrpcNamespace {
  _FeedNamespace(PoptartClient client) : super(client, 'app.bsky.feed');

  dynamic get like => _RecordNamespace(_client, 'app.bsky.feed.like');
  dynamic get post => _RecordNamespace(_client, 'app.bsky.feed.post');
  dynamic get repost => _RecordNamespace(_client, 'app.bsky.feed.repost');
}

class _GraphNamespace extends _XrpcNamespace {
  _GraphNamespace(PoptartClient client) : super(client, 'app.bsky.graph');

  dynamic get block => _RecordNamespace(_client, 'app.bsky.graph.block');
  dynamic get follow => _RecordNamespace(_client, 'app.bsky.graph.follow');
  dynamic get listblock => _RecordNamespace(_client, 'app.bsky.graph.listblock');
  dynamic get listitem => _RecordNamespace(_client, 'app.bsky.graph.listitem');
  dynamic get starterpack => _RecordNamespace(_client, 'app.bsky.graph.starterpack');
}

class _RepoNamespace extends _XrpcNamespace {
  _RepoNamespace(PoptartClient client) : super(client, 'com.atproto.repo');

  Future<XRPCResponse<dynamic>> uploadBlob({
    required Uint8List bytes,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _invokeDescriptor(
      _client,
      repo_methods.comAtprotoRepoUploadBlob,
      headers: $headers,
      service: $service,
      input: bytes,
    );
  }
}

class _RecordNamespace {
  _RecordNamespace(this._client, this._collection);

  final PoptartClient _client;
  final String _collection;

  Future<XRPCResponse<dynamic>> create({
    String? rkey,
    Map<String, String>? $headers,
    String? $service,
    bool? validate,
    String? swapCommit,
    Map<String, dynamic>? record,
    dynamic subject,
    dynamic cid,
    DateTime? createdAt,
    dynamic list,
    dynamic item,
    String? name,
    String? description,
    dynamic avatar,
    dynamic labels,
    dynamic purpose,
  }) {
    final body = record ?? <String, dynamic>{};
    body.putIfAbsent(r'$type', () => _collection);
    _putIfPresent(body, 'subject', subject);
    _putIfPresent(body, 'cid', cid);
    _putIfPresent(body, 'createdAt', createdAt);
    _putIfPresent(body, 'list', list);
    _putIfPresent(body, 'item', item);
    _putIfPresent(body, 'name', name);
    _putIfPresent(body, 'description', description);
    _putIfPresent(body, 'avatar', avatar);
    _putIfPresent(body, 'labels', labels);
    _putIfPresent(body, 'purpose', purpose);
    return _invokeDescriptor(
      _client,
      repo_methods.comAtprotoRepoCreateRecord,
      headers: $headers,
      service: $service,
      input: {
        'repo': _repoDid(_client),
        'collection': _collection,
        'rkey': ?rkey,
        'validate': ?validate,
        'swapCommit': ?swapCommit,
        'record': _normalizeJson(body),
      },
    );
  }

  Future<XRPCResponse<dynamic>> put({
    required String rkey,
    Map<String, String>? $headers,
    String? $service,
    bool? validate,
    String? swapRecord,
    String? swapCommit,
    Map<String, dynamic>? record,
    String? name,
    String? description,
    dynamic avatar,
    dynamic labels,
    dynamic purpose,
    dynamic list,
  }) {
    final body = record ?? <String, dynamic>{};
    body.putIfAbsent(r'$type', () => _collection);
    _putIfPresent(body, 'name', name);
    _putIfPresent(body, 'description', description);
    _putIfPresent(body, 'avatar', avatar);
    _putIfPresent(body, 'labels', labels);
    _putIfPresent(body, 'purpose', purpose);
    _putIfPresent(body, 'list', list);
    return _invokeDescriptor(
      _client,
      repo_methods.comAtprotoRepoPutRecord,
      headers: $headers,
      service: $service,
      input: {
        'repo': _repoDid(_client),
        'collection': _collection,
        'rkey': rkey,
        'validate': ?validate,
        'swapRecord': ?swapRecord,
        'swapCommit': ?swapCommit,
        'record': _normalizeJson(body),
      },
    );
  }

  Future<XRPCResponse<dynamic>> delete({
    required String rkey,
    Map<String, String>? $headers,
    String? $service,
    String? swapRecord,
    String? swapCommit,
  }) {
    return _invokeDescriptor(
      _client,
      repo_methods.comAtprotoRepoDeleteRecord,
      headers: $headers,
      service: $service,
      input: {
        'repo': _repoDid(_client),
        'collection': _collection,
        'rkey': rkey,
        'swapRecord': ?swapRecord,
        'swapCommit': ?swapCommit,
      },
    );
  }
}

class _XrpcNamespace {
  _XrpcNamespace(this._client, this._prefix);

  final PoptartClient _client;
  final String _prefix;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (!invocation.isMethod) return super.noSuchMethod(invocation);
    final method = _symbolName(invocation.memberName);
    final named = <String, dynamic>{};
    invocation.namedArguments.forEach((key, value) => named[_symbolName(key)] = value);
    final headers = named.remove(r'$headers') as Map<String, String>?;
    final service = named.remove(r'$service') as String?;
    final descriptor = _descriptorFor('$_prefix.$method');
    if (descriptor == null) return super.noSuchMethod(invocation);
    return _invokeDescriptor(_client, descriptor, headers: headers, service: service, values: named);
  }
}

Future<XRPCResponse<dynamic>> _invokeDescriptor(
  PoptartClient client,
  XRPCMethodDescriptor<dynamic, dynamic, dynamic> descriptor, {
  Map<String, String>? headers,
  String? service,
  Map<String, dynamic>? values,
  dynamic input,
}) {
  final normalized = _normalizeJson(values ?? const <String, dynamic>{}) as Map<String, dynamic>;
  final dynamic parameters = descriptor.isQuery ? descriptor.parametersFromJson?.call(normalized) ?? normalized : null;
  final normalizedInput = input is Map<String, dynamic> ? _normalizeJson(input) as Map<String, dynamic> : input;
  final dynamic body =
      (normalizedInput is Map<String, dynamic>
          ? descriptor.inputFromJson?.call(normalizedInput) ?? normalizedInput
          : normalizedInput) ??
      (descriptor.isProcedure
          ? descriptor.inputFromJson?.call(normalized) ?? (normalized.isEmpty ? null : normalized)
          : null);
  return client.call(descriptor, service: service, headers: headers, parameters: parameters, input: body);
}

XRPCMethodDescriptor<dynamic, dynamic, dynamic>? _descriptorFor(String nsid) {
  return switch (nsid) {
        'app.bsky.actor.getPreferences' => actor_methods.appBskyActorGetPreferences,
        'app.bsky.actor.getProfile' => actor_methods.appBskyActorGetProfile,
        'app.bsky.actor.getProfiles' => actor_methods.appBskyActorGetProfiles,
        'app.bsky.actor.putPreferences' => actor_methods.appBskyActorPutPreferences,
        'app.bsky.actor.searchActors' => actor_methods.appBskyActorSearchActors,
        'app.bsky.actor.searchActorsTypeahead' => actor_methods.appBskyActorSearchActorsTypeahead,
        'app.bsky.bookmark.createBookmark' => bookmark_methods.appBskyBookmarkCreateBookmark,
        'app.bsky.bookmark.deleteBookmark' => bookmark_methods.appBskyBookmarkDeleteBookmark,
        'app.bsky.bookmark.getBookmarks' => bookmark_methods.appBskyBookmarkGetBookmarks,
        'app.bsky.feed.getActorLikes' => feed_methods.appBskyFeedGetActorLikes,
        'app.bsky.feed.getAuthorFeed' => feed_methods.appBskyFeedGetAuthorFeed,
        'app.bsky.feed.getFeed' => feed_methods.appBskyFeedGetFeed,
        'app.bsky.feed.getFeedGenerator' => feed_methods.appBskyFeedGetFeedGenerator,
        'app.bsky.feed.getFeedGenerators' => feed_methods.appBskyFeedGetFeedGenerators,
        'app.bsky.feed.getLikes' => feed_methods.appBskyFeedGetLikes,
        'app.bsky.feed.getListFeed' => feed_methods.appBskyFeedGetListFeed,
        'app.bsky.feed.getPostThread' => feed_methods.appBskyFeedGetPostThread,
        'app.bsky.feed.getPosts' => feed_methods.appBskyFeedGetPosts,
        'app.bsky.feed.getQuotes' => feed_methods.appBskyFeedGetQuotes,
        'app.bsky.feed.getRepostedBy' => feed_methods.appBskyFeedGetRepostedBy,
        'app.bsky.feed.getSuggestedFeeds' => feed_methods.appBskyFeedGetSuggestedFeeds,
        'app.bsky.feed.getTimeline' => feed_methods.appBskyFeedGetTimeline,
        'app.bsky.feed.searchPosts' => feed_methods.appBskyFeedSearchPosts,
        'app.bsky.graph.getActorStarterPacks' => graph_methods.appBskyGraphGetActorStarterPacks,
        'app.bsky.graph.getFollowers' => graph_methods.appBskyGraphGetFollowers,
        'app.bsky.graph.getFollows' => graph_methods.appBskyGraphGetFollows,
        'app.bsky.graph.getList' => graph_methods.appBskyGraphGetList,
        'app.bsky.graph.getListFeed' => null,
        'app.bsky.graph.getLists' => graph_methods.appBskyGraphGetLists,
        'app.bsky.graph.getListsWithMembership' => graph_methods.appBskyGraphGetListsWithMembership,
        'app.bsky.graph.getStarterPack' => graph_methods.appBskyGraphGetStarterPack,
        'app.bsky.graph.getSuggestedFollowsByActor' => graph_methods.appBskyGraphGetSuggestedFollowsByActor,
        'app.bsky.graph.muteActor' => graph_methods.appBskyGraphMuteActor,
        'app.bsky.graph.muteActorList' => graph_methods.appBskyGraphMuteActorList,
        'app.bsky.graph.searchStarterPacks' => graph_methods.appBskyGraphSearchStarterPacks,
        'app.bsky.graph.unmuteActor' => graph_methods.appBskyGraphUnmuteActor,
        'app.bsky.graph.unmuteActorList' => graph_methods.appBskyGraphUnmuteActorList,
        'app.bsky.labeler.getServices' => labeler_methods.appBskyLabelerGetServices,
        'app.bsky.notification.getUnreadCount' => notification_methods.appBskyNotificationGetUnreadCount,
        'app.bsky.notification.listNotifications' => notification_methods.appBskyNotificationListNotifications,
        'app.bsky.notification.registerPush' => notification_methods.appBskyNotificationRegisterPush,
        'app.bsky.notification.unregisterPush' => notification_methods.appBskyNotificationUnregisterPush,
        'app.bsky.notification.updateSeen' => notification_methods.appBskyNotificationUpdateSeen,
        'app.bsky.unspecced.getPopularFeedGenerators' => unspecced_methods.appBskyUnspeccedGetPopularFeedGenerators,
        'app.bsky.unspecced.getTopicFeed' => unspecced_methods.appBskyUnspeccedGetTaggedSuggestions,
        'app.bsky.unspecced.getTrendingTopics' => unspecced_methods.appBskyUnspeccedGetTrendingTopics,
        'app.bsky.unspecced.getTrends' => unspecced_methods.appBskyUnspeccedGetTrends,
        'app.bsky.video.getJobStatus' => video_methods.appBskyVideoGetJobStatus,
        'app.bsky.video.getUploadLimits' => video_methods.appBskyVideoGetUploadLimits,
        'app.bsky.video.uploadVideo' => video_methods.appBskyVideoUploadVideo,
        'chat.bsky.convo.deleteMessageForSelf' => convo_methods.chatBskyConvoDeleteMessageForSelf,
        'chat.bsky.convo.getConvoForMembers' => convo_methods.chatBskyConvoGetConvoForMembers,
        'chat.bsky.convo.getMessages' => convo_methods.chatBskyConvoGetMessages,
        'chat.bsky.convo.listConvos' => convo_methods.chatBskyConvoListConvos,
        'chat.bsky.convo.muteConvo' => convo_methods.chatBskyConvoMuteConvo,
        'chat.bsky.convo.sendMessage' => convo_methods.chatBskyConvoSendMessage,
        'chat.bsky.convo.unmuteConvo' => convo_methods.chatBskyConvoUnmuteConvo,
        'chat.bsky.convo.updateRead' => convo_methods.chatBskyConvoUpdateRead,
        'com.atproto.identity.resolveHandle' => identity_methods.comAtprotoIdentityResolveHandle,
        'com.atproto.moderation.createReport' => moderation_methods.comAtprotoModerationCreateReport,
        'com.atproto.repo.applyWrites' => repo_methods.comAtprotoRepoApplyWrites,
        'com.atproto.repo.createRecord' => repo_methods.comAtprotoRepoCreateRecord,
        'com.atproto.repo.deleteRecord' => repo_methods.comAtprotoRepoDeleteRecord,
        'com.atproto.repo.describeRepo' => repo_methods.comAtprotoRepoDescribeRepo,
        'com.atproto.repo.getRecord' => repo_methods.comAtprotoRepoGetRecord,
        'com.atproto.repo.listRecords' => repo_methods.comAtprotoRepoListRecords,
        'com.atproto.repo.putRecord' => repo_methods.comAtprotoRepoPutRecord,
        'com.atproto.repo.uploadBlob' => repo_methods.comAtprotoRepoUploadBlob,
        'com.atproto.server.getSession' => server_methods.comAtprotoServerGetSession,
        _ => null,
      }
      as XRPCMethodDescriptor<dynamic, dynamic, dynamic>?;
}

dynamic _normalizeJson(dynamic value) {
  if (value == null || value is String || value is num || value is bool) return value;
  if (value is DateTime) return value.toUtc().toIso8601String();
  if (value is AtUri || value is NSID) return value.toString();
  if (value is Blob || value is BlobRef) return value.toJson();
  if (value is List) return value.map(_normalizeJson).toList(growable: false);
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), _normalizeJson(val)));
  }
  final dynamic dynamicValue = value;
  try {
    return dynamicValue.toJson();
  } catch (_) {
    return value.toString();
  }
}

void _putIfPresent(Map<String, dynamic> target, String key, dynamic value) {
  if (value != null) target[key] = _normalizeJson(value);
}

String _repoDid(PoptartClient client) {
  return client.session?.did ??
      client.oAuthSession?.sub ??
      (throw StateError('Authenticated repo DID is unavailable.'));
}

String _symbolName(Symbol symbol) {
  final text = symbol.toString();
  return text.substring(8, text.length - 2);
}
