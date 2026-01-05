import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/features/feeds/presentation/screens/widgets/feed_post_card.dart';
import 'package:lazurite/src/features/thread/application/thread_notifier.dart';
import 'package:lazurite/src/features/thread/application/thread_providers.dart';
import 'package:lazurite/src/features/thread/infrastructure/thread_repository.dart';
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

          final parents = thread.parent != null ? _getParents(thread.parent!) : <ThreadViewPost>[];
          final replies = thread.replies;

          return CustomScrollView(
            slivers: [
              if (parents.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => FeedPostCard(item: _mapToFeedPost(parents[index])),
                    childCount: parents.length,
                  ),
                ),

              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).dividerColor, width: 4),
                    ),
                  ),
                  child: FeedPostCard(item: _mapToFeedPost(thread)),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => FeedPostCard(item: _mapToFeedPost(replies[index])),
                  childCount: replies.length,
                ),
              ),
            ],
          );
        },
      ),
    );
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
