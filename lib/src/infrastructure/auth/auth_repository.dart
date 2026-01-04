import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jose/jose.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../core/auth/session_model.dart';
import '../identity/identity_repository.dart';
import 'dpop_utils.dart';
import 'oauth_client.dart';
import 'pkce_utils.dart';
import 'session_storage.dart';

class AuthRepository {
  AuthRepository({
    required IdentityRepository identityRepository,
    required OAuthClient oauthClient,
    required SessionStorage sessionStorage,
    FlutterSecureStorage? secureStorage,
  }) : _identityRepo = identityRepository,
       _oauthClient = oauthClient,
       _sessionStorage = sessionStorage,
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final IdentityRepository _identityRepo;
  final OAuthClient _oauthClient;
  final SessionStorage _sessionStorage;
  final FlutterSecureStorage _secureStorage;
  static const _keyPendingSession = 'lazurite_pending_session';
  static const _uuid = Uuid();

  /// Initiates the login flow for the given handle.
  ///
  /// 1. Resolves handle to DID.
  /// 2. Resolves DID to PDS URL.
  /// 3. Generates DPoP key and PKCE challenge.
  /// 4. Performs PAR.
  /// 5. Redirects user to PDS.
  Future<void> login(String handle) async {
    final did = await _identityRepo.resolveHandle(handle);
    if (did == null) {
      throw Exception('Could not resolve handle: $handle');
    }

    final doc = await _identityRepo.resolveDidDocument(did);
    final pdsUrl = doc?.pdsEndpoint;
    if (pdsUrl == null) {
      throw Exception('Could not find PDS endpoint for DID: $did');
    }

    final state = _uuid.v4();
    final verifier = PkceUtils.generateVerifier();
    final challenge = PkceUtils.generateChallenge(verifier);
    final dpopKey = await DPoPUtils.generateKey();

    final requestUri = await _oauthClient.pushedAuthorizationRequest(
      pdsUrl: pdsUrl,
      key: dpopKey,
      state: state,
      codeChallenge: challenge,
    );

    final pending = {
      'did': did,
      'handle': handle,
      'pdsUrl': pdsUrl,
      'verifier': verifier,
      'state': state,
      'dpopKey': dpopKey.toJson(),
    };
    await _secureStorage.write(key: _keyPendingSession, value: jsonEncode(pending));

    final authorizeUrl = _oauthClient.buildAuthorizeUrl(pdsUrl: pdsUrl, requestUri: requestUri);

    final uri = Uri.parse(authorizeUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch browser for $uri');
    }
  }

  /// Completes the login flow from a callback URL.
  Future<Session> completeLogin(Uri uri) async {
    if (uri.queryParameters.containsKey('error')) {
      throw Exception('Login error: ${uri.queryParameters['error']}');
    }

    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];

    if (code == null || state == null) {
      throw Exception('Invalid callback URL: missing code or state');
    }

    final pendingJson = await _secureStorage.read(key: _keyPendingSession);
    if (pendingJson == null) {
      throw Exception('No pending login session found');
    }

    final pending = jsonDecode(pendingJson) as Map<String, dynamic>;
    if (pending['state'] != state) {
      throw Exception('State mismatch');
    }

    try {
      final pdsUrl = pending['pdsUrl'] as String;
      final verifier = pending['verifier'] as String;
      final did = pending['did'] as String;
      final handle = pending['handle'] as String;
      final dpopKey = JsonWebKey.fromJson(pending['dpopKey'] as Map<String, dynamic>);

      final tokenResponse = await _oauthClient.exchangeCodeForToken(
        pdsUrl: pdsUrl,
        code: code,
        codeVerifier: verifier,
        key: dpopKey,
      );

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
      return session;
    } catch (e) {
      rethrow;
    }
  }

  /// Refreshes the session using the refresh token.
  Future<Session> refreshSession(Session session) async {
    try {
      final dpopKey = JsonWebKey.fromJson(session.dpopKey);
      final tokenResponse = await _oauthClient.refreshToken(
        pdsUrl: session.pdsUrl,
        refreshToken: session.refreshJwt,
        key: dpopKey,
      );

      final newSession = session.copyWith(
        accessJwt: tokenResponse.accessToken,
        refreshJwt: tokenResponse.refreshToken ?? session.refreshJwt,
        scope: tokenResponse.scope ?? session.scope,
        expiresAt: DateTime.now().add(Duration(seconds: tokenResponse.expiresIn ?? 3600)),
      );

      await _sessionStorage.saveSession(newSession);
      return newSession;
    } catch (e) {
      // TODO: If refresh fails, we might want to clear session or let caller handle it.
      rethrow;
    }
  }
}
