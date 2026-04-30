import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

const String _defaultBaseUrl = 'https://slingshot.microcosm.blue';
const Duration _kTimeout = Duration(seconds: 10);

class SlingshotException implements Exception {
  const SlingshotException(this.message);

  final String message;

  @override
  String toString() => 'SlingshotException: $message';
}

class SlingshotMiniDoc {
  const SlingshotMiniDoc({required this.did, required this.handle, required this.pds, this.signingKey});

  final String did;
  final String handle;
  final String pds;
  final String? signingKey;
}

class SlingshotClient {
  SlingshotClient({String? baseUrl, http.Client? httpClient})
    : _baseUrl = _normalizeBaseUrl(baseUrl),
      _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final http.Client _httpClient;

  String get baseUrl => _baseUrl;

  static String _normalizeBaseUrl(String? baseUrl) {
    final trimmed = baseUrl?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return _defaultBaseUrl;
    }
    return trimmed.replaceFirst(RegExp(r'/+$'), '');
  }

  Uri _resolveMiniDocUri(String identifier) {
    final base = Uri.parse('$_baseUrl/xrpc/com.bad-example.identity.resolveMiniDoc');
    return base.replace(queryParameters: {'identifier': identifier});
  }

  Future<SlingshotMiniDoc> resolveMiniDoc(String identifier) async {
    final normalizedIdentifier = identifier.trim();
    if (normalizedIdentifier.isEmpty) {
      throw const SlingshotException('identifier must not be empty');
    }

    final response = await _httpClient
        .get(_resolveMiniDocUri(normalizedIdentifier), headers: {'User-Agent': 'lazurite'})
        .timeout(_kTimeout);
    if (response.statusCode != 200) {
      throw SlingshotException('HTTP ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const SlingshotException('invalid resolveMiniDoc response payload');
    }

    final did = (decoded['did'] as String? ?? '').trim();
    final handle = (decoded['handle'] as String? ?? '').trim();
    final pds = (decoded['pds'] as String? ?? '').trim();
    final signingKey = (decoded['signing_key'] as String?)?.trim();

    if (did.isEmpty || handle.isEmpty || pds.isEmpty) {
      throw const SlingshotException('resolveMiniDoc payload missing required fields');
    }

    return SlingshotMiniDoc(
      did: did,
      handle: handle,
      pds: pds,
      signingKey: signingKey == null || signingKey.isEmpty ? null : signingKey,
    );
  }
}
