import 'package:atproto_core/atproto_core.dart' as atcore show UnauthorizedException;
import 'package:lazurite/features/auth/data/models/auth_models.dart';

typedef UnauthorizedRecoveryCallback = Future<AuthTokens?> Function();
typedef UnauthorizedClientFactory<TClient> = TClient? Function(AuthTokens tokens);
typedef UnauthorizedRecoveryLogger = void Function(Object error, StackTrace stackTrace);

/// Centralized helper for retry-on-unauthorized with token refresh.
final class UnauthorizedRecoveryRunner<TClient> {
  UnauthorizedRecoveryRunner({
    required TClient initialClient,
    required UnauthorizedRecoveryCallback? onUnauthorized,
    required UnauthorizedClientFactory<TClient> clientFactory,
    this.onUnauthorizedException,
  }) : _client = initialClient,
       _onUnauthorized = onUnauthorized,
       _clientFactory = clientFactory;

  TClient _client;
  final UnauthorizedRecoveryCallback? _onUnauthorized;
  final UnauthorizedClientFactory<TClient> _clientFactory;
  final UnauthorizedRecoveryLogger? onUnauthorizedException;

  TClient get client => _client;

  Future<T> run<T>(Future<T> Function(TClient client) request) async {
    try {
      return await request(_client);
    } on atcore.UnauthorizedException catch (error, stackTrace) {
      onUnauthorizedException?.call(error, stackTrace);
      final recovered = await _recoverAuthSession();
      if (!recovered) {
        rethrow;
      }
      return request(_client);
    }
  }

  Future<bool> _recoverAuthSession() async {
    final callback = _onUnauthorized;
    if (callback == null) {
      return false;
    }

    final refreshedTokens = await callback();
    if (refreshedTokens == null) {
      return false;
    }

    final refreshedClient = _clientFactory(refreshedTokens);
    if (refreshedClient == null) {
      return false;
    }

    _client = refreshedClient;
    return true;
  }
}
