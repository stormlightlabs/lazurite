import 'dart:convert';

import 'package:poptart_core/poptart_core.dart' as atcore;

export 'auth_fixtures.dart';

String base64UrlEncode(Map<String, Object?> value) =>
    base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');

String buildJwt({
  required String sub,
  String? aud,
  String? clientId,
  String? iss,
  String? scope,
  int? expEpochSeconds,
  int? iatEpochSeconds,
}) {
  final nowEpochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
  final header = base64UrlEncode(const {'alg': 'none', 'typ': 'JWT'});
  final payload = base64UrlEncode({
    'sub': sub,
    'exp': expEpochSeconds ?? nowEpochSeconds + 3600,
    'iat': iatEpochSeconds ?? nowEpochSeconds,
    'aud': ?aud,
    'client_id': ?clientId,
    'iss': ?iss,
    'scope': scope ?? (clientId == null ? 'atproto' : 'atproto transition:generic'),
  });

  return '$header.$payload.signature';
}

atcore.UnauthorizedException testUnauthorizedException(
  String methodId, {
  atcore.HttpMethod method = atcore.HttpMethod.get,
}) => atcore.UnauthorizedException(
  atcore.XRPCResponse(
    headers: const {},
    status: atcore.HttpStatus.unauthorized,
    request: atcore.XRPCRequest(method: method, url: Uri.https('bsky.social', '/xrpc/$methodId')),
    rateLimit: atcore.RateLimit.unlimited(),
    data: const atcore.XRPCError(error: 'Unauthorized', message: 'exp claim timestamp check failed'),
  ),
);
