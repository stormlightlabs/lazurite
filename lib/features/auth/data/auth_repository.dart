import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:atproto_oauth/atproto_oauth.dart';
import 'package:bluesky/atproto.dart' as atp;
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/database/app_database.dart';

class AuthRepository {
  AuthRepository({required AppDatabase database}) : _database = database;
  static const String _clientId = 'https://lazurite.stormlightlabs.org/client-metadata.json';

  final AppDatabase _database;
  HttpServer? _callbackServer;
  Completer<AuthTokens?>? _oauthCompleter;

  Future<AuthTokens?> getStoredSession() async {
    final account = await _database.getActiveAccount();
    if (account == null) return null;

    return AuthTokens(
      accessToken: account.accessToken,
      refreshToken: account.refreshToken,
      expiresAt: account.expiresAt,
      did: account.did,
      handle: account.handle,
      displayName: account.displayName,
    );
  }

  Future<void> saveSession(AuthTokens tokens) async {
    await _database.insertAccount(
      AccountsCompanion(
        did: Value(tokens.did),
        handle: Value(tokens.handle),
        displayName: tokens.displayName != null ? Value(tokens.displayName) : const Value.absent(),
        accessToken: Value(tokens.accessToken),
        refreshToken: tokens.refreshToken != null ? Value(tokens.refreshToken) : const Value.absent(),
        expiresAt: tokens.expiresAt != null ? Value(tokens.expiresAt!) : const Value.absent(),
      ),
    );
  }

  Future<void> clearSession() async {
    await _database.deleteAllAccounts();
  }

  Future<AuthTokens?> loginWithOAuth(String handle) async {
    try {
      _oauthCompleter = Completer<AuthTokens?>();

      await _startCallbackServer();

      final metadata = await getClientMetadata(_clientId);
      final oauthClient = OAuthClient(metadata);

      final result = await oauthClient.authorize(handle);
      final authorizationUrl = result.$1;

      await _launchUrl(authorizationUrl);

      final tokens = await _oauthCompleter!.future;
      return tokens;
    } catch (e) {
      await _stopCallbackServer();
      rethrow;
    }
  }

  Future<AuthTokens?> loginWithAppPassword(String handle, String appPassword) async {
    try {
      final session = await atp.createSession(identifier: handle, password: appPassword);

      final tokens = AuthTokens(
        accessToken: session.data.accessJwt,
        refreshToken: session.data.refreshJwt,
        did: session.data.did,
        handle: session.data.handle,
        displayName: null,
      );

      await saveSession(tokens);
      return tokens;
    } catch (e) {
      throw Exception('Failed to login with app password: $e');
    }
  }

  Future<AuthTokens?> refreshSession(String refreshToken) async {
    try {
      final refreshed = await atp.refreshSession(refreshJwt: refreshToken);

      final tokens = AuthTokens(
        accessToken: refreshed.data.accessJwt,
        refreshToken: refreshed.data.refreshJwt,
        did: refreshed.data.did,
        handle: refreshed.data.handle,
        displayName: null,
      );

      await saveSession(tokens);
      return tokens;
    } catch (e) {
      await clearSession();
      throw Exception('Failed to refresh session: $e');
    }
  }

  Future<void> logout() async {
    await clearSession();
  }

  Future<void> _startCallbackServer() async {
    _callbackServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

    _callbackServer!.listen((request) async {
      final uri = request.requestedUri;

      if (uri.path == '/callback') {
        final code = uri.queryParameters['code'];
        final error = uri.queryParameters['error'];

        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.html
          ..write('''
            <!DOCTYPE html>
            <html>
            <head><title>Authentication Complete</title></head>
            <body>
              <h1>Authentication Complete</h1>
              <p>You can close this window and return to the app.</p>
            </body>
            </html>
          ''');

        await request.response.close();
        await _stopCallbackServer();

        if (error != null) {
          _oauthCompleter?.completeError(Exception('OAuth error: $error'));
        } else if (code != null) {
          try {
            final tokens = await _exchangeCodeForTokens(code);
            await saveSession(tokens);
            _oauthCompleter?.complete(tokens);
          } catch (e) {
            _oauthCompleter?.completeError(e);
          }
        } else {
          _oauthCompleter?.completeError(Exception('No authorization code received'));
        }
      } else {
        request.response.statusCode = 404;
        await request.response.close();
      }
    });
  }

  Future<void> _stopCallbackServer() async {
    await _callbackServer?.close();
    _callbackServer = null;
  }

  Future<AuthTokens> _exchangeCodeForTokens(String code) async {
    throw UnimplementedError('OAuth token exchange not yet implemented');
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  int get callbackPort => _callbackServer?.port ?? 0;
}

String generateCodeVerifier() {
  final random = Random.secure();
  final values = List<int>.generate(32, (_) => random.nextInt(256));
  return base64Url.encode(values).replaceAll('=', '');
}

String generateCodeChallenge(String codeVerifier) {
  final bytes = utf8.encode(codeVerifier);
  final digest = sha256.convert(bytes);
  return base64Url.encode(digest.bytes).replaceAll('=', '');
}
