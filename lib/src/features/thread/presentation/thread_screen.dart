import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/features/thread/application/thread_notifier.dart';
import 'package:lazurite/src/features/thread/application/thread_providers.dart';
import 'package:lazurite/src/features/thread/infrastructure/thread_repository.dart';
import 'package:lazurite/src/features/timeline/presentation/widgets/post_card.dart';
import 'package:lazurite/src/infrastructure/db/daos/timeline_dao.dart';

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
                    (context, index) => PostCard(item: _mapToTimelineItem(parents[index])),
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
                  child: PostCard(item: _mapToTimelineItem(thread)),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => PostCard(item: _mapToTimelineItem(replies[index])),
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

  Widget _buildFlattenedView(
    AsyncValue<List<TimelineFeedItem>> cachedTimeline,
    ThreadViewPost thread,
  ) {
    return cachedTimeline.when(
      data: (items) {
        final timelineItems = items.isEmpty ? _buildFallbackLinearTimeline(thread) : items;
        return CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => PostCard(item: timelineItems[index]),
                childCount: timelineItems.length,
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

  List<TimelineFeedItem> _buildFallbackLinearTimeline(ThreadViewPost thread) {
    final parents = thread.parent != null ? _getParents(thread.parent!) : <ThreadViewPost>[];
    final replies = _getAllReplies(thread);
    final linear = [...parents, thread, ...replies];

    return [
      for (var i = 0; i < linear.length; i++)
        _mapToTimelineItem(linear[i], sortKey: i.toString().padLeft(6, '0')),
    ];
  }

  TimelineFeedItem _mapToTimelineItem(ThreadViewPost view, {String sortKey = ''}) =>
      view.post.toTimelineFeedItem(sortKey: sortKey);
}
