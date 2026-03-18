import 'dart:async';
import 'dart:convert';

import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/cubit/post_action_cubit.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_action_bar.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card.dart';
import 'package:lazurite/features/profile/cubit/profile_action_cubit.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';
import 'package:lazurite/features/profile/presentation/widgets/report_dialog.dart';

class PostCardWithActions extends StatelessWidget {
  const PostCardWithActions({super.key, required this.feedViewPost, required this.accountDid, this.onDeleted});

  final FeedViewPost feedViewPost;
  final String accountDid;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final post = feedViewPost.post;
    final viewer = post.viewer;

    return BlocProvider(
      create: (ctx) => PostActionCubit(
        postActionRepository: ctx.read<PostActionRepository>(),
        postUri: post.uri.toString(),
        postCid: post.cid,
        isLiked: viewer?.like != null,
        isReposted: viewer?.repost != null,
        likeCount: post.likeCount ?? 0,
        repostCount: post.repostCount ?? 0,
        likeUri: viewer?.like?.toString(),
        repostUri: viewer?.repost?.toString(),
        cache: ctx.read<PostActionCache>(),
      ),
      child: _PostCardWithActionsContent(feedViewPost: feedViewPost, accountDid: accountDid, onDeleted: onDeleted),
    );
  }
}

class _PostCardWithActionsContent extends StatelessWidget {
  const _PostCardWithActionsContent({required this.feedViewPost, required this.accountDid, this.onDeleted});

  final FeedViewPost feedViewPost;
  final String accountDid;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostActionCubit, PostActionState>(
      listenWhen: (previous, current) =>
          (previous.error != current.error && current.error != null) || (!previous.isDeleted && current.isDeleted),
      listener: (context, state) {
        if (state.isDeleted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Post deleted'), behavior: SnackBarBehavior.floating));
          onDeleted?.call();
          return;
        }
        if (state.error != null) {
          final cubit = context.read<PostActionCubit>();
          final error = state.error!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  if (error.contains('like')) {
                    cubit.toggleLike();
                  } else if (error.contains('repost')) {
                    cubit.toggleRepost();
                  } else if (error.contains('delete')) {
                    cubit.deletePost();
                  }
                },
              ),
            ),
          );
          cubit.clearError();
        }
      },
      child: PostCard(
        feedViewPost: feedViewPost,
        actionBar: _buildActionBar(context),
        onTap: () => context.push('/post?uri=${Uri.encodeQueryComponent(feedViewPost.post.uri.toString())}'),
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    final post = feedViewPost.post;

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
              saveType: savedState.saveTypeForUri(post.uri.toString()),
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
              onCloudSave: () {
                unawaited(_onCloudSave(context));
              },
              onCloudUnsave: () {
                unawaited(_onCloudUnsave(context));
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
    final post = feedViewPost.post;
    final reply = feedViewPost.reply;

    String rootUri;
    String rootCid;

    if (reply != null && reply.root.isPostView) {
      rootUri = reply.root.postView!.uri.toString();
      rootCid = reply.root.postView!.cid;
    } else {
      rootUri = post.uri.toString();
      rootCid = post.cid;
    }

    context.push(
      '/compose',
      extra: {
        'replyParentUri': post.uri.toString(),
        'replyParentCid': post.cid,
        'replyRootUri': rootUri,
        'replyRootCid': rootCid,
        'replyAuthorHandle': post.author.handle,
      },
    );
  }

  void _onQuote(BuildContext context) {
    HapticFeedback.selectionClick();
    final post = feedViewPost.post;

    context.push(
      '/compose',
      extra: {'quoteUri': post.uri.toString(), 'quoteCid': post.cid, 'quoteAuthorHandle': post.author.handle},
    );
  }

  Future<void> _onToggleSave(BuildContext context) async {
    final cubit = context.read<SavedPostsCubit>();
    final post = feedViewPost.post;

    await HapticFeedback.lightImpact();
    await cubit.toggleSave(postUri: post.uri.toString(), postJson: jsonEncode(post.toJson()));
  }

  Future<void> _onCloudSave(BuildContext context) async {
    final cubit = context.read<SavedPostsCubit>();
    final post = feedViewPost.post;

    await HapticFeedback.lightImpact();
    await cubit.cloudSave(postUri: post.uri.toString(), cid: post.cid, postJson: jsonEncode(post.toJson()));
  }

  Future<void> _onCloudUnsave(BuildContext context) async {
    final cubit = context.read<SavedPostsCubit>();
    final post = feedViewPost.post;

    await HapticFeedback.lightImpact();
    await cubit.cloudUnsave(post.uri.toString());
  }

  void _showMoreOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
    final post = feedViewPost.post;
    final postUri = post.uri.toString();
    final bskyUrl = _convertAtUriToBskyUrl(postUri);

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Link'),
              onTap: () {
                Navigator.pop(context);
                _copyToClipboard(context, bskyUrl);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text('View @${post.author.handle}'),
              onTap: () {
                Navigator.pop(context);
                context.push('/profile/view?actor=${Uri.encodeQueryComponent(post.author.did)}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined, color: Colors.orange),
              title: const Text('Report Post', style: TextStyle(color: Colors.orange)),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(context);
              },
            ),
            if (post.author.did == accountDid)
              ListTile(
                leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                title: Text('Delete Post', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final post = feedViewPost.post;

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
      builder: (context) => AlertDialog(
        title: const Text('Delete Post?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
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
