import 'dart:async';
import 'dart:io';

import 'package:atproto/atproto.dart' as atp;
import 'package:atproto_core/atproto_core.dart' as atcore;
import 'package:atproto_oauth/atproto_oauth.dart';
import 'package:bluesky/bluesky.dart';
import 'package:drift/drift.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthRepository {
  AuthRepository({required AppDatabase database}) : _database = database;

  static const String kClientId = 'https://lazurite.stormlightlabs.org/client-metadata.json';
  static const String _fallbackService = 'bsky.social';

  final AppDatabase _database;

  HttpServer? _callbackServer;
  Completer<AuthTokens?>? _oauthCompleter;
  OAuthClient? _pendingOAuthClient;
  OAuthContext? _pendingOAuthContext;
  Uri? _pendingRedirectUri;
  String? _pendingHandle;
  String? _pendingService;

  Future<AuthTokens?> getStoredSession() async {
    final account = await _database.getActiveAccount();
    if (account == null) {
      return null;
    }

    return AuthTokens(
      accessToken: account.accessToken,
      refreshToken: account.refreshToken,
      expiresAt: account.expiresAt,
      did: account.did,
      handle: account.handle,
      displayName: account.displayName,
      service: account.service,
      dpopNonce: account.dpopNonce,
      dpopPublicKey: account.dpopPublicKey,
      dpopPrivateKey: account.dpopPrivateKey,
      authMethod: account.dpopPrivateKey != null && account.dpopPublicKey != null
          ? AuthMethod.oauth
          : AuthMethod.appPassword,
    );
  }

  Future<AuthTokens?> restoreSession() async {
    final storedSession = await getStoredSession();
    if (storedSession == null) {
      return null;
    }

    if (!storedSession.isExpired) {
      return storedSession;
    }

    if (storedSession.refreshToken == null) {
      await clearSession();
      return null;
    }

    try {
      return await refreshSession(storedSession);
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  Future<void> saveSession(AuthTokens tokens) async {
    await _database.insertAccount(
      AccountsCompanion(
        did: Value(tokens.did),
        handle: Value(tokens.handle),
        displayName: tokens.displayName != null ? Value(tokens.displayName) : const Value.absent(),
        service: tokens.service != null ? Value(tokens.service) : const Value.absent(),
        accessToken: Value(tokens.accessToken),
        refreshToken: tokens.refreshToken != null ? Value(tokens.refreshToken) : const Value.absent(),
        dpopPublicKey: tokens.dpopPublicKey != null ? Value(tokens.dpopPublicKey) : const Value.absent(),
        dpopPrivateKey: tokens.dpopPrivateKey != null ? Value(tokens.dpopPrivateKey) : const Value.absent(),
        dpopNonce: tokens.dpopNonce != null ? Value(tokens.dpopNonce) : const Value.absent(),
        expiresAt: tokens.expiresAt != null ? Value(tokens.expiresAt) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> clearSession() async {
    await _database.deleteAllAccounts();
  }

  Future<AuthTokens?> loginWithOAuth(String handle) async {
    try {
      _oauthCompleter = Completer<AuthTokens?>();
      _pendingHandle = handle.trim();
      _pendingService = await _resolveServiceForIdentifier(_pendingHandle!);

      final metadata = await getClientMetadata(kClientId);
      final redirectUri = Uri.parse(metadata.redirectUris.first);
      final oauthClient = OAuthClient(metadata, service: _pendingService!);
      final (authorizationUrl, context) = await oauthClient.authorize(_pendingHandle);

      _pendingOAuthClient = oauthClient;
      _pendingOAuthContext = context;
      _pendingRedirectUri = redirectUri;

      await _startCallbackServer(redirectUri);
      await _launchUrl(authorizationUrl);

      return await _oauthCompleter!.future;
    } catch (error) {
      await _stopCallbackServer();
      _resetPendingOAuthState();
      throw Exception('Failed to login with OAuth: $error');
    }
  }

  Future<AuthTokens?> loginWithAppPassword(String handle, String appPassword) async {
    try {
      final service = await _resolveServiceForIdentifier(handle);
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

      await saveSession(tokens);
      return tokens;
    } catch (error) {
      throw Exception('Failed to login with app password: $error');
    }
  }

  Future<AuthTokens?> refreshSession(AuthTokens currentSession) async {
    if (currentSession.refreshToken == null) {
      throw Exception('No refresh token available for session refresh');
    }

    if (currentSession.usesOAuth) {
      final publicKey = currentSession.dpopPublicKey;
      final privateKey = currentSession.dpopPrivateKey;
      if (publicKey == null || privateKey == null) {
        throw Exception('Stored OAuth session is missing DPoP keys');
      }

      try {
        final metadata = await getClientMetadata(kClientId);
        final oauthClient = OAuthClient(metadata, service: currentSession.service ?? _fallbackService);
        final restoredSession = atcore.restoreOAuthSession(
          accessToken: currentSession.accessToken,
          refreshToken: currentSession.refreshToken!,
          dPoPNonce: currentSession.dpopNonce,
          publicKey: publicKey,
          privateKey: privateKey,
        );

        final refreshedSession = await oauthClient.refresh(restoredSession);
        final refreshedTokens = await _buildOAuthTokens(
          refreshedSession,
          fallbackHandle: currentSession.handle,
          service: currentSession.service ?? _fallbackService,
        );

        await saveSession(refreshedTokens);
        return refreshedTokens;
      } catch (error) {
        await clearSession();
        throw Exception('Failed to refresh OAuth session: $error');
      }
    }

    try {
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

      await saveSession(tokens);
      return tokens;
    } catch (error) {
      await clearSession();
      throw Exception('Failed to refresh session: $error');
    }
  }

  Future<void> logout() async {
    final storedSession = await getStoredSession();

    try {
      if (storedSession?.refreshToken != null && storedSession?.usesOAuth == false) {
        await atp.deleteSession(refreshJwt: storedSession!.refreshToken!, service: storedSession.service);
      }
    } finally {
      await clearSession();
    }
  }

  Future<void> _startCallbackServer(Uri redirectUri) async {
    final requestedPort = redirectUri.hasPort ? redirectUri.port : 80;

    _callbackServer = await HttpServer.bind(InternetAddress.loopbackIPv4, requestedPort);

    unawaited(
      _callbackServer!.forEach((request) async {
        final uri = request.requestedUri;

        if (uri.path != redirectUri.path) {
          request.response.statusCode = HttpStatus.notFound;
          await request.response.close();
          return;
        }

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.html
          ..write(_callbackPageHtml);
        await request.response.close();

        final callbackUrl = uri.replace(
          scheme: redirectUri.scheme,
          host: redirectUri.host,
          port: _pendingRedirectUri?.hasPort == true ? _pendingRedirectUri!.port : null,
        );

        await _stopCallbackServer();

        try {
          final tokens = await _handleOAuthCallback(callbackUrl.toString());
          _oauthCompleter?.complete(tokens);
        } catch (error) {
          _oauthCompleter?.completeError(error);
        } finally {
          _resetPendingOAuthState();
        }
      }),
    );
  }

  Future<AuthTokens> _handleOAuthCallback(String callbackUrl) async {
    final oauthClient = _pendingOAuthClient;
    final oauthContext = _pendingOAuthContext;
    final fallbackHandle = _pendingHandle;
    final service = _pendingService;

    if (oauthClient == null || oauthContext == null || fallbackHandle == null || service == null) {
      throw StateError('OAuth callback received without an active auth flow');
    }

    final oauthSession = await oauthClient.callback(callbackUrl, oauthContext);
    final tokens = await _buildOAuthTokens(oauthSession, fallbackHandle: fallbackHandle, service: service);
    await saveSession(tokens);
    return tokens;
  }

  Future<AuthTokens> _buildOAuthTokens(
    OAuthSession session, {
    required String fallbackHandle,
    required String service,
  }) async {
    var resolvedHandle = fallbackHandle;
    String? displayName;

    try {
      final authSession = await atp.ATProto.fromOAuthSession(session, service: service).server.getSession();
      resolvedHandle = authSession.data.handle;
    } catch (e, s) {
      log.w(
        'AuthRepository: Failed to resolve handle from session, falling back to login hint',
        error: e,
        stackTrace: s,
      );
    }

    try {
      final profile = await Bluesky.fromOAuthSession(session, service: service).actor.getProfile(actor: session.sub);
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
      service: service,
      dpopNonce: session.$dPoPNonce,
      dpopPublicKey: session.$publicKey,
      dpopPrivateKey: session.$privateKey,
      authMethod: AuthMethod.oauth,
    );
  }

  Future<void> _stopCallbackServer() async {
    await _callbackServer?.close(force: true);
    _callbackServer = null;
  }

  Future<String> _resolveServiceForIdentifier(String identifier) async {
    final client = atp.ATProto.anonymous(service: _fallbackService);

    final did = identifier.startsWith('did:')
        ? identifier
        : (await client.identity.resolveHandle(handle: identifier)).data.did;

    final didDoc = (await client.identity.resolveDid(did: did)).data.didDoc;
    return _extractServiceEndpoint(didDoc) ?? _fallbackService;
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

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _resetPendingOAuthState() {
    _pendingOAuthClient = null;
    _pendingOAuthContext = null;
    _pendingRedirectUri = null;
    _pendingHandle = null;
    _pendingService = null;
  }

  int get callbackPort => _callbackServer?.port ?? 0;
}

const String _callbackPageHtml = '''
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
        margin: 0;
      }
    </style>
  </head>
  <body>
    <main>
      <h1>Authentication Complete</h1>
      <p>You can close this window and return to Lazurite.</p>
    </main>
  </body>
</html>
''';
