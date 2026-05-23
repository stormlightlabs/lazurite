import 'dart:convert';

class MediaRoutePayloadCodec {
  const MediaRoutePayloadCodec._();

  static const payloadQueryParameter = 'payload';

  static String location({required String path, required Map<String, Object?> payload}) {
    return Uri(
      path: path,
      queryParameters: {payloadQueryParameter: base64Url.encode(utf8.encode(jsonEncode(payload)))},
    ).toString();
  }

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
