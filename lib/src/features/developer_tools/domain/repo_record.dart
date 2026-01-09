/// Represents an ATProto repository record.
///
/// A record is an individual data item in a collection, with its own URI,
/// CID, and JSON content.
class RepoRecord {
  const RepoRecord({required this.uri, required this.cid, required this.value, this.indexedAt});

  /// Creates a record from JSON response.
  factory RepoRecord.fromJson(Map<String, dynamic> json) {
    return RepoRecord(
      uri: json['uri'] as String,
      cid: json['cid'] as String,
      value: json['value'] as Map<String, dynamic>,
      indexedAt: json['indexedAt'] != null ? DateTime.parse(json['indexedAt'] as String) : null,
    );
  }

  /// The AT URI of this record (e.g., at://did:plc:abc.../app.bsky.feed.post/123).
  final String uri;

  /// The CID (Content Identifier) of this record version.
  final String cid;

  /// The JSON content of the record.
  final Map<String, dynamic> value;

  /// When this record was indexed (optional).
  final DateTime? indexedAt;

  /// Extracts the rkey (record key) from the URI.
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
      identical(this, other) ||
      other is RepoRecord &&
          runtimeType == other.runtimeType &&
          uri == other.uri &&
          cid == other.cid;

  @override
  int get hashCode => Object.hash(uri, cid);

  @override
  String toString() => 'RepoRecord(uri: $uri, cid: $cid)';
}
