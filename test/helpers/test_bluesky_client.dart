import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lazurite/core/network/poptart_client_adapter.dart';

Bluesky testBluesky({
  GetClient? getClient,
  PostClient? postClient,
  String did = 'did:plc:test',
  String handle = 'test.bsky.social',
  String service = 'bsky.social',
}) {
  return Bluesky.fromSession(
    Session(did: did, handle: handle, accessJwt: 'access-token', refreshJwt: 'refresh-token'),
    service: service,
    getClient: getClient ?? unexpectedGetClient,
    postClient: postClient ?? unexpectedPostClient,
  );
}

Future<http.Response> unexpectedGetClient(Uri url, {Map<String, String>? headers}) async {
  throw StateError('Unexpected GET ${url.path}');
}

Future<http.Response> unexpectedPostClient(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  throw StateError('Unexpected POST ${url.path}');
}

http.Response jsonResponse(Uri url, String method, Map<String, dynamic> body, {int statusCode = 200}) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
    request: http.Request(method, url),
  );
}
