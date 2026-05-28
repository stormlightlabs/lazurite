import 'package:lazurite/features/auth/data/models/auth_models.dart';

/// Avoids refresh-token churn when an old in-memory client receives 401 shortly
/// after another client already refreshed and published newer tokens.
final class RecentAuthRecoveryPolicy {
  RecentAuthRecoveryPolicy({this.reuseWindow = const Duration(minutes: 1), DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final Duration reuseWindow;
  final DateTime Function() _now;
  final Map<String, _RecentAuthRecovery> _recoveriesByDid = <String, _RecentAuthRecovery>{};

  bool shouldReuse(AuthTokens tokens) {
    if (tokens.isExpired) {
      return false;
    }

    final recovery = _recoveriesByDid[tokens.did];
    if (recovery == null || recovery.accessToken != tokens.accessToken) {
      return false;
    }

    return _now().difference(recovery.completedAt) <= reuseWindow;
  }

  void recordSuccess(AuthTokens tokens) {
    _recoveriesByDid[tokens.did] = _RecentAuthRecovery(accessToken: tokens.accessToken, completedAt: _now());
  }

  void clear(String did) => _recoveriesByDid.remove(did);
}

final class _RecentAuthRecovery {
  const _RecentAuthRecovery({required this.accessToken, required this.completedAt});

  final String accessToken;
  final DateTime completedAt;
}
