/// Represents an ATProto repository collection.
///
/// A collection is a type of record in a user's repository (e.g.,
/// app.bsky.feed.post, app.bsky.actor.profile).
class RepoCollection {
  const RepoCollection({required this.nsid, required this.count});

  /// Creates a collection from JSON response.
  factory RepoCollection.fromJson(Map<String, dynamic> json) {
    return RepoCollection(
      nsid: json['nsid'] as String? ?? json['collection'] as String,
      count: json['count'] as int? ?? 0,
    );
  }

  /// Collection NSID (e.g., "app.bsky.feed.post").
  final String nsid;

  /// Number of records in this collection.
  final int count;

  Map<String, dynamic> toJson() {
    return {'nsid': nsid, 'count': count};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepoCollection &&
          runtimeType == other.runtimeType &&
          nsid == other.nsid &&
          count == other.count;

  @override
  int get hashCode => Object.hash(nsid, count);

  @override
  String toString() => 'RepoCollection(nsid: $nsid, count: $count)';
}
