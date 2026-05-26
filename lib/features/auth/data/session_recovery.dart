import 'package:lazurite/features/auth/data/models/auth_models.dart';

typedef AuthTokenRefresh = Future<AuthTokens?> Function(AuthTokens tokens);
typedef AuthTokenUpdated = void Function(AuthTokens tokens);

/// Refreshes the current session and returns the refreshed tokens only when
/// they still belong to [accountDid].
Future<AuthTokens?> refreshCurrentAccountSession({
  required AuthTokens? currentTokens,
  required String accountDid,
  required AuthTokenRefresh refresh,
  required AuthTokenUpdated onRefreshed,
}) async {
  if (currentTokens == null) {
    return null;
  }

  final refreshed = await refresh(currentTokens);
  if (refreshed == null || refreshed.did != accountDid) {
    return null;
  }

  onRefreshed(refreshed);
  return refreshed;
}
