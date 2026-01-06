import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/features/feeds/presentation/screens/widgets/feed_post_card.dart';
import 'package:lazurite/src/features/thread/application/thread_notifier.dart';
import 'package:lazurite/src/features/thread/application/thread_providers.dart';
import 'package:lazurite/src/features/thread/infrastructure/thread_repository.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/blocked_post_card.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/not_found_post_card.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/thread_line_connector.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thread'),
        actions: [
          IconButton(
            icon: Icon(_flattenedView ? Icons.account_tree : Icons.list),
            tooltip: _flattenedView ? 'Switch to Tree View' : 'Switch to Flattened View',
            onPressed: () => setState(() => _flattenedView = !_flattenedView),
          ),
        ],
      ),
      body: threadAsync.when(
        loading: () => const LoadingView(),
        error: (err, stack) => ErrorView(
          title: 'Could not load thread',
          message: err.toString(),
          onRetry: () => ref.refresh(threadProvider(widget.postUri)),
        ),
        data: (thread) {
          if (_flattenedView) {
            return _buildFlattenedView(threadCacheAsync, thread);
          }

          return _buildTreeView(thread);
        },
      ),
    );
  }

  Widget _buildTreeView(ThreadViewPost thread) {
    final parents = thread.parent != null ? _getParents(thread.parent!) : <ThreadViewPost>[];
    final replies = thread.replies;

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
            final reply = replies[index];
            final position = _getThreadLinePosition(
              index: index,
              total: replies.length,
              isParentChain: false,
            );
            return _buildThreadPost(reply, position: position, isReply: true);
          }, childCount: replies.length),
        ),
      ],
    );
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
        color: colorScheme.primaryContainer.withValues(alpha: 0.1),
        border: Border(
          left: BorderSide(color: colorScheme.primary, width: 3),
          bottom: BorderSide(color: theme.dividerColor, width: 4),
        ),
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
        message: err.toString(),
        onRetry: () => ref.refresh(threadProvider(widget.postUri)),
      ),
    );
  }

  List<FeedPost> _buildFallbackLinearTimeline(ThreadViewPost thread) {
    final parents = thread.parent != null ? _getParents(thread.parent!) : <ThreadViewPost>[];
    final replies = _getAllReplies(thread);
    final linear = [...parents, thread, ...replies];

    return [for (var i = 0; i < linear.length; i++) _mapToFeedPost(linear[i])];
  }

  FeedPost _mapToFeedPost(ThreadViewPost view) => view.post.toFeedPost();
}
