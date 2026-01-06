import 'dart:convert';

/// Represents an AT Protocol content label (com.atproto.label.defs#label).
///
/// Labels are metadata tags applied to posts and profiles by labelers
/// (moderation services). They're used for content moderation, identity
/// verification, and other purposes.
class ContentLabel {
  const ContentLabel({
    required this.src,
    required this.uri,
    required this.val,
    required this.cts,
    this.cid,
    this.neg,
    this.ver,
  });

  /// Creates a ContentLabel from API JSON response.
  factory ContentLabel.fromJson(Map<String, dynamic> json) {
    return ContentLabel(
      src: json['src'] as String,
      uri: json['uri'] as String,
      val: json['val'] as String,
      cts: DateTime.parse(json['cts'] as String),
      cid: json['cid'] as String?,
      neg: json['neg'] as bool?,
      ver: json['ver'] as int?,
    );
  }

  /// Parses a list of ContentLabels from a JSON string stored in the database.
  ///
  /// Returns an empty list if the string is null or invalid.
  static List<ContentLabel> parseFromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final list = jsonDecode(jsonString) as List;
      return list.whereType<Map<String, dynamic>>().map(ContentLabel.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  /// DID of the labeler that created this label.
  final String src;

  /// AT URI of the subject (post or profile) this label applies to.
  final String uri;

  /// Short name or type of the label (e.g., "porn", "spam", "scam").
  final String val;

  /// Timestamp when the label was created.
  final DateTime cts;

  /// Optional CID targeting a specific version of the subject.
  final String? cid;

  /// If true, this label negates a previous label with the same src, uri, and val.
  final bool? neg;

  /// Label schema version (currently always 1).
  final int? ver;

  /// Convenience getter for the labeler DID.
  String get labelerDid => src;

  /// Whether this label is a negation of a previous label.
  bool get isNegation => neg == true;

  /// Whether this is a system label (prefixed with !).
  bool get isSystemLabel => val.startsWith('!');

  /// Converts to JSON map for serialization.
  Map<String, dynamic> toJson() => {
    'src': src,
    'uri': uri,
    'val': val,
    'cts': cts.toIso8601String(),
    if (cid != null) 'cid': cid,
    if (neg != null) 'neg': neg,
    if (ver != null) 'ver': ver,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentLabel &&
          runtimeType == other.runtimeType &&
          src == other.src &&
          uri == other.uri &&
          val == other.val &&
          cts == other.cts;

  @override
  int get hashCode => Object.hash(src, uri, val, cts);

  @override
  String toString() => 'ContentLabel(val: $val, src: $src, uri: $uri)';
}
