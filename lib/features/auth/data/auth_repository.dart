import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:atproto/atproto.dart' as atp;
import 'package:atproto_core/atproto_core.dart' as atcore;
import 'package:atproto_oauth/atproto_oauth.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/atproto_host_resolver.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/slingshot_client.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/core/network/xrpc_network_interceptor.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:url_launcher/url_launcher.dart';

typedef LaunchUrlWithMode = Future<bool> Function(Uri url, LaunchMode mode);
typedef CloseInAppBrowser = Future<void> Function();
typedef SupportsCloseForMode = Future<bool> Function(LaunchMode mode);
typedef OAuthRefreshSession =
    Future<OAuthSession> Function({
      required OAuthClientMetadata metadata,
      required String service,
      required OAuthSession session,
    });

class AuthRepository {
  AuthRepository({
    required AppDatabase database,
    LaunchUrlWithMode launchUrlWithMode = _defaultLaunchUrlWithMode,
    CloseInAppBrowser closeInAppBrowser = closeInAppWebView,
    SupportsCloseForMode supportsCloseForMode = supportsCloseForLaunchMode,
    OAuthRefreshSession oauthRefreshSession = _defaultOAuthRefreshSession,
    Future<OAuthClientMetadata> Function(String clientId) loadClientMetadata = getClientMetadata,
    String Function()? oauthServiceResolver,
    bool Function()? slingshotIdentityFallbackEnabledResolver,
    SlingshotClient? slingshotClient,
    Future<String> Function(String handle)? resolveHandleDid,
    Future<Map<String, dynamic>> Function(String did)? resolveDidDocument,
  }) : _database = database,
       _launchUrlWithMode = launchUrlWithMode,
       _closeInAppBrowser = closeInAppBrowser,
       _supportsCloseForMode = supportsCloseForMode,
       _oauthRefreshSession = oauthRefreshSession,
       _loadClientMetadata = loadClientMetadata,
       _oauthServiceResolver = oauthServiceResolver ?? _defaultOAuthServiceResolver,
       _slingshotIdentityFallbackEnabledResolver = slingshotIdentityFallbackEnabledResolver ?? _defaultFalse,
       _slingshotClient = slingshotClient ?? SlingshotClient(),
       _resolveHandleDid = resolveHandleDid,
       _resolveDidDocumentOverride = resolveDidDocument;

  static const String kClientId = 'https://lazurite.stormlightlabs.org/client-metadata.json';
  static const String _oauthService = 'bsky.social';
  static const String _fallbackService = 'bsky.social';
  static final Uri _appReopenUri = Uri.parse('lazurite://auth-complete');

  final AppDatabase _database;
  final LaunchUrlWithMode _launchUrlWithMode;
  final CloseInAppBrowser _closeInAppBrowser;
  final SupportsCloseForMode _supportsCloseForMode;
  final OAuthRefreshSession _oauthRefreshSession;
  final Future<OAuthClientMetadata> Function(String clientId) _loadClientMetadata;
  final String Function() _oauthServiceResolver;
  final bool Function() _slingshotIdentityFallbackEnabledResolver;
  final SlingshotClient _slingshotClient;
  final Future<String> Function(String handle)? _resolveHandleDid;
  final Future<Map<String, dynamic>> Function(String did)? _resolveDidDocumentOverride;

  HttpServer? _callbackServer;
  StreamSubscription<HttpRequest>? _callbackSubscription;
  int _callbackServerPort = 0;
  Completer<AuthTokens?>? _oauthCompleter;
  OAuthClient? _pendingOAuthClient;
  OAuthContext? _pendingOAuthContext;
  String? _pendingHandle;
  String? _pendingService;
  LaunchMode? _oauthLaunchMode;

  Future<AuthTokens?> getStoredSession() async {
    final account = await _database.getActiveAccount();
    if (account == null) {
      return null;
    }

    final authMethod = account.dpopPrivateKey != null && account.dpopPublicKey != null
        ? AuthMethod.oauth
        : AuthMethod.appPassword;

    return AuthTokens(
      accessToken: account.accessToken,
      refreshToken: account.refreshToken,
      expiresAt: account.expiresAt,
      did: account.did,
      handle: account.handle,
      displayName: account.displayName,
      service: account.service,
      oauthService: authMethod == AuthMethod.oauth ? normalizeAtprotoServiceHost(account.oauthService) : null,
      dpopNonce: account.dpopNonce,
      dpopPublicKey: account.dpopPublicKey,
      dpopPrivateKey: account.dpopPrivateKey,
      authMethod: authMethod,
    );
  }

  Future<AuthTokens?> restoreSession() async {
    log.d('AuthRepository: Restoring stored session');
    final storedSession = await getStoredSession();
    if (storedSession == null) {
      log.d('AuthRepository: No stored session found');
      return null;
    }

    if (!storedSession.isExpired) {
      log.i('AuthRepository: Restored valid stored session for ${storedSession.handle}');
      return storedSession;
    }

    if (storedSession.refreshToken == null) {
      log.w('AuthRepository: Stored session expired without refresh token, removing account');
      await _invalidateSession(storedSession);
      return restoreSession();
    }

    try {
      log.i('AuthRepository: Stored session expired, attempting refresh for ${storedSession.handle}');
      return await refreshSession(storedSession);
    } catch (error, stackTrace) {
      log.e('AuthRepository: Failed to restore expired session', error: error, stackTrace: stackTrace);
      return restoreSession();
    }
  }

  Future<void> saveSession(AuthTokens tokens, {bool makeActive = false}) async {
    await _database.insertAccount(
      AccountsCompanion(
        did: Value(tokens.did),
        handle: Value(tokens.handle),
        displayName: tokens.displayName != null ? Value(tokens.displayName) : const Value.absent(),
        service: tokens.service != null ? Value(tokens.service) : const Value.absent(),
        oauthService: tokens.oauthService != null ? Value(tokens.oauthService) : const Value.absent(),
        accessToken: Value(tokens.accessToken),
        refreshToken: tokens.refreshToken != null ? Value(tokens.refreshToken) : const Value.absent(),
        dpopPublicKey: tokens.dpopPublicKey != null ? Value(tokens.dpopPublicKey) : const Value.absent(),
        dpopPrivateKey: tokens.dpopPrivateKey != null ? Value(tokens.dpopPrivateKey) : const Value.absent(),
        dpopNonce: tokens.dpopNonce != null ? Value(tokens.dpopNonce) : const Value.absent(),
        expiresAt: tokens.expiresAt != null ? Value(tokens.expiresAt) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );

    if (makeActive) {
      await _database.setSetting(AppDatabase.activeAccountDidSettingKey, tokens.did);
    }
  }

  Future<void> clearSession() async {
    await _database.deleteAllAccounts();
    await _database.deleteSetting(AppDatabase.activeAccountDidSettingKey);
  }

  Future<AuthTokens?> loginWithOAuth(String handle) async {
    try {
      _oauthCompleter = Completer<AuthTokens?>();
      _pendingHandle = handle.trim();
      final preferredOauthService = normalizeAtprotoServiceHost(_oauthServiceResolver()) ?? _oauthService;
      String? resolvedPdsHost;
      String? resolvedAuthService;
      try {
        resolvedPdsHost = await _resolveServiceForIdentifier(_pendingHandle!);
        resolvedAuthService = await _resolveAuthorizationServiceForPdsHost(resolvedPdsHost);
      } catch (error, stackTrace) {
        log.w(
          'AuthRepository: Failed to pre-resolve OAuth account authority for ${_pendingHandle!}; '
          'continuing with fallback auth service chain.',
          error: error,
          stackTrace: stackTrace,
        );
      }
      final oauthServices = _oauthAuthorizeServiceCandidates(
        preferredAuthService: preferredOauthService,
        resolvedPdsHost: resolvedPdsHost,
        resolvedAuthService: resolvedAuthService,
      );
      log.i('AuthRepository: Starting OAuth login for ${_pendingHandle!}');
      log.d('AuthRepository: OAuth auth service candidates: ${oauthServices.join(', ')}');

      final metadata = await _loadClientMetadata(kClientId);
      log.d('AuthRepository: Loaded client metadata with redirect URIs: ${metadata.redirectUris.join(', ')}');
      final redirectUriTemplate = Uri.parse(metadata.redirectUris.first);
      final redirectUri = await _startCallbackServer(redirectUriTemplate);

      Object? lastAttemptError;
      StackTrace? lastAttemptStackTrace;
      final failedAttemptSummaries = <String>[];

      for (final oauthService in oauthServices) {
        try {
          final oauthClient = OAuthClient(
            metadata.copyWith(redirectUris: [redirectUri.toString()]),
            service: oauthService,
          );
          final (authorizationUrl, context) = await oauthClient.authorize(_pendingHandle);

          _pendingService = oauthService;
          _pendingOAuthClient = oauthClient;
          _pendingOAuthContext = context;
          log.i('AuthRepository: OAuth PAR completed, launching browser to ${_sanitizeUriForLog(authorizationUrl)}');
          await _launchUrl(authorizationUrl);

          return await _oauthCompleter!.future;
        } catch (error, stackTrace) {
          lastAttemptError = error;
          lastAttemptStackTrace = stackTrace;
          final summary = _summarizeOAuthRefreshError(error);
          failedAttemptSummaries.add('$oauthService=$summary');
          log.w(
            'AuthRepository: OAuth authorize attempt failed using auth service $oauthService ($summary)',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }

      Error.throwWithStackTrace(
        Exception(
          'OAuth authorize failed across ${oauthServices.length} auth service candidate(s). '
          'Attempts: ${failedAttemptSummaries.join(' | ')}. Last error: $lastAttemptError',
        ),
        lastAttemptStackTrace ?? StackTrace.current,
      );
    } catch (error, stackTrace) {
      log.e('AuthRepository: OAuth login failed', error: error, stackTrace: stackTrace);
      await _stopCallbackServer();
      _resetPendingOAuthState();
      throw Exception('Failed to login with OAuth: $error');
    } finally {
      await _dismissOAuthBrowserIfNeeded();
    }
  }

  Future<AuthTokens?> loginWithAppPassword(String handle, String appPassword) async {
    try {
      log.i('AuthRepository: Starting app password login for ${handle.trim()}');
      final service = await _resolveServiceForIdentifier(handle);
      log.d('AuthRepository: Resolved app password login service to $service');
      final session = await atp.createSession(identifier: handle, password: appPassword, service: service);

      final tokens = AuthTokens(
        accessToken: session.data.accessJwt,
        refreshToken: session.data.refreshJwt,
        expiresAt: session.data.accessTokenJwt.exp,
        did: session.data.did,
        handle: session.data.handle,
        displayName: null,
        service: service,
        authMethod: AuthMethod.appPassword,
      );

      await saveSession(tokens, makeActive: true);
      log.i('AuthRepository: App password login succeeded for ${tokens.handle}');
      return tokens;
    } catch (error, stackTrace) {
      log.e('AuthRepository: App password login failed', error: error, stackTrace: stackTrace);
      throw Exception('Failed to login with app password: $error');
    }
  }

  Future<AuthTokens?> refreshSession(AuthTokens currentSession) async {
    if (currentSession.refreshToken == null) {
      throw Exception('No refresh token available for session refresh');
    }

    if (currentSession.usesOAuth) {
      log.i('AuthRepository: Refreshing OAuth session for ${currentSession.handle}');
      final publicKey = currentSession.dpopPublicKey;
      final privateKey = currentSession.dpopPrivateKey;
      if (publicKey == null || privateKey == null) {
        throw Exception('Stored OAuth session is missing DPoP keys');
      }

      try {
        final metadata = await _loadClientMetadata(kClientId);
        final restoredSession = _restoreOAuthSession(
          currentSession: currentSession,
          publicKey: publicKey,
          privateKey: privateKey,
        );
        final oauthServices = _oauthRefreshServiceCandidates(
          storedAuthService: currentSession.oauthService,
          issuer: restoredSession.accessTokenJwt.iss,
        );

        Object? lastAttemptError;
        StackTrace? lastAttemptStackTrace;
        String? successfulOauthService;
        final failedAttemptSummaries = <String>[];
        OAuthSession? refreshedSession;
        for (final oauthService in oauthServices) {
          try {
            log.d('AuthRepository: Attempting OAuth refresh using auth service $oauthService');
            refreshedSession = await _oauthRefreshSession(
              metadata: metadata,
              service: oauthService,
              session: _restoreOAuthSession(
                currentSession: currentSession,
                publicKey: publicKey,
                privateKey: privateKey,
              ),
            );
            successfulOauthService = oauthService;
            break;
          } catch (error, stackTrace) {
            lastAttemptError = error;
            lastAttemptStackTrace = stackTrace;
            final summary = _summarizeOAuthRefreshError(error);
            failedAttemptSummaries.add('$oauthService=$summary');
            log.w(
              'AuthRepository: OAuth refresh attempt failed using auth service $oauthService ($summary)',
              error: error,
              stackTrace: stackTrace,
            );
          }
        }

        if (refreshedSession == null) {
          Error.throwWithStackTrace(
            Exception(
              'OAuth refresh failed across ${oauthServices.length} auth service candidate(s). '
              'Attempts: ${failedAttemptSummaries.join(' | ')}. Last error: $lastAttemptError',
            ),
            lastAttemptStackTrace ?? StackTrace.current,
          );
        }

        final fallbackPdsHost = normalizeAtprotoServiceHost(currentSession.service) ?? _fallbackService;
        final refreshedTokens = await _buildOAuthTokens(
          refreshedSession,
          fallbackHandle: currentSession.handle,
          fallbackPdsHost: fallbackPdsHost,
          oauthService: successfulOauthService ?? currentSession.oauthService ?? _oauthService,
        );

        await saveSession(
          refreshedTokens,
          makeActive: await _database.getSetting(AppDatabase.activeAccountDidSettingKey) == currentSession.did,
        );
        log.i(
          'AuthRepository: OAuth session refresh succeeded for ${refreshedTokens.handle} '
          'using auth service ${refreshedTokens.oauthService ?? successfulOauthService ?? 'unknown'}',
        );
        return refreshedTokens;
      } catch (error, stackTrace) {
        log.e('AuthRepository: OAuth session refresh failed', error: error, stackTrace: stackTrace);
        await _invalidateSession(currentSession);
        throw Exception('Failed to refresh OAuth session: $error');
      }
    }

    try {
      log.i('AuthRepository: Refreshing app password session for ${currentSession.handle}');
      final refreshed = await atp.refreshSession(
        refreshJwt: currentSession.refreshToken!,
        service: currentSession.service,
      );

      final tokens = AuthTokens(
        accessToken: refreshed.data.accessJwt,
        refreshToken: refreshed.data.refreshJwt,
        expiresAt: refreshed.data.accessTokenJwt.exp,
        did: refreshed.data.did,
        handle: refreshed.data.handle,
        displayName: currentSession.displayName,
        service: currentSession.service,
        authMethod: AuthMethod.appPassword,
      );

      await saveSession(
        tokens,
        makeActive: await _database.getSetting(AppDatabase.activeAccountDidSettingKey) == currentSession.did,
      );
      log.i('AuthRepository: App password session refresh succeeded for ${tokens.handle}');
      return tokens;
    } catch (error, stackTrace) {
      log.e('AuthRepository: App password session refresh failed', error: error, stackTrace: stackTrace);
      await _invalidateSession(currentSession);
      throw Exception('Failed to refresh session: $error');
    }
  }

  Future<void> logout() async {
    final storedSession = await getStoredSession();
    log.i('AuthRepository: Logging out ${storedSession?.handle ?? 'current user'}');

    try {
      if (storedSession?.refreshToken != null && storedSession?.usesOAuth == false) {
        await atp.deleteSession(refreshJwt: storedSession!.refreshToken!, service: storedSession.service);
      }
    } finally {
      await clearSession();
      log.i('AuthRepository: Logout complete');
    }
  }

  Future<Uri> _startCallbackServer(Uri redirectUriTemplate) async {
    if (!_isSupportedLoopbackRedirect(redirectUriTemplate)) {
      throw UnsupportedError(
        'Unsupported OAuth redirect URI: $redirectUriTemplate. '
        'Lazurite currently supports only loopback HTTP redirects.',
      );
    }

    await _stopCallbackServer();

    final requestedPort = _requestedCallbackPort(redirectUriTemplate);
    log.d(
      'AuthRepository: Binding OAuth callback server to '
      '${InternetAddress.loopbackIPv4.address}:${requestedPort == 0 ? 'ephemeral' : requestedPort} '
      'for ${redirectUriTemplate.path}',
    );

    final callbackServer = await HttpServer.bind(InternetAddress.loopbackIPv4, requestedPort);
    _callbackServer = callbackServer;
    _callbackServerPort = callbackServer.port;
    final redirectUri = redirectUriTemplate.replace(
      host: InternetAddress.loopbackIPv4.address,
      port: callbackServer.port,
    );
    log.i('AuthRepository: OAuth callback server listening on ${_sanitizeUriForLog(redirectUri)}');

    _callbackSubscription = callbackServer.listen(
      (request) {
        unawaited(_handleCallbackRequest(request, redirectUri));
      },
      onError: (Object error, StackTrace stackTrace) {
        log.e('AuthRepository: OAuth callback server stream failed', error: error, stackTrace: stackTrace);
      },
    );

    return redirectUri;
  }

  Future<void> _handleCallbackRequest(HttpRequest request, Uri redirectUri) async {
    final uri = request.requestedUri;
    log.d(
      'AuthRepository: OAuth callback request received at '
      '${uri.path} with query keys: ${uri.queryParameters.keys.join(', ')}',
    );

    if (uri.path != redirectUri.path) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    await _callbackSubscription?.cancel();
    _callbackSubscription = null;

    final callbackPageHtml = buildCallbackPageHtmlForTest();
    final callbackBody = utf8.encode(callbackPageHtml);
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.html
      ..headers.contentLength = callbackBody.length
      ..write(callbackPageHtml);
    await request.response.close();

    final callbackUrl = uri.replace(scheme: redirectUri.scheme, host: redirectUri.host, port: redirectUri.port);

    try {
      log.i('AuthRepository: Processing OAuth callback');
      final tokens = await _handleOAuthCallback(callbackUrl.toString());
      if (_oauthCompleter?.isCompleted == false) {
        _oauthCompleter?.complete(tokens);
      }
    } catch (error, stackTrace) {
      log.e('AuthRepository: OAuth callback handling failed', error: error, stackTrace: stackTrace);
      if (_oauthCompleter?.isCompleted == false) {
        _oauthCompleter?.completeError(error, stackTrace);
      }
    } finally {
      await _stopCallbackServer();
      _resetPendingOAuthState();
    }
  }

  Future<AuthTokens> _handleOAuthCallback(String callbackUrl) async {
    final oauthClient = _pendingOAuthClient;
    final oauthContext = _pendingOAuthContext;
    final fallbackHandle = _pendingHandle;
    final service = _pendingService;

    if (oauthClient == null || oauthContext == null || fallbackHandle == null || service == null) {
      throw StateError('OAuth callback received without an active auth flow');
    }

    final callbackUri = Uri.parse(callbackUrl);
    log.d(
      'AuthRepository: Exchanging OAuth callback for session using '
      '${callbackUri.path} with query keys: ${callbackUri.queryParameters.keys.join(', ')}',
    );
    final oauthSession = await oauthClient.callback(callbackUrl, oauthContext);
    log.i('AuthRepository: OAuth token exchange succeeded for DID ${oauthSession.sub}');
    final tokens = await _buildOAuthTokens(
      oauthSession,
      fallbackHandle: fallbackHandle,
      fallbackPdsHost: _fallbackService,
      oauthService: service,
    );
    await saveSession(tokens, makeActive: true);
    log.i('AuthRepository: OAuth login completed for ${tokens.handle}');
    return tokens;
  }

  Future<AuthTokens> _buildOAuthTokens(
    OAuthSession session, {
    required String fallbackHandle,
    required String fallbackPdsHost,
    required String oauthService,
  }) async {
    var resolvedHandle = fallbackHandle;
    String? displayName;
    log.d('AuthRepository: Building OAuth tokens for DID ${session.sub}');
    log.d(
      'AuthRepository: OAuth session will target PDS '
      '${session.atprotoPdsEndpoint ?? 'unknown'} via auth service $oauthService',
    );
    final pdsHost = normalizeAtprotoServiceHost(session.atprotoPdsEndpoint) ?? fallbackPdsHost;
    final normalizedOauthService =
        normalizeAtprotoServiceHost(session.accessTokenJwt.iss) ??
        normalizeAtprotoServiceHost(oauthService) ??
        _oauthService;

    try {
      final authSession = await createAtProtoForOAuthSession(session).server.getSession();
      resolvedHandle = authSession.data.handle;
    } catch (e, s) {
      log.w(
        'AuthRepository: Failed to resolve handle from session, falling back to login hint',
        error: e,
        stackTrace: s,
      );
    }

    try {
      final profile = await createBlueskyForOAuthSession(session).actor.getProfile(actor: session.sub);
      displayName = profile.data.displayName;
    } catch (e, s) {
      log.w('AuthRepository: Failed to fetch display name, continuing without it', error: e, stackTrace: s);
    }

    return AuthTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      expiresAt: session.expiresAt,
      did: session.sub,
      handle: resolvedHandle,
      displayName: displayName,
      service: pdsHost,
      oauthService: normalizedOauthService,
      dpopNonce: session.$dPoPNonce,
      dpopPublicKey: session.$publicKey,
      dpopPrivateKey: session.$privateKey,
      authMethod: AuthMethod.oauth,
    );
  }

  Future<void> _stopCallbackServer() async {
    final callbackSubscription = _callbackSubscription;
    final callbackServer = _callbackServer;
    final callbackServerPort = _callbackServerPort;

    _callbackSubscription = null;
    _callbackServer = null;
    _callbackServerPort = 0;

    if (callbackServerPort > 0) {
      log.d('AuthRepository: Stopping OAuth callback server on port $callbackServerPort');
    }
    await callbackSubscription?.cancel();
    if (callbackServer == null) {
      return;
    }

    try {
      await callbackServer.close(force: true);
    } on HttpException catch (error, stackTrace) {
      log.w('AuthRepository: OAuth callback server was already closed', error: error, stackTrace: stackTrace);
    }
  }

  Future<String> _resolveServiceForIdentifier(String identifier) async {
    log.d('AuthRepository: Resolving AT Protocol service for $identifier');
    final resolvedIdentity = await _resolveIdentityForIdentifier(identifier);
    log.d('AuthRepository: Resolved identifier $identifier to DID ${resolvedIdentity.did}');

    final serviceFromMiniDoc = normalizeAtprotoServiceHost(resolvedIdentity.pdsHost);
    if (serviceFromMiniDoc != null) {
      log.d('AuthRepository: Using Slingshot-provided PDS host for $identifier: $serviceFromMiniDoc');
      return serviceFromMiniDoc;
    }

    final did = resolvedIdentity.did;
    final didDoc = await _resolveDidDocument(did);
    final serviceEndpoint = _extractServiceEndpoint(didDoc) ?? _fallbackService;
    log.d('AuthRepository: Resolved DID $did to service endpoint $serviceEndpoint');
    return serviceEndpoint;
  }

  Future<({String did, String? pdsHost})> _resolveIdentityForIdentifier(String identifier) async {
    final normalizedIdentifier = identifier.trim();
    if (normalizedIdentifier.startsWith('did:')) {
      return (did: normalizedIdentifier, pdsHost: null);
    }

    try {
      final did = await _resolveHandleDidOrFetch(normalizedIdentifier);
      return (did: did, pdsHost: null);
    } catch (error, stackTrace) {
      final useSlingshotFallback = _slingshotIdentityFallbackEnabledResolver();
      log.w(
        'AuthRepository: resolveHandle failed for $normalizedIdentifier '
        'slingshotFallbackEnabled=$useSlingshotFallback',
        error: error,
        stackTrace: stackTrace,
      );
      if (!useSlingshotFallback) {
        rethrow;
      }

      try {
        final miniDoc = await _slingshotClient.resolveMiniDoc(normalizedIdentifier);
        log.i(
          'AuthRepository: slingshot resolveMiniDoc succeeded for $normalizedIdentifier '
          'did=${miniDoc.did} pds=${miniDoc.pds}',
        );
        return (did: miniDoc.did, pdsHost: miniDoc.pds);
      } catch (fallbackError, fallbackStackTrace) {
        log.w(
          'AuthRepository: slingshot resolveMiniDoc failed for $normalizedIdentifier',
          error: fallbackError,
          stackTrace: fallbackStackTrace,
        );
        rethrow;
      }
    }
  }

  Future<String> _resolveHandleDidOrFetch(String handle) async {
    final override = _resolveHandleDid;
    if (override != null) {
      return override(handle);
    }

    final client = atp.ATProto.anonymous(
      service: _fallbackService,
      getClient: XrpcNetworkInterceptor.wrapGetClient(),
      postClient: XrpcNetworkInterceptor.wrapPostClient(),
    );
    return (await client.identity.resolveHandle(handle: handle)).data.did;
  }

  Future<String?> _resolveAuthorizationServiceForPdsHost(String pdsHost) async {
    final normalizedPdsHost = normalizeAtprotoServiceHost(pdsHost);
    if (normalizedPdsHost == null) {
      return null;
    }

    final uri = Uri.https(normalizedPdsHost, '/.well-known/oauth-protected-resource');
    log.d('AuthRepository: Fetching protected resource metadata from ${_sanitizeUriForLog(uri)}');
    final response = await http.get(uri);
    if (response.statusCode != HttpStatus.ok) {
      throw Exception(
        'Failed to resolve authorization server for $normalizedPdsHost: '
        'HTTP ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid protected resource metadata for $normalizedPdsHost');
    }

    final rawAuthorizationServers = decoded['authorization_servers'];
    if (rawAuthorizationServers is! List) {
      return null;
    }

    for (final candidate in rawAuthorizationServers) {
      if (candidate is! String) {
        continue;
      }
      final host = normalizeAtprotoServiceHost(candidate);
      if (host != null && host.isNotEmpty) {
        return host;
      }
    }

    return null;
  }

  Future<Map<String, dynamic>> _resolveDidDocument(String did) async {
    final override = _resolveDidDocumentOverride;
    if (override != null) {
      return override(did);
    }

    final uri = _didDocumentUri(did);
    log.d('AuthRepository: Fetching DID document from ${_sanitizeUriForLog(uri)}');
    final response = await http.get(uri);

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to resolve DID document for $did: ${response.statusCode}');
    }

    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic>) {
      throw Exception('Invalid DID document for $did');
    }

    return json;
  }

  Uri _didDocumentUri(String did) {
    if (did.startsWith('did:plc:')) {
      return Uri.https('plc.directory', '/$did');
    }

    if (did.startsWith('did:web:')) {
      final encodedSegments = did.substring('did:web:'.length).split(':');
      if (encodedSegments.isEmpty || encodedSegments.first.isEmpty) {
        throw Exception('Invalid did:web identifier: $did');
      }

      final host = Uri.decodeComponent(encodedSegments.first);
      final pathSegments = encodedSegments.skip(1).map(Uri.decodeComponent).toList();
      final path = pathSegments.isEmpty ? '/.well-known/did.json' : '/${pathSegments.join('/')}/did.json';
      return Uri.https(host, path);
    }

    throw Exception('Unsupported DID method for service resolution: $did');
  }

  String? _extractServiceEndpoint(Map<String, dynamic> didDoc) {
    final services = didDoc['service'];
    if (services is! List) {
      return null;
    }

    for (final service in services) {
      if (service is! Map<String, dynamic>) {
        continue;
      }

      if (service['id'] == '#atproto_pds' &&
          service['type'] == 'AtprotoPersonalDataServer' &&
          service['serviceEndpoint'] is String) {
        final endpoint = Uri.tryParse(service['serviceEndpoint'] as String);
        if (endpoint != null && endpoint.host.isNotEmpty) {
          return endpoint.host;
        }
      }
    }

    return null;
  }

  static Future<bool> _defaultLaunchUrlWithMode(Uri url, LaunchMode mode) {
    return launchUrl(url, mode: mode);
  }

  Future<void> _launchUrl(Uri url) async {
    final launchMode = _oauthLaunchModeForPlatform(isWeb: kIsWeb, platform: defaultTargetPlatform);
    log.d('AuthRepository: Launching OAuth URL ${_sanitizeUriForLog(url)} with mode $launchMode');

    if (!await _launchUrlWithMode(url, launchMode)) {
      throw Exception('Could not launch $url');
    }

    _oauthLaunchMode = launchMode;
  }

  Future<void> _dismissOAuthBrowserIfNeeded() async {
    final launchMode = _oauthLaunchMode;
    _oauthLaunchMode = null;

    if (launchMode == null || launchMode != LaunchMode.inAppBrowserView) {
      return;
    }

    try {
      final supportsClose = await _supportsCloseForMode(launchMode);
      if (!supportsClose) {
        return;
      }

      await _closeInAppBrowser();
      log.d('AuthRepository: Dismissed OAuth in-app browser');
    } catch (error, stackTrace) {
      log.w('AuthRepository: Failed to dismiss OAuth in-app browser', error: error, stackTrace: stackTrace);
    }
  }

  @visibleForTesting
  static LaunchMode oauthLaunchModeForTest({required bool isWeb, required TargetPlatform platform}) {
    return _oauthLaunchModeForPlatform(isWeb: isWeb, platform: platform);
  }

  static LaunchMode _oauthLaunchModeForPlatform({required bool isWeb, required TargetPlatform platform}) {
    if (isWeb) {
      return LaunchMode.platformDefault;
    }

    return switch (platform) {
      TargetPlatform.android || TargetPlatform.iOS => LaunchMode.inAppBrowserView,
      _ => LaunchMode.externalApplication,
    };
  }

  @visibleForTesting
  Future<void> dismissOAuthBrowserForTest(LaunchMode mode) async {
    _oauthLaunchMode = mode;
    await _dismissOAuthBrowserIfNeeded();
  }

  bool _isSupportedLoopbackRedirect(Uri redirectUri) {
    return redirectUri.scheme == 'http' && _isLoopbackHost(redirectUri.host);
  }

  bool _isLoopbackHost(String host) {
    return host == '127.0.0.1' || host == 'localhost';
  }

  int _requestedCallbackPort(Uri redirectUri) {
    if (!redirectUri.hasPort) {
      return 0;
    }

    return redirectUri.port < 1024 ? 0 : redirectUri.port;
  }

  String _sanitizeUriForLog(Uri uri) {
    return uri.replace(query: null, fragment: null).toString();
  }

  Future<void> _invalidateSession(AuthTokens tokens) async {
    await _database.deleteAccount(tokens.did);
    if (await _database.getSetting(AppDatabase.activeAccountDidSettingKey) == tokens.did) {
      await _database.deleteSetting(AppDatabase.activeAccountDidSettingKey);
    }
  }

  void _resetPendingOAuthState() {
    _oauthCompleter = null;
    _pendingOAuthClient = null;
    _pendingOAuthContext = null;
    _pendingHandle = null;
    _pendingService = null;
    _oauthLaunchMode = null;
  }

  @visibleForTesting
  String buildCallbackPageHtmlForTest() => _buildCallbackPageHtml(_appReopenUri);

  OAuthSession _restoreOAuthSession({
    required AuthTokens currentSession,
    required String publicKey,
    required String privateKey,
  }) {
    return atcore.restoreOAuthSession(
      accessToken: currentSession.accessToken,
      refreshToken: currentSession.refreshToken!,
      dPoPNonce: currentSession.dpopNonce,
      publicKey: publicKey,
      privateKey: privateKey,
    );
  }

  static Future<OAuthSession> _defaultOAuthRefreshSession({
    required OAuthClientMetadata metadata,
    required String service,
    required OAuthSession session,
  }) {
    final oauthClient = OAuthClient(metadata, service: service);
    return oauthClient.refresh(session);
  }

  static String _defaultOAuthServiceResolver() {
    return AppViewProviders.descriptorForSetting(AppViewProviders.defaultKey).entrywayUrl.host;
  }

  static bool _defaultFalse() => false;

  String _summarizeOAuthRefreshError(Object error) {
    final message = error.toString().replaceAll('\n', ' ').trim();

    if (message.contains('<!DOCTYPE html>')) {
      return 'non_json_html_response';
    }
    if (error is FormatException) {
      return 'json_parse_error';
    }
    if (message.isEmpty) {
      return error.runtimeType.toString();
    }

    return message.length <= 240 ? message : '${message.substring(0, 237)}...';
  }

  static List<String> _oauthRefreshServiceCandidates({required String? storedAuthService, required String? issuer}) {
    final candidates = <String>{};
    final issuerHost = normalizeAtprotoServiceHost(issuer);
    if (issuerHost != null) {
      candidates.add(issuerHost);
    }

    final storedAuthHost = normalizeAtprotoServiceHost(storedAuthService);
    if (storedAuthHost != null) {
      candidates.add(storedAuthHost);
    }

    candidates.add(_oauthService);
    candidates.add(_fallbackService);
    return candidates.toList(growable: false);
  }

  static List<String> _oauthAuthorizeServiceCandidates({
    required String? preferredAuthService,
    required String? resolvedPdsHost,
    required String? resolvedAuthService,
  }) {
    final candidates = <String>{};

    final resolvedAuthHost = normalizeAtprotoServiceHost(resolvedAuthService);
    if (resolvedAuthHost != null) {
      candidates.add(resolvedAuthHost);
    }

    final resolvedHost = normalizeAtprotoServiceHost(resolvedPdsHost);
    if (resolvedHost != null) {
      candidates.add(resolvedHost);
    }

    candidates.add(_oauthService);

    final preferredHost = normalizeAtprotoServiceHost(preferredAuthService);
    if (preferredHost != null) {
      candidates.add(preferredHost);
    }

    candidates.add(_fallbackService);
    return candidates.toList(growable: false);
  }

  @visibleForTesting
  static List<String> oauthRefreshServiceCandidatesForTest({
    required String? storedAuthService,
    required String? issuer,
  }) {
    return _oauthRefreshServiceCandidates(storedAuthService: storedAuthService, issuer: issuer);
  }

  @visibleForTesting
  static List<String> oauthAuthorizeServiceCandidatesForTest({
    required String? preferredAuthService,
    required String? resolvedPdsHost,
    required String? resolvedAuthService,
  }) {
    return _oauthAuthorizeServiceCandidates(
      preferredAuthService: preferredAuthService,
      resolvedPdsHost: resolvedPdsHost,
      resolvedAuthService: resolvedAuthService,
    );
  }

  @visibleForTesting
  Future<Uri> startCallbackServerForTest(Uri redirectUriTemplate) => _startCallbackServer(redirectUriTemplate);

  @visibleForTesting
  Future<void> stopCallbackServerForTest() => _stopCallbackServer();

  @visibleForTesting
  Future<String> resolveServiceForIdentifierForTest(String identifier) => _resolveServiceForIdentifier(identifier);

  int get callbackPort => _callbackServerPort;
}

String _buildCallbackPageHtml(Uri reopenUri) {
  final escapedReopenUrl = const HtmlEscape(HtmlEscapeMode.element).convert(reopenUri.toString());
  return '''
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Lazurite Authentication Complete</title>
    <style>
      body {
        align-items: center;
        background: #161616;
        color: #f2f4f8;
        display: flex;
        font-family: system-ui, sans-serif;
        justify-content: center;
        margin: 0;
        min-height: 100vh;
        padding: 24px;
        text-align: center;
      }

      main {
        max-width: 420px;
      }

      h1 {
        font-size: 28px;
        margin-bottom: 12px;
      }

      p {
        color: #dde1e6;
        line-height: 1.5;
        margin: 0 0 12px;
      }

      .button-link {
        appearance: none;
        background: #0f62fe;
        border: 0;
        border-radius: 999px;
        color: white;
        cursor: pointer;
        display: inline-block;
        font: inherit;
        font-weight: 600;
        padding: 12px 20px;
      }

      a { text-decoration: none; }
    </style>
  </head>
  <body>
    <main>
      <h1>Authentication Complete</h1>
      <p>Lazurite is finishing sign-in. If it does not reopen automatically, tap the button below.</p>
      <a id="reopen-link" class="button-link" href="$escapedReopenUrl">Return to Lazurite</a>
    </main>
    <iframe
      id="reopen-frame"
      title="Return to Lazurite"
      style="display: none; width: 0; height: 0; border: 0"
    ></iframe>
    <script>
      const reopenUrl = '$escapedReopenUrl';
      let reopenAttempts = 0;

      function attemptReopen() {
        reopenAttempts += 1;

        const frame = document.getElementById('reopen-frame');
        if (frame) {
          frame.src = reopenUrl;
        }

        const link = document.getElementById('reopen-link');
        if (link && reopenAttempts === 1) {
          link.click();
        }

        if (reopenAttempts === 1) {
          window.location.assign(reopenUrl);
          return;
        }

        window.location.href = reopenUrl;
      }

      window.addEventListener('load', function () {
        window.setTimeout(attemptReopen, 120);
        window.setTimeout(attemptReopen, 480);
        window.setTimeout(attemptReopen, 1000);
      });

      document.addEventListener('visibilitychange', function () {
        if (document.visibilityState === 'hidden') {
          window.setTimeout(function () {
            window.close();
          }, 300);
        }
      });
    </script>
  </body>
</html>
''';
}
