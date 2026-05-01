import 'dart:async';
import 'dart:convert';

import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_post.dart';
import 'package:bluesky/moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/compose/presentation/compose_route_args.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/cubit/post_action_cubit.dart';
import 'package:lazurite/features/feed/cubit/post_thread_cubit.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/feed/data/post_thread_repository.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_action_bar.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_interactions_sheet.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_menu_actions.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_avatar.dart';
import 'package:lazurite/features/profile/cubit/profile_action_cubit.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';
import 'package:lazurite/features/profile/presentation/widgets/report_dialog.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/shared/presentation/helpers/haptic_helper.dart';
import 'package:lazurite/shared/presentation/helpers/snackbar_helper.dart';
import 'package:lazurite/shared/presentation/widgets/confirmation_dialog.dart';
import 'package:lazurite/shared/presentation/widgets/options_sheet.dart';

class PostThreadScreen extends StatelessWidget {
  const PostThreadScreen({super.key, required this.postUri});

  final String postUri;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PostThreadCubit(postThreadRepository: context.read<PostThreadRepository>())..load(postUri),
      child: _PostThreadContent(postUri: postUri),
    );
  }
}

const int _maxThreadDepth = 3;
const double _threadIndentPerDepth = 20;
const double _threadLineTouchTarget = 20;
const Duration _threadCollapseDuration = Duration(milliseconds: 200);

Set<String> computeInitialCollapsedThreadUris(ThreadViewPost thread, {required int? autoCollapseDepth}) {
  if (autoCollapseDepth == null) {
    return <String>{};
  }

  final opDid = _getThreadRoot(thread).post.author.did;
  final collapsedUris = <String>{};

  void visit(ThreadViewPost node, int depth) {
    for (final reply in _threadRepliesOf(node)) {
      final childDepth = depth + 1;
      final childReplies = _threadRepliesOf(reply);
      if (childDepth > autoCollapseDepth && childReplies.isNotEmpty && reply.post.author.did != opDid) {
        collapsedUris.add(reply.post.uri.toString());
      }
      visit(reply, childDepth);
    }
  }

  visit(thread, 0);
  return collapsedUris;
}

class _PostThreadContent extends StatefulWidget {
  const _PostThreadContent({required this.postUri});

  final String postUri;

  @override
  State<_PostThreadContent> createState() => _PostThreadContentState();
}

class _PostThreadContentState extends State<_PostThreadContent> {
  Set<String> _collapsedUris = <String>{};
  String? _initializedThreadUri;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<PostThreadCubit>().state;
    if (state.status == PostThreadStatus.loaded && state.thread != null) {
      _syncInitialCollapsedUris(state.thread!);
    }
  }

  void _syncInitialCollapsedUris(ThreadViewPost thread) {
    final threadUri = thread.post.uri.toString();
    if (_initializedThreadUri == threadUri) {
      return;
    }

    final collapsedUris = computeInitialCollapsedThreadUris(
      thread,
      autoCollapseDepth: context.read<SettingsCubit>().state.threadAutoCollapseDepth,
    );

    setState(() {
      _initializedThreadUri = threadUri;
      _collapsedUris = collapsedUris;
    });
  }

  void _toggleCollapsed(String postUri) {
    setState(() {
      if (_collapsedUris.contains(postUri)) {
        _collapsedUris.remove(postUri);
      } else {
        _collapsedUris.add(postUri);
      }
    });
  }

  Future<void> _reloadThreadAfterReply(String replyParentUri) async {
    final cubit = context.read<PostThreadCubit>();
    final before = cubit.state.thread == null ? null : _snapshotForPostUri(cubit.state.thread!, replyParentUri);
    final retryDelays = <Duration>[
      Duration.zero,
      const Duration(seconds: 1),
      const Duration(seconds: 2),
      const Duration(seconds: 4),
    ];

    for (final delay in retryDelays) {
      if (delay > Duration.zero) {
        await Future<void>.delayed(delay);
      }
      if (!mounted) return;

      await cubit.load(widget.postUri);
      final loadedThread = cubit.state.thread;
      if (loadedThread == null) {
        continue;
      }

      final after = _snapshotForPostUri(loadedThread, replyParentUri);
      if (before == null || after == null) {
        return;
      }

      final replyCountIncreased = after.directReplyCount > before.directReplyCount;
      final descendantCountIncreased = after.descendantReplyCount > before.descendantReplyCount;
      if (replyCountIncreased || descendantCountIncreased) {
        return;
      }
    }

    if (mounted) {
      showAppSnackBar(
        context,
        'Reply posted. It may take a moment to appear in this thread.',
        behavior: SnackBarBehavior.floating,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostThreadCubit, PostThreadState>(
      listenWhen: (previous, current) {
        if (current.status != PostThreadStatus.loaded || current.thread == null) {
          return false;
        }
        return previous.thread?.post.uri.toString() != current.thread!.post.uri.toString();
      },
      listener: (context, state) {
        _syncInitialCollapsedUris(state.thread!);
      },
      child: Scaffold(
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
          FilledButton(
            onPressed: () => context.read<PostThreadCubit>().load(widget.postUri),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildThread(BuildContext context, ThreadViewPost thread) {
    final accountDid = context.read<String>();
    final parents = _getParentChain(thread);
    final replies = _threadRepliesOf(thread);
    final opDid = (parents.isNotEmpty ? parents.first : thread).post.author.did;

    return ListView(
      children: [
        for (int i = 0; i < parents.length; i++) ...[
          PostCardWithActions(
            feedViewPost: FeedViewPost(post: parents[i].post),
            accountDid: accountDid,
            onReplySubmitted: _reloadThreadAfterReply,
            moderationContext: bsky_moderation.ModerationBehaviorContext.contentView,
          ),
          _buildThreadConnector(context),
        ],
        _FocusedPostWithActions(thread: thread, accountDid: accountDid, onReplySubmitted: _reloadThreadAfterReply),
        if (replies.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Replies',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1),
          for (final reply in replies)
            ThreadReplyNode(
              key: ValueKey('thread-reply-node-${reply.post.uri}'),
              thread: reply,
              depth: 1,
              accountDid: accountDid,
              opDid: opDid,
              collapsedUris: _collapsedUris,
              onToggleCollapse: _toggleCollapsed,
              onReplySubmitted: _reloadThreadAfterReply,
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

class ThreadReplyNode extends StatelessWidget {
  const ThreadReplyNode({
    super.key,
    required this.thread,
    required this.depth,
    required this.accountDid,
    required this.opDid,
    required this.collapsedUris,
    required this.onToggleCollapse,
    this.onReplySubmitted,
    this.onContinueThread,
  });

  final ThreadViewPost thread;
  final int depth;
  final String accountDid;
  final String opDid;
  final Set<String> collapsedUris;
  final ValueChanged<String> onToggleCollapse;
  final Future<void> Function(String replyParentUri)? onReplySubmitted;
  final ValueChanged<ThreadViewPost>? onContinueThread;

  @override
  Widget build(BuildContext context) {
    if (depth > _maxThreadDepth) {
      return _ThreadOverflowLink(thread: thread, depth: depth, onContinueThread: onContinueThread);
    }

    final postUri = thread.post.uri.toString();
    final replies = _threadRepliesOf(thread);
    final isCollapsed = collapsedUris.contains(postUri);
    final lineColor = _threadLineColors(context)[(depth - 1) % _threadLineColors(context).length];
    final indent = (depth - 1) * _threadIndentPerDepth;
    final canCollapse = replies.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: _threadLineTouchTarget),
            child: AnimatedSize(
              duration: _threadCollapseDuration,
              curve: Curves.easeInOut,
              child: isCollapsed
                  ? _CollapsedThreadReply(
                      thread: thread,
                      hiddenReplyCount: _countDescendantReplies(thread),
                      onLongPress: canCollapse ? () => onToggleCollapse(postUri) : null,
                    )
                  : _ExpandedThreadReply(
                      thread: thread,
                      depth: depth,
                      accountDid: accountDid,
                      opDid: opDid,
                      collapsedUris: collapsedUris,
                      onToggleCollapse: onToggleCollapse,
                      onReplySubmitted: onReplySubmitted,
                      onContinueThread: onContinueThread,
                    ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: _threadLineTouchTarget,
            child: canCollapse
                ? _ThreadLineButton(
                    color: lineColor,
                    postUri: postUri,
                    isCollapsed: isCollapsed,
                    onTap: () => onToggleCollapse(postUri),
                  )
                : IgnorePointer(child: _ThreadLine(color: lineColor)),
          ),
        ],
      ),
    );
  }
}

class _ExpandedThreadReply extends StatelessWidget {
  const _ExpandedThreadReply({
    required this.thread,
    required this.depth,
    required this.accountDid,
    required this.opDid,
    required this.collapsedUris,
    required this.onToggleCollapse,
    this.onReplySubmitted,
    this.onContinueThread,
  });

  final ThreadViewPost thread;
  final int depth;
  final String accountDid;
  final String opDid;
  final Set<String> collapsedUris;
  final ValueChanged<String> onToggleCollapse;
  final Future<void> Function(String replyParentUri)? onReplySubmitted;
  final ValueChanged<ThreadViewPost>? onContinueThread;

  @override
  Widget build(BuildContext context) {
    final postUri = thread.post.uri.toString();
    final replies = _threadRepliesOf(thread);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: replies.isNotEmpty ? () => onToggleCollapse(postUri) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          PostCardWithActions(
            feedViewPost: FeedViewPost(post: thread.post),
            accountDid: accountDid,
            onReplySubmitted: onReplySubmitted,
            moderationContext: bsky_moderation.ModerationBehaviorContext.contentView,
          ),
          for (final reply in replies)
            ThreadReplyNode(
              key: ValueKey('thread-reply-node-${reply.post.uri}'),
              thread: reply,
              depth: depth + 1,
              accountDid: accountDid,
              opDid: opDid,
              collapsedUris: collapsedUris,
              onToggleCollapse: onToggleCollapse,
              onReplySubmitted: onReplySubmitted,
              onContinueThread: onContinueThread,
            ),
        ],
      ),
    );
  }
}

class _CollapsedThreadReply extends StatelessWidget {
  const _CollapsedThreadReply({required this.thread, required this.hiddenReplyCount, this.onLongPress});

  final ThreadViewPost thread;
  final int hiddenReplyCount;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final post = thread.post;
    final colorScheme = context.colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          color: colorScheme.surfaceContainerLowest,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CollapsedThreadHeader(post: post),
              const SizedBox(height: 10),
              Text(
                _hiddenReplyLabel(hiddenReplyCount).toUpperCase(),
                key: ValueKey('collapsed-indicator-${post.uri}'),
                style: context.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, letterSpacing: 1.1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollapsedThreadHeader extends StatelessWidget {
  const _CollapsedThreadHeader({required this.post});

  final PostView post;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final timestamp = _parsePostRecord(post.record)?.createdAt ?? post.indexedAt;
    final moderationService = maybeModerationService(context);
    final avatarUi =
        moderationService?.profileBasicUi(post.author, bsky_moderation.ModerationBehaviorContext.avatar) ??
        const bsky_moderation.ModerationUI();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModeratedAvatar(
          size: 40,
          ui: avatarUi,
          imageUrl: post.author.avatar,
          initials: _initials(post.author.displayName ?? post.author.handle),
          shape: BoxShape.rectangle,
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      post.author.displayName ?? post.author.handle,
                      style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM d').format(timestamp.toLocal()).toUpperCase(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '@${post.author.handle}'.toUpperCase(),
                style: context.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThreadOverflowLink extends StatelessWidget {
  const _ThreadOverflowLink({required this.thread, required this.depth, this.onContinueThread});

  final ThreadViewPost thread;
  final int depth;
  final ValueChanged<ThreadViewPost>? onContinueThread;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: _maxThreadDepth * _threadIndentPerDepth),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          key: ValueKey('continue-thread-${thread.post.uri}'),
          onPressed: () {
            if (onContinueThread != null) {
              onContinueThread!(thread);
              return;
            }
            context.push('/post?uri=${Uri.encodeQueryComponent(thread.post.uri.toString())}');
          },
          child: const Text('Continue this thread →'),
        ),
      ),
    );
  }
}

class _ThreadLineButton extends StatelessWidget {
  const _ThreadLineButton({required this.color, required this.postUri, required this.isCollapsed, required this.onTap});

  final Color color;
  final String postUri;
  final bool isCollapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('threadline-$postUri'),
        onTap: onTap,
        splashColor: color.withValues(alpha: 0.16),
        highlightColor: color.withValues(alpha: 0.08),
        child: _ThreadLine(color: color, isCollapsed: isCollapsed),
      ),
    );
  }
}

class _ThreadLine extends StatelessWidget {
  const _ThreadLine({required this.color, this.isCollapsed = false});

  final Color color;
  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: _threadCollapseDuration,
        width: 2,
        margin: EdgeInsets.symmetric(vertical: isCollapsed ? 12 : 0),
        color: color,
      ),
    );
  }
}

List<ThreadViewPost> _threadRepliesOf(ThreadViewPost thread) {
  return (thread.replies ?? <UThreadViewPostReplies>[])
      .where((reply) => reply.isThreadViewPost)
      .map((reply) => reply.threadViewPost!)
      .toList();
}

ThreadViewPost _getThreadRoot(ThreadViewPost thread) {
  var current = thread;
  while (current.parent != null && current.parent!.isThreadViewPost) {
    current = current.parent!.threadViewPost!;
  }
  return current;
}

int _countDescendantReplies(ThreadViewPost thread) {
  var count = 0;
  for (final reply in _threadRepliesOf(thread)) {
    count += 1 + _countDescendantReplies(reply);
  }
  return count;
}

_ReplyThreadSnapshot? _snapshotForPostUri(ThreadViewPost thread, String postUri) {
  if (thread.post.uri.toString() == postUri) {
    return _ReplyThreadSnapshot(
      directReplyCount: thread.post.replyCount ?? 0,
      descendantReplyCount: _countDescendantReplies(thread),
    );
  }

  for (final reply in _threadRepliesOf(thread)) {
    final nested = _snapshotForPostUri(reply, postUri);
    if (nested != null) {
      return nested;
    }
  }

  return null;
}

class _ReplyThreadSnapshot {
  const _ReplyThreadSnapshot({required this.directReplyCount, required this.descendantReplyCount});

  final int directReplyCount;
  final int descendantReplyCount;
}

String _hiddenReplyLabel(int count) => count == 1 ? '1 reply hidden' : '$count replies hidden';

List<Color> _threadLineColors(BuildContext context) {
  final colorScheme = context.colorScheme;
  final surface = colorScheme.surface;

  Color blend(Color color, double amount) => Color.lerp(color, surface, amount)!;

  return [
    blend(colorScheme.outlineVariant, 0.08),
    blend(colorScheme.outline, 0.18),
    blend(colorScheme.primary, 0.78),
    blend(colorScheme.secondary, 0.74),
    blend(colorScheme.tertiary, 0.72),
    blend(colorScheme.primaryContainer, 0.62),
  ];
}

FeedPostRecord? _parsePostRecord(Map<String, dynamic> record) {
  try {
    return FeedPostRecord.fromJson(record);
  } catch (_) {
    return null;
  }
}

String _initials(String value) {
  final parts = value.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) {
    return '?';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
}

class _FocusedPostWithActions extends StatelessWidget {
  const _FocusedPostWithActions({required this.thread, required this.accountDid, this.onReplySubmitted});

  final ThreadViewPost thread;
  final String accountDid;
  final Future<void> Function(String replyParentUri)? onReplySubmitted;

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
        cache: context.read<PostActionCache>(),
      ),
      child: BlocListener<PostActionCubit, PostActionState>(
        listenWhen: (previous, current) => previous.error != current.error && current.error != null,
        listener: (context, state) {
          showAppSnackBar(context, state.error!, behavior: SnackBarBehavior.floating);
          context.read<PostActionCubit>().clearError();
        },
        child: _FocusedPostContent(thread: thread, accountDid: accountDid, onReplySubmitted: onReplySubmitted),
      ),
    );
  }
}

class _FocusedPostContent extends StatelessWidget {
  const _FocusedPostContent({required this.thread, required this.accountDid, this.onReplySubmitted});

  final ThreadViewPost thread;
  final String accountDid;
  final Future<void> Function(String replyParentUri)? onReplySubmitted;

  @override
  Widget build(BuildContext context) {
    final post = thread.post;
    final record = _parsePostRecord(post.record);
    final timestamp = record?.createdAt ?? post.indexedAt;

    final hasStats = (post.replyCount ?? 0) > 0 || (post.repostCount ?? 0) > 0 || (post.likeCount ?? 0) > 0;

    return PostCard(
      feedViewPost: FeedViewPost(post: post),
      moderationContext: bsky_moderation.ModerationBehaviorContext.contentView,
      actionBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              _formatTimestamp(timestamp),
              style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            if (hasStats) ...[
              const SizedBox(height: 10),
              _buildStats(context, post),
              const SizedBox(height: 10),
              const Divider(height: 1),
            ],
            const SizedBox(height: 6),
            _buildActionBar(context, post),
            const SizedBox(height: 6),
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
      items.addAll([
        _buildStat(
          context,
          post.repostCount!,
          'reposts',
          onTap: () => _showInteractions(context, post, showLikes: false),
        ),
        const SizedBox(width: 20),
      ]);
    }
    if ((post.likeCount ?? 0) > 0) {
      items.add(
        _buildStat(context, post.likeCount!, 'likes', onTap: () => _showInteractions(context, post, showLikes: true)),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Row(children: items);
  }

  void _showInteractions(BuildContext context, PostView post, {required bool showLikes}) {
    final repository = context.read<PostActionRepository>();
    showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PostInteractionsSheet(
        postUri: post.uri,
        likeCount: post.likeCount ?? 0,
        repostCount: post.repostCount ?? 0,
        initialTab: showLikes ? InteractionTab.likes : InteractionTab.reposts,
        repository: repository,
      ),
    );
  }

  Widget _buildStat(BuildContext context, int count, String label, {VoidCallback? onTap}) {
    final text = RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$count',
            style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: ' $label',
            style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );

    if (onTap == null) return text;

    return GestureDetector(onTap: onTap, child: text);
  }

  Widget _buildActionBar(BuildContext context, PostView post) {
    final isOffline = context.select<ConnectivityCubit, bool>((cubit) => cubit.state.isOffline);
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
              isOffline: isOffline,
            );
          },
        );
      },
    );
  }

  void _onReply(BuildContext context) {
    unawaited(_handleReply(context));
  }

  Future<void> _handleReply(BuildContext context) async {
    HapticHelper.selectionClick();
    final post = thread.post;
    final root = _findRoot();

    final result = await context.push(
      '/compose',
      extra: ComposeRouteArgs(
        replyParentUri: post.uri.toString(),
        replyParentCid: post.cid,
        replyRootUri: root.$1,
        replyRootCid: root.$2,
        replyAuthorHandle: post.author.handle,
      ),
    );

    if (!context.mounted) return;
    if (!_didCreateImmediateReply(result)) return;

    await onReplySubmitted?.call(post.uri.toString());
  }

  bool _didCreateImmediateReply(Object? result) {
    if (result is! Map) return false;
    return result['status'] == 'posted' && result['isReply'] == true;
  }

  void _onQuote(BuildContext context) {
    HapticHelper.selectionClick();
    final post = thread.post;

    context.push(
      '/compose',
      extra: ComposeRouteArgs(quoteUri: post.uri.toString(), quoteCid: post.cid, quoteAuthorHandle: post.author.handle),
    );
  }

  Future<void> _onToggleSave(BuildContext context) async {
    final cubit = context.read<SavedPostsCubit>();
    final post = thread.post;

    await HapticHelper.lightImpact();
    await cubit.toggleSave(postUri: post.uri.toString(), postJson: jsonEncode(post.toJson()));
  }

  void _showMoreOptions(BuildContext context) {
    final post = thread.post;
    final repository = context.read<PostActionRepository>();
    final isOffline = context.read<ConnectivityCubit>().state.isOffline;

    unawaited(
      showPostOverflowMenu(
        context: context,
        post: post,
        accountDid: accountDid,
        repository: repository,
        onQuote: () => _onQuote(context),
        onShowReport: () => _showReportDialog(context),
        onEdit: () => _onEdit(context),
        onDelete: () => _confirmDelete(context),
        isOffline: isOffline,
      ),
    );
  }

  /// Editing is currently exposed through the thread-screen overflow menu for owner posts.
  Future<void> _onEdit(BuildContext context) async {
    final post = thread.post;
    final record = Map<String, dynamic>.from(post.record);

    final result = await context.push(
      '/compose',
      extra: ComposeRouteArgs(
        initialText: _editableTextFromRecord(record),
        editPostUri: post.uri.toString(),
        editPostCid: post.cid,
        editRecord: record,
      ),
    );

    if (!context.mounted) return;

    final didSave = result == true || result is Map;
    if (!didSave) return;

    String? expectedText;
    if (result is Map) {
      final editedText = result['editedText'];
      if (editedText is String) {
        expectedText = editedText;
      }
    }

    await _reloadThreadAfterEdit(context, postUri: post.uri.toString(), expectedText: expectedText);
  }

  Future<void> _reloadThreadAfterEdit(BuildContext context, {required String postUri, String? expectedText}) async {
    final cubit = context.read<PostThreadCubit>();
    final retryDelays = <Duration>[
      Duration.zero,
      const Duration(seconds: 1),
      const Duration(seconds: 2),
      const Duration(seconds: 4),
    ];

    for (var i = 0; i < retryDelays.length; i++) {
      final delay = retryDelays[i];
      if (delay > Duration.zero) {
        await Future<void>.delayed(delay);
      }
      if (!context.mounted) return;

      await cubit.load(postUri);

      if (expectedText == null) {
        return;
      }

      final loadedThread = cubit.state.thread;
      if (loadedThread == null) {
        continue;
      }

      final loadedText = _editableTextFromRecord(loadedThread.post.record);
      if (loadedText == expectedText) {
        return;
      }
    }

    if (context.mounted && expectedText != null) {
      showAppSnackBar(
        context,
        'Edit saved. Your updates may take a moment to appear across feeds.',
        behavior: SnackBarBehavior.floating,
      );
    }
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

  Future<void> _confirmDelete(BuildContext context) async {
    await showConfirmationDialog(
      context: context,
      title: const Text('Delete Post?'),
      content: const Text('This action cannot be undone.'),
      confirmLabel: 'Delete',
      confirmDestructive: true,
      onConfirmed: () => context.read<PostActionCubit>().deletePost(),
    );
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

  String _formatTimestamp(DateTime time) {
    return DateFormat('h:mm a · MMM d, yyyy').format(time.toLocal());
  }

  String _editableTextFromRecord(Map<String, dynamic> record) {
    final parsed = _parsePostRecord(record);
    if (parsed != null) {
      return parsed.text;
    }
    final text = record['text'];
    return text is String ? text : '';
  }
}
