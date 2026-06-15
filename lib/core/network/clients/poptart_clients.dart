part of '../poptart_client_adapter.dart';

const _bskyChatProxyHeaders = <String, String>{'atproto-proxy': 'did:web:api.bsky.chat#bsky_chat'};

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
  BlueskyActorService get actor => BlueskyActorService._(_client);
  BlueskyBookmarkService get bookmark => BlueskyBookmarkService._(_client);
  BlueskyFeedService get feed => BlueskyFeedService._(_client);
  BlueskyGraphService get graph => BlueskyGraphService._(_client);
  BlueskyLabelerService get labeler => BlueskyLabelerService._(_client);
  BlueskyNotificationService get notification => BlueskyNotificationService._(_client);
  BlueskyUnspeccedService get unspecced => BlueskyUnspeccedService._(_client);
  BlueskyVideoService get video => BlueskyVideoService._(_client);

  Future<XRPCResponse<O>> call<P, I, O>(
    XRPCMethod<P, I, O> method, {
    String? service,
    Map<String, String>? headers,
    P? parameters,
    I? input,
  }) {
    final descriptor = method.methodDescriptor;
    return _client.call(
      method,
      service: service,
      headers: headers,
      parameters: _coerceDescriptorParameters(descriptor, parameters) as P?,
      input: _coerceDescriptorInput(descriptor, input) as I?,
    );
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
    Object? body,
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
        headers: {...?headers, ..._bskyChatProxyHeaders},
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
        headers: {...?headers, ..._bskyChatProxyHeaders},
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

  BlueskyConvoService get convo => BlueskyConvoService._(_client);
  BlueskyGroupService get group => BlueskyGroupService._(_client);
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

  AtProtoIdentityService get identity => AtProtoIdentityService._(_client);
  AtProtoModerationService get moderation => AtProtoModerationService._(_client);
  AtProtoRepoService get repo => AtProtoRepoService._(_client);
  AtProtoServerService get server => AtProtoServerService._(_client);

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
    comAtprotoServerCreateSession,
    service: service,
    input: ServerCreateSessionInput(identifier: identifier, password: password),
  );

  return _sessionResponse(response, _sessionFromCreateSessionOutput(response.data));
}

Future<XRPCResponse<Session>> refreshSession({required String refreshJwt, String? service}) async {
  final response = await PoptartClient.anonymous(
    headers: {'Authorization': 'Bearer $refreshJwt'},
  ).call(comAtprotoServerRefreshSession, service: service);

  return _sessionResponse(response, _sessionFromRefreshSessionOutput(response.data));
}
