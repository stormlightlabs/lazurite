class HttpLogger {
  static const int _maxBodyLength = 200;

  static String redactAuthorizationHeader(Map<String, String> headers) {
    final redacted = <String, String>{};
    headers.forEach((key, value) {
      if (key.toLowerCase() == 'authorization') {
        redacted[key] = '[REDACTED]';
      } else {
        redacted[key] = value;
      }
    });
    return redacted.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }

  static String truncateBody(String? body) {
    if (body == null || body.isEmpty) return '<empty>';
    if (body.length <= _maxBodyLength) return body;
    return '${body.substring(0, _maxBodyLength)}...';
  }

  static String formatRequest({
    required String method,
    required String path,
    Map<String, String>? headers,
    String? body,
  }) {
    final headerStr = headers != null ? redactAuthorizationHeader(headers) : '';
    final bodyStr = truncateBody(body);
    return '$method $path${headerStr.isNotEmpty ? ' | Headers: $headerStr' : ''}${bodyStr.isNotEmpty && bodyStr != '<empty>' ? ' | Body: $bodyStr' : ''}';
  }

  static String formatResponse({required int statusCode, required Duration duration, String? body}) {
    final bodyStr = truncateBody(body);
    return '$statusCode (${duration.inMilliseconds}ms)${bodyStr.isNotEmpty && bodyStr != '<empty>' ? ' | Body: $bodyStr' : ''}';
  }
}
