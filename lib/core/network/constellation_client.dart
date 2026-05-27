import 'dart:convert';

import 'package:http/http.dart' as http;

const String _defaultBaseUrl = 'https://constellation.microcosm.blue';
const Duration _kTimeout = Duration(seconds: 10);

class ConstellationLinkRecord {
  const ConstellationLinkRecord({required this.did, required this.collection, required this.rkey});

  factory ConstellationLinkRecord.fromJson(Map<String, dynamic> json) => ConstellationLinkRecord(
    did: json['did'] as String,
    collection: json['collection'] as String,
    rkey: json['rkey'] as String,
  );

  final String did;
  final String collection;
  final String rkey;
}

class ManyToManyItem {
  const ManyToManyItem({required this.linkRecord, required this.otherSubject});

  factory ManyToManyItem.fromJson(Map<String, dynamic> json) => ManyToManyItem(
    linkRecord: ConstellationLinkRecord.fromJson(json['linkRecord'] as Map<String, dynamic>),
    otherSubject: json['otherSubject'] as String,
  );

  final ConstellationLinkRecord linkRecord;
  final String otherSubject;
}

class ConstellationException implements Exception {
  const ConstellationException(this.message);

  final String message;

  @override
  String toString() => 'ConstellationException: $message';
}

class ConstellationClient {
  ConstellationClient({String? baseUrl, http.Client? httpClient})
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

  Uri _xrpcUri(String endpoint, Map<String, dynamic> params) {
    final filtered = <String, dynamic>{};
    for (final entry in params.entries) {
      final value = entry.value;
      if (value == null) {
        continue;
      }
      if (value is Iterable && value.isEmpty) {
        continue;
      }
      filtered[entry.key] = value;
    }
    final base = Uri.parse('$_baseUrl/xrpc/$endpoint');
    return filtered.isEmpty ? base : base.replace(queryParameters: filtered);
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    final response = await _httpClient.get(uri, headers: {'User-Agent': 'lazurite'}).timeout(_kTimeout);

    if (response.statusCode != 200) {
      throw ConstellationException('HTTP ${response.statusCode}: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  List<dynamic> _listField(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return const [];
    return value as List<dynamic>;
  }

  List<dynamic> _listFieldAny(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      if (data.containsKey(key) && data[key] != null) {
        return data[key] as List<dynamic>;
      }
    }
    return const [];
  }

  Future<int> getBacklinksCount(String subject, String source) async {
    final uri = _xrpcUri('blue.microcosm.links.getBacklinksCount', {'subject': subject, 'source': source});
    final data = await _get(uri);
    return data['total'] as int;
  }

  Future<({int total, List<String> dids, String? cursor})> getDistinct(
    String subject,
    String source, {
    int? limit,
    String? cursor,
  }) async {
    final uri = _xrpcUri('blue.microcosm.links.getBacklinkDids', {
      'subject': subject,
      'source': source,
      if (limit != null) 'limit': limit.toString(),
      'cursor': cursor,
    });
    final data = await _get(uri);
    return (
      total: data['total'] as int,
      dids: _listFieldAny(data, ['linking_dids', 'dids']).cast<String>(),
      cursor: data['cursor'] as String?,
    );
  }

  Future<({int total, List<ConstellationLinkRecord> records, String? cursor})> getBacklinks(
    String subject,
    String source, {
    int? limit,
    String? cursor,
    List<String> dids = const [],
  }) async {
    final uri = _xrpcUri('blue.microcosm.links.getBacklinks', {
      'subject': subject,
      'source': source,
      if (limit != null) 'limit': limit.toString(),
      'cursor': cursor,
      'did': dids,
    });
    final data = await _get(uri);
    final records = _listFieldAny(data, [
      'records',
      'linking_records',
    ]).map((r) => ConstellationLinkRecord.fromJson(r as Map<String, dynamic>)).toList();
    return (total: data['total'] as int, records: records, cursor: data['cursor'] as String?);
  }

  Future<({List<ManyToManyItem> items, String? cursor})> getManyToMany(
    String subject,
    String source,
    String pathToOther, {
    int? limit,
    String? cursor,
  }) async {
    final uri = _xrpcUri('blue.microcosm.links.getManyToMany', {
      'subject': subject,
      'source': source,
      'pathToOther': pathToOther,
      if (limit != null) 'limit': limit.toString(),
      'cursor': cursor,
    });
    final data = await _get(uri);
    final items = _listField(data, 'items').map((i) => ManyToManyItem.fromJson(i as Map<String, dynamic>)).toList();
    return (items: items, cursor: data['cursor'] as String?);
  }
}
