/// Represents an ATProto repository record.
///
/// A record is an individual data item in a collection, with its own URI,
/// CID, and JSON content.
class RepoRecord {
  const RepoRecord({
    required this.uri,
    required this.cid,
    required this.value,
    this.indexedAt,
    this.hasBlob,
  });

  /// Creates a record from JSON response.
  factory RepoRecord.fromJson(Map<String, dynamic> json) {
    final value = json['value'] as Map<String, dynamic>;
    return RepoRecord(
      uri: json['uri'] as String,
      cid: json['cid'] as String,
      value: value,
      indexedAt: json['indexedAt'] != null ? DateTime.parse(json['indexedAt'] as String) : null,
      hasBlob: _detectBlobs(value),
    );
  }
  final String uri;
  final String cid;
  final Map<String, dynamic> value;
  final DateTime? indexedAt;
  final bool? hasBlob;

  /// The AT URI of this record (e.g., at://did:plc:abc.../app.bsky.feed.post/123).
  String get rkey {
    final parts = uri.split('/');
    return parts.isNotEmpty ? parts.last : '';
  }

  /// Extracts the collection NSID from the URI.
  String get collection {
    final uriWithoutScheme = uri.startsWith('at://') ? uri.substring(5) : uri;
    final parts = uriWithoutScheme.split('/');
    return parts.length >= 2 ? parts[1] : '';
  }

  Map<String, dynamic> toJson() {
    return {
      'uri': uri,
      'cid': cid,
      'value': value,
      if (indexedAt != null) 'indexedAt': indexedAt!.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RepoRecord && uri == other.uri && cid == other.cid;

  @override
  int get hashCode => Object.hash(uri, cid);

  @override
  String toString() => 'RepoRecord(uri: $uri, cid: $cid)';

  /// Detects if the given JSON value contains blob references.
  ///
  /// Blobs in ATProto follow a consistent structure:
  /// - Objects with `$type: "blob"`
  /// - Objects containing `ref` with `$link` property (CID reference)
  static bool _detectBlobs(dynamic value, [Set<String>? seen]) {
    seen ??= <String>{};

    if (value is Map<String, dynamic>) {
      final map = value;

      if (map[r'$type'] == 'blob') {
        return true;
      }

      if (map.containsKey('ref')) {
        final refValue = map['ref'];
        if (refValue is Map && refValue.containsKey(r'$link')) {
          return true;
        }
      }

      for (final v in map.values) {
        if (_detectBlobs(v, seen)) {
          return true;
        }
      }
    } else if (value is List) {
      for (final item in value) {
        if (_detectBlobs(item, seen)) {
          return true;
        }
      }
    }

    return false;
  }
}
