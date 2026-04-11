/// A single result from a semantic (vector) search.
class SemanticSearchResult {
  const SemanticSearchResult({
    required this.postUri,
    required this.score,
    required this.source,
    required this.postJson,
  });

  /// AT URI of the post (e.g. at://did:plc:xxx/app.bsky.feed.post/yyy).
  final String postUri;

  /// Cosine similarity expressed as a percentage in [0, 100].
  ///
  /// Derived from the ObjectBox cosine distance: `(1 - distance) * 100`.
  final double score;

  /// Whether this post came from the user's saves ('saved') or likes ('liked').
  final String source;

  /// Raw JSON for the post, fetched from the Drift [SavedPosts] or [LikedPosts]
  /// table for display.
  final String postJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemanticSearchResult &&
          runtimeType == other.runtimeType &&
          postUri == other.postUri &&
          score == other.score &&
          source == other.source &&
          postJson == other.postJson;

  @override
  int get hashCode => Object.hash(postUri, score, source, postJson);
}
