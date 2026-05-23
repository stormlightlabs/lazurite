import 'dart:convert';

/// Encodes and decodes media viewer route payloads.
///
/// The image and video viewers are full-screen routes that are often opened
/// with rich in-memory arguments. GoRouter's `extra` field is transient, so it
/// can disappear when a route is restored from its URL. This codec stores the
/// minimum viewer state in a URL-safe `payload` query parameter so the route can
/// be reconstructed without relying only on `extra`.
class MediaRoutePayloadCodec {
  const MediaRoutePayloadCodec._();

  /// Query parameter containing the base64url-encoded JSON payload.
  static const payloadQueryParameter = 'payload';

  /// Builds a route location for [path] with [payload] encoded in the query.
  static String location({required String path, required Map<String, Object?> payload}) {
    return Uri(
      path: path,
      queryParameters: {payloadQueryParameter: base64Url.encode(utf8.encode(jsonEncode(payload)))},
    ).toString();
  }

  /// Decodes a route payload from [uri].
  ///
  /// Returns `null` instead of throwing for missing, malformed, or non-object
  /// payloads because route parsing must be safe for arbitrary external URLs.
  static Map<String, Object?>? tryDecode(Uri uri) {
    final encodedPayload = uri.queryParameters[payloadQueryParameter];
    if (encodedPayload == null || encodedPayload.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(encodedPayload))));
      if (decoded is! Map) {
        return null;
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException {
      return null;
    }
  }
}
