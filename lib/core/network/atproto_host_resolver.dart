import 'package:atproto_core/atproto_core.dart' as atp_core;
import 'package:lazurite/features/auth/data/models/auth_models.dart';

String resolvePdsHost(AuthTokens tokens) {
  final oauthHost = _resolveOAuthPdsHost(tokens);
  if (oauthHost != null) {
    return oauthHost;
  }

  final storedHost = normalizeAtprotoServiceHost(tokens.service);
  if (storedHost != null) {
    return storedHost;
  }

  return 'Unknown';
}

String? normalizeAtprotoServiceHost(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri != null && uri.host.isNotEmpty) {
    return uri.host;
  }

  return trimmed;
}

String? _resolveOAuthPdsHost(AuthTokens tokens) {
  if (!tokens.usesOAuth ||
      tokens.refreshToken == null ||
      tokens.dpopPublicKey == null ||
      tokens.dpopPrivateKey == null) {
    return null;
  }

  try {
    final session = atp_core.restoreOAuthSession(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken!,
      dPoPNonce: tokens.dpopNonce,
      publicKey: tokens.dpopPublicKey!,
      privateKey: tokens.dpopPrivateKey!,
    );
    return normalizeAtprotoServiceHost(session.atprotoPdsEndpoint);
  } catch (_) {
    return null;
  }
}
