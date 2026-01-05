import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jose/jose.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../core/auth/session_model.dart';
import '../../core/utils/logger.dart';
import '../identity/identity_repository.dart';
import 'dpop_nonce_store.dart';
import 'dpop_utils.dart';
import 'loopback_server.dart';
import 'oauth_client.dart';
import 'pkce_utils.dart';
import 'server_metadata.dart';
import 'session_storage.dart';

/// Callback for opening OAuth authorization URL and waiting for callback.
///
/// Returns the callback URI when the OAuth flow completes.
typedef OAuthBrowserCallback = Future<Uri> Function(String authorizeUrl, String callbackUrlPrefix);

class AuthRepository {
  AuthRepository({
    required IdentityRepository identityRepository,
    required OAuthClient oauthClient,
    required SessionStorage sessionStorage,
    required ServerMetadataRepository metadataRepository,
    required Logger logger,
    FlutterSecureStorage? secureStorage,
    DPoPNonceStore? nonceStore,
    Dio? bootstrapDio,
    OAuthBrowserCallback? oauthBrowserCallback,
  }) : _identityRepo = identityRepository,
       _oauthClient = oauthClient,
       _sessionStorage = sessionStorage,
       _metadataRepo = metadataRepository,
       _logger = logger,
       _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _nonceStore = nonceStore ?? DPoPNonceStore(),
       _bootstrapDio = bootstrapDio,
       _oauthBrowserCallback = oauthBrowserCallback;

  final IdentityRepository _identityRepo;
  final OAuthClient _oauthClient;
  final SessionStorage _sessionStorage;
  final ServerMetadataRepository _metadataRepo;
  final Logger _logger;
  final FlutterSecureStorage _secureStorage;
  final DPoPNonceStore _nonceStore;
  final Dio? _bootstrapDio;
  final OAuthBrowserCallback? _oauthBrowserCallback;
  LoopbackServer? _loopbackServer;
  static const _keyPendingSession = 'lazurite_pending_session';
  static const _uuid = Uuid();
  static const _pendingSessionTimeout = Duration(minutes: 15);

  /// Initiates the login flow for the given handle.
  ///
  /// 1. Clears any expired pending sessions.
  /// 2. Starts loopback server for OAuth callback.
  /// 3. Resolves handle to DID.
  /// 4. Resolves DID to PDS URL.
  /// 5. Discovers OAuth server metadata.
  /// 6. Generates DPoP key and PKCE challenge.
  /// 7. Performs PAR with HTTP loopback redirect URI.
  /// 8. Redirects user to OAuth authorization page (in-app browser on iOS).
  /// 9. Waits for callback via loopback server.
  /// 10. Completes login with authorization code.
  Future<Session> login(String handle) async {
    _logger.info('Initiating login for handle: $handle');
    try {
      await _clearExpiredPendingSession();

      _loopbackServer = LoopbackServer(logger: _logger);
      final redirectUri = await _loopbackServer!.start();
      _logger.debug('Loopback server started with redirect URI: $redirectUri');

      final did = await _identityRepo.resolveHandle(handle);
      if (did == null) {
        await _loopbackServer!.stop();
        _loopbackServer = null;
        throw Exception('Could not resolve handle: $handle');
      }

      final doc = await _identityRepo.resolveDidDocument(did);
      final pdsUrl = doc?.pdsEndpoint;
      if (pdsUrl == null) {
        await _loopbackServer!.stop();
        _loopbackServer = null;
        throw Exception('Could not find PDS endpoint for DID: $did');
      }

      final metadata = await _metadataRepo.discover(pdsUrl);

      final state = _uuid.v4();
      final verifier = PkceUtils.generateVerifier();
      final challenge = PkceUtils.generateChallenge(verifier);
      final dpopKey = await DPoPUtils.generateKey();

      final nonce = _nonceStore.get(pdsUrl);
      final requestUri = await _oauthClient.pushedAuthorizationRequest(
        metadata: metadata,
        key: dpopKey,
        state: state,
        codeChallenge: challenge,
        redirectUri: redirectUri,
        nonce: nonce,
      );

      _logger.debug('PAR successful, requestUri: $requestUri');

      final pending = {
        'did': did,
        'handle': handle,
        'pdsUrl': pdsUrl,
        'verifier': verifier,
        'state': state,
        'redirectUri': redirectUri,
        'dpopKey': dpopKey.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _secureStorage.write(key: _keyPendingSession, value: jsonEncode(pending));

      final authorizeUrl = _oauthClient.buildAuthorizeUrl(
        metadata: metadata,
        requestUri: requestUri,
      );

      final Uri callbackUri;

      if (Platform.isIOS && _oauthBrowserCallback != null) {
        _logger.info('Using custom OAuth browser callback for iOS');
        try {
          callbackUri = await _oauthBrowserCallback(authorizeUrl, redirectUri);
        } catch (e, st) {
          await _loopbackServer!.stop();
          _loopbackServer = null;
          _logger.error('OAuth browser callback failed', e, st);
          rethrow;
        }
        await _loopbackServer!.stop();
        _loopbackServer = null;
      } else {
        final uri = Uri.parse(authorizeUrl);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          await _loopbackServer!.stop();
          _loopbackServer = null;
          throw Exception('Could not launch browser for $uri');
        }

        _logger.info('Waiting for OAuth callback...');
        callbackUri = await _loopbackServer!.waitForCallback();
        await _loopbackServer!.stop();
        _loopbackServer = null;
      }

      _logger.debug('Received callback: $callbackUri');

      return await completeLogin(callbackUri);
    } catch (e, st) {
      await _loopbackServer?.stop();
      _loopbackServer = null;
      _logger.error('Login failed', e, st);
      rethrow;
    }
  }

  /// Completes the login flow from a callback URL.
  Future<Session> completeLogin(Uri uri) async {
    _logger.info('Completing login from callback');
    if (uri.queryParameters.containsKey('error')) {
      await _secureStorage.delete(key: _keyPendingSession);
      final error = uri.queryParameters['error'];
      _logger.error('Login callback error: $error');
      throw Exception('Login error: $error');
    }

    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];

    if (code == null || state == null) {
      _logger.error('Invalid callback URL: missing code or state');
      throw Exception('Invalid callback URL: missing code or state');
    }

    final pendingJson = await _secureStorage.read(key: _keyPendingSession);
    if (pendingJson == null) {
      _logger.error('No pending login session found');
      throw Exception('No pending login session found');
    }

    final pending = jsonDecode(pendingJson) as Map<String, dynamic>;
    if (pending['state'] != state) {
      await _secureStorage.delete(key: _keyPendingSession);
      _logger.error('State mismatch during login completion');
      throw Exception('State mismatch');
    }

    try {
      final pdsUrl = pending['pdsUrl'] as String;
      final verifier = pending['verifier'] as String;
      final did = pending['did'] as String;
      final handle = pending['handle'] as String;
      final redirectUri = pending['redirectUri'] as String;
      final dpopKey = JsonWebKey.fromJson(pending['dpopKey'] as Map<String, dynamic>);

      final metadata = await _metadataRepo.discover(pdsUrl);
      final nonce = _nonceStore.get(pdsUrl);

      final tokenResponse = await _oauthClient.exchangeCodeForToken(
        metadata: metadata,
        code: code,
        codeVerifier: verifier,
        redirectUri: redirectUri,
        key: dpopKey,
        nonce: nonce,
      );

      _logger.debug('Token exchange successful');
      _validateScopes(tokenResponse.scope, OAuthClient.kScope);
      _validateTokenClaims(tokenResponse.accessToken, did, pdsUrl);

      final session = Session(
        did: did,
        handle: handle,
        pdsUrl: pdsUrl,
        accessJwt: tokenResponse.accessToken,
        refreshJwt: tokenResponse.refreshToken ?? '',
        scope: tokenResponse.scope ?? '',
        expiresAt: DateTime.now().add(Duration(seconds: tokenResponse.expiresIn ?? 3600)),
        dpopKey: dpopKey.toJson(),
      );

      await _sessionStorage.saveSession(session);
      await _secureStorage.delete(key: _keyPendingSession);
      _logger.info('Login completed successfully for $handle');
      return session;
    } catch (e, st) {
      await _secureStorage.delete(key: _keyPendingSession);
      _logger.error('Failed to complete login', e, st);
      rethrow;
    }
  }

  /// Refreshes the session using the refresh token.
  Future<Session> refreshSession(Session session) async {
    _logger.info('Refreshing session for ${session.handle}');
    try {
      final dpopKey = JsonWebKey.fromJson(session.dpopKey);
      final metadata = await _metadataRepo.discover(session.pdsUrl);
      final nonce = _nonceStore.get(session.pdsUrl);

      final tokenResponse = await _oauthClient.refreshToken(
        metadata: metadata,
        refreshToken: session.refreshJwt,
        key: dpopKey,
        nonce: nonce,
      );

      _validateScopes(tokenResponse.scope, OAuthClient.kScope);
      _validateTokenClaims(tokenResponse.accessToken, session.did, session.pdsUrl);

      final newSession = session.copyWith(
        accessJwt: tokenResponse.accessToken,
        refreshJwt: tokenResponse.refreshToken ?? session.refreshJwt,
        scope: tokenResponse.scope ?? session.scope,
        expiresAt: DateTime.now().add(Duration(seconds: tokenResponse.expiresIn ?? 3600)),
      );

      await _sessionStorage.saveSession(newSession);
      _logger.debug('Session refreshed successfully');
      return newSession;
    } catch (e, st) {
      _logger.error('Failed to refresh session', e, st);
      rethrow;
    }
  }

  /// Revokes the session tokens on the server.
  ///
  /// This should be called during logout to invalidate tokens server-side.
  /// The method is best-effort and will not throw if revocation fails.
  Future<void> revokeSession(Session session) async {
    _logger.info('Revoking session for ${session.handle}');
    try {
      final dpopKey = JsonWebKey.fromJson(session.dpopKey);
      final metadata = await _metadataRepo.discover(session.pdsUrl);
      final nonce = _nonceStore.get(session.pdsUrl);

      await _oauthClient.revokeToken(
        metadata: metadata,
        token: session.refreshJwt,
        key: dpopKey,
        nonce: nonce,
        tokenTypeHint: 'refresh_token',
      );
    } catch (e) {
      _logger.warning('Failed to revoke session: $e');
    }
  }

  /// Clears expired pending sessions.
  Future<void> _clearExpiredPendingSession() async {
    try {
      final pendingJson = await _secureStorage.read(key: _keyPendingSession);
      if (pendingJson == null) return;

      final pending = jsonDecode(pendingJson) as Map<String, dynamic>;
      final timestampStr = pending['timestamp'] as String?;

      if (timestampStr != null) {
        final timestamp = DateTime.parse(timestampStr);
        final age = DateTime.now().difference(timestamp);

        if (age > _pendingSessionTimeout) {
          await _secureStorage.delete(key: _keyPendingSession);
        }
      }
    } catch (e) {
      await _secureStorage.delete(key: _keyPendingSession);
    }
  }

  /// Validates that granted scopes match requested scopes.
  ///
  /// Logs a warning if the server returned fewer scopes than requested.
  void _validateScopes(String? grantedScope, String requestedScope) {
    if (grantedScope == null || grantedScope.isEmpty) {
      _logger.warning('No scopes granted by server. Requested: $requestedScope');
      return;
    }

    final grantedScopes = grantedScope.split(' ').toSet();
    final requestedScopes = requestedScope.split(' ').toSet();

    final missingScopes = requestedScopes.difference(grantedScopes);
    if (missingScopes.isNotEmpty) {
      _logger.warning(
        'Server granted reduced scopes. Requested: $requestedScope, Granted: $grantedScope, Missing: ${missingScopes.join(' ')}',
      );
    }
  }

  /// Validates JWT claims (sub and iss) match expected values.
  ///
  /// Decodes the access token and verifies:
  /// - `sub` claim matches the expected DID
  /// - `iss` claim matches the expected PDS URL
  void _validateTokenClaims(String accessToken, String expectedDid, String expectedPdsUrl) {
    try {
      final jwt = JsonWebToken.unverified(accessToken);
      final claims = jwt.claims;

      final sub = claims.getTyped<String>('sub');
      if (sub != expectedDid) {
        _logger.warning('Token sub claim mismatch. Expected: $expectedDid, Got: $sub');
      }

      final iss = claims.getTyped<String>('iss');
      if (iss != null && iss != expectedPdsUrl) {
        _logger.warning('Token iss claim mismatch. Expected: $expectedPdsUrl, Got: $iss');
      }
    } catch (e) {
      _logger.warning('Failed to validate token claims: $e');
    }
  }

  /// Logs in using an app password (dev/test only).
  Future<Session> loginWithAppPassword(String handle, String password) async {
    _logger.info('Initiating App Password login for $handle');
    final did = await _identityRepo.resolveHandle(handle);
    if (did == null) {
      throw Exception('Could not resolve handle: $handle');
    }

    final doc = await _identityRepo.resolveDidDocument(did);
    final pdsUrl = doc?.pdsEndpoint;
    if (pdsUrl == null) {
      throw Exception('Could not find PDS endpoint for DID: $did');
    }

    final dio = _bootstrapDio ?? Dio(BaseOptions(baseUrl: pdsUrl));

    try {
      final response = await dio.post(
        '/xrpc/com.atproto.server.createSession',
        data: {'identifier': handle, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;

      final accessJwt = data['accessJwt'] as String;
      final refreshJwt = data['refreshJwt'] as String;
      final returnedDid = data['did'] as String;
      final returnedHandle = data['handle'] as String;

      final dpopKey = await DPoPUtils.generateKey();

      final session = Session(
        did: returnedDid,
        handle: returnedHandle,
        pdsUrl: pdsUrl,
        accessJwt: accessJwt,
        refreshJwt: refreshJwt,
        scope: 'atproto',
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
        dpopKey: dpopKey.toJson(),
      );

      await _sessionStorage.saveSession(session);
      _logger.info('App Password login successful');
      return session;
    } on DioException catch (e, st) {
      final msg = e.response?.data?['message'] ?? e.message;
      _logger.error('App Password login failed: $msg', e, st);
      throw Exception('Login failed: $msg');
    }
  }
}
