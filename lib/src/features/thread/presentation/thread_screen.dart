import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/core/utils/error_message.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/features/feeds/presentation/screens/widgets/feed_post_card.dart';
import 'package:lazurite/src/features/settings/application/settings_providers.dart';
import 'package:lazurite/src/features/settings/domain/bluesky_preferences.dart';
import 'package:lazurite/src/features/thread/application/thread_notifier.dart';
import 'package:lazurite/src/features/thread/application/thread_providers.dart';
import 'package:lazurite/src/features/thread/domain/thread.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/blocked_post_card.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/not_found_post_card.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/thread_line_connector.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/thread_reply_item.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/threadgate_indicator.dart';
import 'package:lazurite/src/infrastructure/db/daos/feed_content_dao.dart';

class ThreadScreen extends ConsumerStatefulWidget {
  const ThreadScreen({required this.postUri, super.key});

  final String postUri;

  @override
  ConsumerState<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends ConsumerState<ThreadScreen> {
  bool _flattenedView = false;

  @override
  Widget build(BuildContext context) {
    final threadAsync = ref.watch(threadProvider(widget.postUri));
    final threadCacheAsync = ref.watch(threadCacheProvider(widget.postUri));
    final threadViewPref = ref.watch(threadViewPrefProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thread'),
        actions: [
          IconButton(
            icon: Icon(_flattenedView ? Icons.account_tree : Icons.list),
            tooltip: _flattenedView ? 'Switch to Tree View' : 'Switch to Flattened View',
            onPressed: () => setState(() => _flattenedView = !_flattenedView),
          ),
          if (!_flattenedView)
            threadAsync.maybeWhen(
              data: (thread) => PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'Thread options',
                onSelected: (value) {
                  if (value == 'collapse_all') {
                    _collapseAllReplies(thread);
                  } else if (value == 'expand_all') {
                    ref.read(threadCollapseStateProvider.notifier).expandAll();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'collapse_all',
                    child: Row(
                      children: [
                        Icon(Icons.unfold_less),
                        SizedBox(width: 12),
                        Text('Collapse all replies'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'expand_all',
                    child: Row(
                      children: [
                        Icon(Icons.unfold_more),
                        SizedBox(width: 12),
                        Text('Expand all replies'),
                      ],
                    ),
                  ),
                ],
              ),
              orElse: () => const SizedBox.shrink(),
            ),
        ],
      ),
      body: threadAsync.when(
        loading: () => const LoadingView(),
        error: (err, stack) => ErrorView(
          title: 'Could not load thread',
          message: errorMessage(err),
          onRetry: () => ref.refresh(threadProvider(widget.postUri)),
        ),
        data: (thread) {
          final pref = threadViewPref.maybeWhen(
            data: (data) => data,
            orElse: () => ThreadViewPref.defaultPref,
          );

          if (_flattenedView) {
            return _buildFlattenedView(threadCacheAsync, thread);
          }

          return _buildTreeView(thread, pref);
        },
      ),
    );
  }

  Widget _buildTreeView(ThreadViewPost thread, ThreadViewPref pref) {
    final parents = thread.parent != null ? _getParents(thread.parent!) : <ThreadViewPost>[];
    final sortedReplies = _sortReplies(thread.replies, pref);

    return CustomScrollView(
      slivers: [
        if (parents.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final parent = parents[index];
              final position = _getThreadLinePosition(
                index: index,
                total: parents.length,
                isParentChain: true,
              );
              return _buildThreadPost(parent, position: position);
            }, childCount: parents.length),
          ),

        SliverToBoxAdapter(child: _buildFocalPost(thread)),

        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final reply = sortedReplies[index];
            return _buildReplyTree(reply, depth: 1);
          }, childCount: sortedReplies.length),
        ),
      ],
    );
  }

  /// Sorts replies based on user thread view preferences.
  List<ThreadViewPost> _sortReplies(List<ThreadViewPost> replies, ThreadViewPref pref) {
    if (replies.isEmpty) return replies;

    final sortedReplies = List<ThreadViewPost>.from(replies);

    sortedReplies.sort((a, b) {
      switch (pref.sort) {
        case ThreadSortOrder.oldest:
          final aTime = a.post.indexedAt ?? DateTime(1970);
          final bTime = b.post.indexedAt ?? DateTime(1970);
          return aTime.compareTo(bTime);
        case ThreadSortOrder.newest:
          final aTime = a.post.indexedAt ?? DateTime(1970);
          final bTime = b.post.indexedAt ?? DateTime(1970);
          return bTime.compareTo(aTime);
        case ThreadSortOrder.mostLikes:
          return b.post.likeCount.compareTo(a.post.likeCount);
        case ThreadSortOrder.random:
          final aTime = a.post.indexedAt ?? DateTime(1970);
          final bTime = b.post.indexedAt ?? DateTime(1970);
          return aTime.compareTo(bTime);
        case ThreadSortOrder.hotness:
          return b.post.likeCount.compareTo(a.post.likeCount);
      }
    });

    if (pref.prioritizeFollowedUsers) {
      final followed = <ThreadViewPost>[];
      final notFollowed = <ThreadViewPost>[];

      for (final reply in sortedReplies) {
        final isFollowing = reply.post.author.viewer?['following'] != null;
        if (isFollowing) {
          followed.add(reply);
        } else {
          notFollowed.add(reply);
        }
      }

      return [...followed, ...notFollowed];
    }

    return sortedReplies;
  }

  /// Builds a single thread post with appropriate state handling
  Widget _buildThreadPost(
    ThreadViewPost view, {
    ThreadLinePosition position = ThreadLinePosition.none,
    bool isReply = false,
  }) {
    if (view.isBlocked) {
      return Stack(
        children: [
          if (position != ThreadLinePosition.none) ThreadLineConnector(position: position),
          const BlockedPostCard(),
        ],
      );
    }

    if (view.isNotFound) {
      return Stack(
        children: [
          if (position != ThreadLinePosition.none) ThreadLineConnector(position: position),
          const NotFoundPostCard(),
        ],
      );
    }

    return Stack(
      children: [
        if (position != ThreadLinePosition.none) ThreadLineConnector(position: position),
        Padding(
          padding: isReply ? const EdgeInsets.only(left: 24) : EdgeInsets.zero,
          child: FeedPostCard(item: _mapToFeedPost(view)),
        ),
      ],
    );
  }

  /// Builds the focal post with visual distinction
  Widget _buildFocalPost(ThreadViewPost thread) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.45), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FeedPostCard(item: _mapToFeedPost(thread)),
          if (thread.threadgate != null)
            Padding(
              padding: const EdgeInsets.only(left: 68, bottom: 12),
              child: ThreadgateIndicator(threadgate: thread.threadgate!),
            ),
        ],
      ),
    );
  }

  /// Determines thread line position based on index and context
  ThreadLinePosition _getThreadLinePosition({
    required int index,
    required int total,
    required bool isParentChain,
  }) {
    if (total == 0) return ThreadLinePosition.none;
    if (total == 1) return isParentChain ? ThreadLinePosition.bottom : ThreadLinePosition.top;

    if (index == 0) {
      return isParentChain ? ThreadLinePosition.top : ThreadLinePosition.top;
    } else if (index == total - 1) {
      return isParentChain ? ThreadLinePosition.bottom : ThreadLinePosition.bottom;
    } else {
      return ThreadLinePosition.middle;
    }
  }

  /// Helper to walk up ancestors
  List<ThreadViewPost> _getParents(ThreadViewPost parent) {
    final list = <ThreadViewPost>[];
    var current = parent;
    while (true) {
      list.add(current);
      if (current.parent == null) break;
      current = current.parent!;
    }
    return list.reversed.toList();
  }

  /// Collects all reply URIs for collapse/expand all
  void _collapseAllReplies(ThreadViewPost thread) {
    final uris = <String>[];
    void collectUris(ThreadViewPost post) {
      if (post.replies.isNotEmpty) {
        uris.add(post.post.uri);
        for (final reply in post.replies) {
          collectUris(reply);
        }
      }
    }

    for (final reply in thread.replies) {
      collectUris(reply);
    }

    ref.read(threadCollapseStateProvider.notifier).collapseAll(uris);
  }

  /// Recursively builds reply tree with nesting and collapse support
  Widget _buildReplyTree(ThreadViewPost post, {required int depth}) {
    final isCollapsed = ref.watch(
      threadCollapseStateProvider.select((state) => state[post.post.uri] ?? false),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ThreadReplyItem(
          post: post,
          depth: depth,
          isCollapsed: isCollapsed,
          onToggleCollapse: () {
            ref.read(threadCollapseStateProvider.notifier).toggle(post.post.uri);
          },
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: (!isCollapsed && post.replies.isNotEmpty)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: post.replies
                      .map((reply) => _buildReplyTree(reply, depth: depth + 1))
                      .toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Helper to flatten replies purely for the list
  List<ThreadViewPost> _getAllReplies(ThreadViewPost root) {
    final list = <ThreadViewPost>[];
    for (final reply in root.replies) {
      list.add(reply);
      list.addAll(_getAllReplies(reply));
    }
    return list;
  }

  Widget _buildFlattenedView(AsyncValue<List<FeedPost>> cachedFeedContent, ThreadViewPost thread) {
    return cachedFeedContent.when(
      data: (items) {
        final feedContentItems = items.isEmpty ? _buildFallbackLinearTimeline(thread) : items;
        return CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => FeedPostCard(item: feedContentItems[index]),
                childCount: feedContentItems.length,
              ),
            ),
          ],
        );
      },
      loading: () => const LoadingView(),
      error: (err, stack) => ErrorView(
        title: 'Thread cache unavailable',
        message: errorMessage(err),
        onRetry: () => ref.refresh(threadProvider(widget.postUri)),
      ),
    );
  }

  List<FeedPost> _buildFallbackLinearTimeline(ThreadViewPost thread) {
    final parents = thread.parent != null ? _getParents(thread.parent!) : <ThreadViewPost>[];
    return [...parents, thread, ..._getAllReplies(thread)].map(_mapToFeedPost).toList();
  }

  FeedPost _mapToFeedPost(ThreadViewPost view) => view.post.toFeedPost();
}
