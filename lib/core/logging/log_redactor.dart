class LogRedactor {
  LogRedactor._();

  static const String _sensitiveKeyPattern =
      r'access[_-]?token|refresh[_-]?token|token|authcode|password|client[_-]?secret|authorization|'
      r'dpop(?:[_-]?nonce|[_-]?private[_-]?key|[_-]?public[_-]?key|nonce|privatekey|publickey)|'
      r'app[_-]?password';
  static const String _sensitiveJsonOnlyKeyPattern = r'code|state|authcode';

  static final RegExp _jwtPattern = RegExp(r'\beyJ[A-Za-z0-9_-]{6,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b');
  static final RegExp _bearerPattern = RegExp(r'\bbearer\s+[A-Za-z0-9._~+\/-]+=*', caseSensitive: false);
  static final RegExp _sensitiveQueryParamPattern = RegExp(
    r'([?&](?:access_token|refresh_token|code|state|token|password|client_secret|authcode)=)([^&#\s|]+)',
    caseSensitive: false,
  );
  static final RegExp _sensitiveJsonKeyValuePattern = RegExp(
    '("($_sensitiveKeyPattern|$_sensitiveJsonOnlyKeyPattern)"\\s*:\\s*)"(?:[^"\\\\]|\\\\.)*"',
    caseSensitive: false,
  );
  static final RegExp _sensitiveScalarKeyValuePattern = RegExp(
    '(?<![?&])\\b($_sensitiveKeyPattern)\\b\\s*[:=]\\s*(?:"(?:[^"\\\\]|\\\\.)*"|\'(?:[^\'\\\\]|\\\\.)*\'|[^\\s,|}]+)',
    caseSensitive: false,
  );
  static final RegExp _sensitiveScalarCodeStatePattern = RegExp(
    '(?<![?&])\\b($_sensitiveJsonOnlyKeyPattern)\\b\\s*=\\s*(?:"(?:[^"\\\\]|\\\\.)*"|\'(?:[^\'\\\\]|\\\\.)*\'|[^\\s,|}]+)',
    caseSensitive: false,
  );

  static String redact(String input) {
    var redacted = input;
    redacted = redacted.replaceAllMapped(_sensitiveQueryParamPattern, (match) => '${match.group(1)}[REDACTED]');
    redacted = redacted.replaceAll(_bearerPattern, 'Bearer [REDACTED]');
    redacted = redacted.replaceAllMapped(_sensitiveJsonKeyValuePattern, (match) => '${match.group(1)}"[REDACTED]"');
    redacted = redacted.replaceAllMapped(_sensitiveScalarKeyValuePattern, (match) => '${match.group(1)}: [REDACTED]');
    redacted = redacted.replaceAllMapped(_sensitiveScalarCodeStatePattern, (match) => '${match.group(1)}: [REDACTED]');
    redacted = redacted.replaceAll(_jwtPattern, '[REDACTED_JWT]');
    return redacted;
  }
}
