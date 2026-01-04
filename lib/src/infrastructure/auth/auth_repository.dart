import 'dart:convert';

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
import 'oauth_client.dart';
import 'pkce_utils.dart';
import 'server_metadata.dart';
import 'session_storage.dart';

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
  }) : _identityRepo = identityRepository,
       _oauthClient = oauthClient,
       _sessionStorage = sessionStorage,
       _metadataRepo = metadataRepository,
       _logger = logger,
       _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _nonceStore = nonceStore ?? DPoPNonceStore(),
       _bootstrapDio = bootstrapDio;

  final IdentityRepository _identityRepo;
  final OAuthClient _oauthClient;
  final SessionStorage _sessionStorage;
  final ServerMetadataRepository _metadataRepo;
  final Logger _logger;
  final FlutterSecureStorage _secureStorage;
  final DPoPNonceStore _nonceStore;
  final Dio? _bootstrapDio;
  static const _keyPendingSession = 'lazurite_pending_session';
  static const _uuid = Uuid();
  static const _pendingSessionTimeout = Duration(minutes: 15);

  /// Initiates the login flow for the given handle.
  ///
  /// 1. Clears any expired pending sessions.
  /// 2. Resolves handle to DID.
  /// 3. Resolves DID to PDS URL.
  /// 4. Discovers OAuth server metadata.
  /// 5. Generates DPoP key and PKCE challenge.
  /// 6. Performs PAR.
  /// 7. Redirects user to PDS.
  Future<void> login(String handle) async {
    _logger.info('Initiating login for handle: $handle');
    try {
      await _clearExpiredPendingSession();

      final did = await _identityRepo.resolveHandle(handle);
      if (did == null) {
        throw Exception('Could not resolve handle: $handle');
      }

      final doc = await _identityRepo.resolveDidDocument(did);
      final pdsUrl = doc?.pdsEndpoint;
      if (pdsUrl == null) {
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
        nonce: nonce,
      );

      _logger.debug('PAR successful, requestUri: $requestUri');

      final pending = {
        'did': did,
        'handle': handle,
        'pdsUrl': pdsUrl,
        'verifier': verifier,
        'state': state,
        'dpopKey': dpopKey.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _secureStorage.write(key: _keyPendingSession, value: jsonEncode(pending));

      final authorizeUrl = _oauthClient.buildAuthorizeUrl(
        metadata: metadata,
        requestUri: requestUri,
      );

      final uri = Uri.parse(authorizeUrl);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch browser for $uri');
      }
    } catch (e, st) {
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
      final dpopKey = JsonWebKey.fromJson(pending['dpopKey'] as Map<String, dynamic>);

      final metadata = await _metadataRepo.discover(pdsUrl);
      final nonce = _nonceStore.get(pdsUrl);

      final tokenResponse = await _oauthClient.exchangeCodeForToken(
        metadata: metadata,
        code: code,
        codeVerifier: verifier,
        key: dpopKey,
        nonce: nonce,
      );

      _logger.debug('Token exchange successful');

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
