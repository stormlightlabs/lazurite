import 'dart:async';
import 'dart:convert';

import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/cubit/post_action_cubit.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/feed/presentation/widgets/grid_post_card.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_footer.dart';

/// Controls which card layout variant is rendered by [PostCardWithActions].
enum PostCardVariant { linear, grid }

class PostCardWithActions extends StatelessWidget {
  const PostCardWithActions({
    super.key,
    required this.feedViewPost,
    required this.accountDid,
    this.variant = PostCardVariant.linear,
    this.onDeleted,
  });

  final FeedViewPost feedViewPost;
  final String accountDid;
  final PostCardVariant variant;
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
      child: _PostCardWithActionsContent(
        feedViewPost: feedViewPost,
        accountDid: accountDid,
        variant: variant,
        onDeleted: onDeleted,
      ),
    );
  }
}

class _PostCardWithActionsContent extends StatelessWidget {
  const _PostCardWithActionsContent({
    required this.feedViewPost,
    required this.accountDid,
    required this.variant,
    this.onDeleted,
  });

  final FeedViewPost feedViewPost;
  final String accountDid;
  final PostCardVariant variant;
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
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    Future<Object?> onTap() => context.push('/post?uri=${Uri.encodeQueryComponent(feedViewPost.post.uri.toString())}');
    if (variant == PostCardVariant.grid) {
      return GridPostCard(feedViewPost: feedViewPost, footer: _buildFooter(context), onTap: onTap);
    }
    return PostCard(feedViewPost: feedViewPost, actionBar: _buildFooter(context), onTap: onTap);
  }

  Widget _buildFooter(BuildContext context) {
    final post = feedViewPost.post;
    return BlocBuilder<PostActionCubit, PostActionState>(
      builder: (context, postActionState) {
        return BlocBuilder<SavedPostsCubit, SavedPostsState>(
          builder: (context, savedState) {
            return PostCardFooter(
              timestamp: formatPostTime(post.indexedAt),
              replyCount: post.replyCount ?? 0,
              repostCount: postActionState.repostCount,
              likeCount: postActionState.likeCount,
              saveCount: post.bookmarkCount ?? 0,
              isLiked: postActionState.isLiked,
              isReposted: postActionState.isReposted,
              isSaved: savedState.isSaved(post.uri.toString()),
              saveType: savedState.saveTypeForUri(post.uri.toString()),
              isLoadingLike: postActionState.isLoadingLike,
              isLoadingRepost: postActionState.isLoadingRepost,
              onReply: () => _onReply(context),
              onRepost: () => context.read<PostActionCubit>().toggleRepost(),
              onLike: () => context.read<PostActionCubit>().toggleLike(),
              onSave: () => unawaited(_onToggleSave(context)),
              onLongPressSave: () => unawaited(_onToggleSave(context)),
              onCloudSave: () => unawaited(_onCloudSave(context)),
              onCloudUnsave: () => unawaited(_onCloudUnsave(context)),
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
}
