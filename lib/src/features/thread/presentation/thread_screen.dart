import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../infrastructure/db/app_database.dart';
import '../../../infrastructure/db/daos/timeline_dao.dart';
import '../../timeline/presentation/widgets/post_card.dart';
import '../application/thread_notifier.dart';
import '../infrastructure/thread_repository.dart';

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
          return CustomScrollView(
            slivers: [
              if (thread.parent != null)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final parents = _getParents(thread.parent!);
                    final parent = parents[index];
                    return PostCard(item: _mapToTimelineItem(parent));
                  }, childCount: _getParents(thread.parent!).length),
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

              (thread.replies.isNotEmpty && _flattenedView)
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final allReplies = _getAllReplies(thread);
                        return PostCard(item: _mapToTimelineItem(allReplies[index]));
                      }, childCount: _getAllReplies(thread).length),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return PostCard(item: _mapToTimelineItem(thread.replies[index]));
                      }, childCount: thread.replies.length),
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

  TimelineFeedItem _mapToTimelineItem(ThreadViewPost view) {
    // TODO: refactor to use domain models
    final postMap = view.post;
    final authorMap = postMap['author'] as Map<String, dynamic>;

    return TimelineFeedItem(
      post: Post(
        uri: postMap['uri'],
        cid: postMap['cid'],
        authorDid: authorMap['did'],
        record: jsonEncode(postMap['record']),
        indexedAt: DateTime.tryParse(postMap['indexedAt'] ?? ''),
      ),
      author: Profile(
        did: authorMap['did'],
        handle: authorMap['handle'],
        displayName: authorMap['displayName'],
        description: authorMap['description'],
        avatar: authorMap['avatar'],
        indexedAt: DateTime.now(),
      ),
      item: const TimelineItem(feedKey: 'thread', postUri: '', sortKey: ''),
    );
  }
}
