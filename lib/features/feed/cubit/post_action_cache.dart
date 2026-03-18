import 'package:lazurite/features/feed/cubit/post_action_cubit.dart';

/// In-memory cache that preserves optimistic like/repost state across
/// [PostActionCubit] recreations (e.g. after scroll recycling).
///
/// Keyed by post URI. Transient fields (loading, error) are never cached.
class PostActionCache {
  final Map<String, CachedPostAction> _cache = {};

  CachedPostAction? read(String postUri) => _cache[postUri];

  /// Persists the settled state of [state] into the cache.
  /// No-ops while either loading flag is set.
  void write(PostActionState state) {
    if (state.isLoadingLike || state.isLoadingRepost) return;
    _cache[state.postUri] = CachedPostAction(
      isLiked: state.isLiked,
      isReposted: state.isReposted,
      likeCount: state.likeCount,
      repostCount: state.repostCount,
      likeUri: state.likeUri,
      repostUri: state.repostUri,
    );
  }
}

class CachedPostAction {
  const CachedPostAction({
    required this.isLiked,
    required this.isReposted,
    required this.likeCount,
    required this.repostCount,
    this.likeUri,
    this.repostUri,
  });

  final bool isLiked;
  final bool isReposted;
  final int likeCount;
  final int repostCount;
  final String? likeUri;
  final String? repostUri;
}
