import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:poptart_core/poptart_core.dart' as atcore show UnauthorizedException;

typedef UnauthorizedRecoveryCallback = Future<AuthTokens?> Function();
typedef UnauthorizedClientFactory<TClient> = TClient? Function(AuthTokens tokens);
typedef UnauthorizedRecoveryLogger = void Function(Object error, StackTrace stackTrace);

/// Centralized helper for retry-on-unauthorized with token refresh.
///
/// Repositories keep their current client locally. On a 401, this asks the app
/// shell to refresh the session, rebuilds the client from fresh tokens, and
/// retries the original request once.
final class UnauthorizedRecoveryRunner<TClient> {
  UnauthorizedRecoveryRunner({
    required TClient initialClient,
    required UnauthorizedRecoveryCallback? onUnauthorized,
    required UnauthorizedClientFactory<TClient> clientFactory,
    String? expectedDid,
    this.onUnauthorizedException,
  }) : _client = initialClient,
       _onUnauthorized = onUnauthorized,
       _clientFactory = clientFactory,
       _expectedDid = expectedDid;

  TClient _client;
  final UnauthorizedRecoveryCallback? _onUnauthorized;
  final UnauthorizedClientFactory<TClient> _clientFactory;
  final String? _expectedDid;
  final UnauthorizedRecoveryLogger? onUnauthorizedException;

  TClient get client => _client;

  /// Runs [request] with the current client. Only UnauthorizedException is
  /// recoverable; all other failures belong to the caller's normal error path.
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

    // Account-scoped repositories must not switch to a refreshed client for a
    // different DID when account switching or background work overlaps recovery.
    if (_expectedDid != null && refreshedTokens.did != _expectedDid) {
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
