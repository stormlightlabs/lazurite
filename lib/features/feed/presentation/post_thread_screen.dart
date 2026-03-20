import 'dart:async';
import 'dart:convert';

import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_post.dart';
import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/feed/cubit/post_action_cubit.dart';
import 'package:lazurite/features/feed/cubit/post_thread_cubit.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/feed/data/post_thread_repository.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_action_bar.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/features/profile/cubit/profile_action_cubit.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';
import 'package:lazurite/features/profile/presentation/widgets/report_dialog.dart';

class PostThreadScreen extends StatelessWidget {
  const PostThreadScreen({super.key, required this.postUri});

  final String postUri;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PostThreadCubit(postThreadRepository: PostThreadRepository(bluesky: context.read<Bluesky>()))..load(postUri),
      child: _PostThreadContent(postUri: postUri),
    );
  }
}

class _PostThreadContent extends StatelessWidget {
  const _PostThreadContent({required this.postUri});

  final String postUri;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thread')),
      body: BlocBuilder<PostThreadCubit, PostThreadState>(
        builder: (context, state) {
          return switch (state.status) {
            PostThreadStatus.loading => const Center(child: CircularProgressIndicator()),
            PostThreadStatus.error => _buildError(context, state.error ?? 'Failed to load thread'),
            PostThreadStatus.loaded => _buildThread(context, state.thread!),
          };
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => context.read<PostThreadCubit>().load(postUri), child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildThread(BuildContext context, ThreadViewPost thread) {
    final accountDid = context.read<String>();
    final parents = _getParentChain(thread);
    final replies = (thread.replies ?? []).where((r) => r.isThreadViewPost).map((r) => r.threadViewPost!).toList();

    return ListView(
      children: [
        for (int i = 0; i < parents.length; i++) ...[
          PostCardWithActions(
            feedViewPost: FeedViewPost(post: parents[i].post),
            accountDid: accountDid,
          ),
          _buildThreadConnector(context),
        ],
        _FocusedPostWithActions(thread: thread, accountDid: accountDid),
        if (replies.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Replies',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1),
          for (final reply in replies)
            PostCardWithActions(
              feedViewPost: FeedViewPost(post: reply.post),
              accountDid: accountDid,
            ),
        ],
      ],
    );
  }

  Widget _buildThreadConnector(BuildContext context) {
    return SizedBox(
      height: 16,
      child: Row(
        children: [
          const SizedBox(width: 37),
          Container(width: 2, color: Theme.of(context).dividerColor),
        ],
      ),
    );
  }

  List<ThreadViewPost> _getParentChain(ThreadViewPost thread) {
    final parents = <ThreadViewPost>[];
    var current = thread.parent;
    while (current != null && current.isThreadViewPost) {
      final parentThread = current.threadViewPost!;
      parents.add(parentThread);
      current = parentThread.parent;
    }
    return parents.reversed.toList();
  }
}

class _FocusedPostWithActions extends StatelessWidget {
  const _FocusedPostWithActions({required this.thread, required this.accountDid});

  final ThreadViewPost thread;
  final String accountDid;

  @override
  Widget build(BuildContext context) {
    final post = thread.post;
    final viewer = post.viewer;

    return BlocProvider(
      create: (_) => PostActionCubit(
        postActionRepository: context.read<PostActionRepository>(),
        postUri: post.uri.toString(),
        postCid: post.cid,
        isLiked: viewer?.like != null,
        isReposted: viewer?.repost != null,
        likeCount: post.likeCount ?? 0,
        repostCount: post.repostCount ?? 0,
        likeUri: viewer?.like?.toString(),
        repostUri: viewer?.repost?.toString(),
      ),
      child: BlocListener<PostActionCubit, PostActionState>(
        listenWhen: (previous, current) => previous.error != current.error && current.error != null,
        listener: (context, state) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!), behavior: SnackBarBehavior.floating));
          context.read<PostActionCubit>().clearError();
        },
        child: _FocusedPostContent(thread: thread, accountDid: accountDid),
      ),
    );
  }
}

class _FocusedPostContent extends StatelessWidget {
  const _FocusedPostContent({required this.thread, required this.accountDid});

  final ThreadViewPost thread;
  final String accountDid;

  @override
  Widget build(BuildContext context) {
    final post = thread.post;
    final record = _tryParseRecord(post.record);
    final timestamp = record?.createdAt ?? post.indexedAt;

    return PostCard(
      feedViewPost: FeedViewPost(post: post),
      actionBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(timestamp),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const Divider(),
            _buildStats(context, post),
            const Divider(height: 1),
            const SizedBox(height: 4),
            _buildActionBar(context, post),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, PostView post) {
    final items = <Widget>[];

    if ((post.replyCount ?? 0) > 0) {
      items.addAll([_buildStat(context, post.replyCount!, 'replies'), const SizedBox(width: 20)]);
    }
    if ((post.repostCount ?? 0) > 0) {
      items.addAll([_buildStat(context, post.repostCount!, 'reposts'), const SizedBox(width: 20)]);
    }
    if ((post.likeCount ?? 0) > 0) {
      items.add(_buildStat(context, post.likeCount!, 'likes'));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: items),
    );
  }

  Widget _buildStat(BuildContext context, int count, String label) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$count',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: ' $label',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, PostView post) {
    return BlocBuilder<PostActionCubit, PostActionState>(
      builder: (context, postActionState) {
        return BlocBuilder<SavedPostsCubit, SavedPostsState>(
          builder: (context, savedState) {
            return PostActionBar(
              replyCount: post.replyCount ?? 0,
              repostCount: postActionState.repostCount,
              likeCount: postActionState.likeCount,
              saveCount: post.bookmarkCount ?? 0,
              isLiked: postActionState.isLiked,
              isReposted: postActionState.isReposted,
              isSaved: savedState.isSaved(post.uri.toString()),
              postUri: post.uri.toString(),
              postCid: post.cid,
              isLoadingLike: postActionState.isLoadingLike,
              isLoadingRepost: postActionState.isLoadingRepost,
              onReply: () => _onReply(context),
              onRepost: () => context.read<PostActionCubit>().toggleRepost(),
              onQuote: () => _onQuote(context),
              onLike: () => context.read<PostActionCubit>().toggleLike(),
              onSave: () {
                unawaited(_onToggleSave(context));
              },
              onLongPressSave: () {
                unawaited(_onToggleSave(context));
              },
              onMore: () => _showMoreOptions(context),
            );
          },
        );
      },
    );
  }

  void _onReply(BuildContext context) {
    HapticFeedback.selectionClick();
    final post = thread.post;
    final root = _findRoot();

    context.push(
      '/compose',
      extra: {
        'replyParentUri': post.uri.toString(),
        'replyParentCid': post.cid,
        'replyRootUri': root.$1,
        'replyRootCid': root.$2,
        'replyAuthorHandle': post.author.handle,
      },
    );
  }

  void _onQuote(BuildContext context) {
    HapticFeedback.selectionClick();
    final post = thread.post;

    context.push(
      '/compose',
      extra: {'quoteUri': post.uri.toString(), 'quoteCid': post.cid, 'quoteAuthorHandle': post.author.handle},
    );
  }

  Future<void> _onToggleSave(BuildContext context) async {
    final cubit = context.read<SavedPostsCubit>();
    final post = thread.post;

    await HapticFeedback.lightImpact();
    await cubit.toggleSave(postUri: post.uri.toString(), postJson: jsonEncode(post.toJson()));
  }

  void _showMoreOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
    final post = thread.post;
    final postUri = post.uri.toString();
    final bskyUrl = _convertAtUriToBskyUrl(postUri);

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Link'),
              onTap: () {
                Navigator.pop(sheetContext);
                _copyToClipboard(context, bskyUrl);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text('View @${post.author.handle}'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.push('/profile/view?actor=${Uri.encodeQueryComponent(post.author.did)}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined, color: Colors.orange),
              title: const Text('Report Post', style: TextStyle(color: Colors.orange)),
              onTap: () {
                Navigator.pop(sheetContext);
                _showReportDialog(context);
              },
            ),
            if (post.author.did == accountDid)
              ListTile(
                leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                title: Text('Delete Post', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmDelete(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final post = thread.post;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (_) => ProfileActionCubit(
          profileActionRepository: context.read<ProfileActionRepository>(),
          actorDid: post.author.did,
        ),
        child: ReportDialog.post(postUri: post.uri, cid: post.cid, authorHandle: post.author.handle),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Post?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<PostActionCubit>().deletePost();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Link copied to clipboard'), behavior: SnackBarBehavior.floating));
  }

  (String, String) _findRoot() {
    var current = thread.parent;
    ThreadViewPost? root;
    while (current != null && current.isThreadViewPost) {
      root = current.threadViewPost!;
      current = root.parent;
    }
    if (root != null) {
      return (root.post.uri.toString(), root.post.cid);
    }
    return (thread.post.uri.toString(), thread.post.cid);
  }

  FeedPostRecord? _tryParseRecord(Map<String, dynamic> record) {
    try {
      return FeedPostRecord.fromJson(record);
    } catch (_) {
      return null;
    }
  }

  String _formatTimestamp(DateTime time) {
    return DateFormat('h:mm a · MMM d, yyyy').format(time.toLocal());
  }

  String _convertAtUriToBskyUrl(String atUri) {
    try {
      final uri = Uri.parse(atUri);
      final parts = uri.pathSegments;
      if (parts.length >= 2) {
        final did = uri.host;
        final rkey = parts.last;
        return 'https://bsky.app/profile/$did/post/$rkey';
      }
    } catch (_) {
      log.d('failed to convert atUri to bskyUrl');
    }
    return atUri;
  }
}
