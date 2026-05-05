class LogRedactor {
  LogRedactor._();

  static final RegExp _jwtPattern = RegExp(r'\beyJ[A-Za-z0-9_-]{6,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b');
  static final RegExp _bearerPattern = RegExp(r'\bbearer\s+[A-Za-z0-9._~+\/-]+=*', caseSensitive: false);
  static final RegExp _sensitiveQueryParamPattern = RegExp(
    r'([?&](?:access_token|refresh_token|code|state|token|password|client_secret|authcode)=)([^&#\s|]+)',
    caseSensitive: false,
  );
  static final RegExp _sensitiveKeyValuePattern = RegExp(
    r'\b(access[_-]?token|refresh[_-]?token|password|client[_-]?secret|authorization|dpop[_-]?(?:nonce|privatekey|publickey)|app[_-]?password)\b\s*[:=]\s*([^\s,|]+)',
    caseSensitive: false,
  );

  static String redact(String input) {
    var redacted = input;
    redacted = redacted.replaceAllMapped(_sensitiveQueryParamPattern, (match) => '${match.group(1)}[REDACTED]');
    redacted = redacted.replaceAll(_bearerPattern, 'Bearer [REDACTED]');
    redacted = redacted.replaceAllMapped(_sensitiveKeyValuePattern, (match) => '${match.group(1)}: [REDACTED]');
    redacted = redacted.replaceAll(_jwtPattern, '[REDACTED_JWT]');
    return redacted;
  }
}
