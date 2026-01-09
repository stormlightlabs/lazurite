/// Represents an ATProto repository collection.
///
/// A collection is a type of record in a user's repository (e.g.,
/// app.bsky.feed.post, app.bsky.actor.profile).
///
/// Note: The com.atproto.repo.describeRepo API only returns collection NSIDs,
/// not record counts.
class RepoCollection {
  const RepoCollection({required this.nsid});

  /// Creates a collection from an NSID string.
  factory RepoCollection.fromNsid(String nsid) {
    return RepoCollection(nsid: nsid);
  }

  /// Collection NSID (e.g., "app.bsky.feed.post").
  final String nsid;

  Map<String, dynamic> toJson() {
    return {'nsid': nsid};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepoCollection && runtimeType == other.runtimeType && nsid == other.nsid;

  @override
  int get hashCode => nsid.hashCode;

  @override
  String toString() => 'RepoCollection(nsid: $nsid)';
}
