import 'dart:async';

import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/post.dart';
import 'package:poptart_bluesky_moderation/poptart_bluesky_moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/compose/presentation/compose_route_args.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/cubit/post_action_cubit.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/feed/presentation/widgets/compact_post_card.dart';
import 'package:lazurite/features/feed/presentation/widgets/grid_post_card.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_footer.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_menu_actions.dart';
import 'package:lazurite/features/profile/cubit/profile_action_cubit.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';
import 'package:lazurite/features/profile/presentation/widgets/report_dialog.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/shared/presentation/helpers/haptic_helper.dart';
import 'package:lazurite/shared/presentation/helpers/snackbar_helper.dart';
import 'package:lazurite/shared/presentation/widgets/confirmation_dialog.dart';

/// Controls which card layout variant is rendered by [PostCardWithActions].
enum PostCardVariant { adaptive, card, compact, grid }

class PostCardWithActions extends StatefulWidget {
  const PostCardWithActions({
    super.key,
    required this.feedViewPost,
    required this.accountDid,
    this.variant = PostCardVariant.adaptive,
    this.onDeleted,
    this.onReplySubmitted,
    this.moderationContext = bsky_moderation.ModerationBehaviorContext.contentList,
  });

  final FeedViewPost feedViewPost;
  final String accountDid;
  final PostCardVariant variant;
  final VoidCallback? onDeleted;
  final Future<void> Function(String replyParentUri)? onReplySubmitted;
  final bsky_moderation.ModerationBehaviorContext moderationContext;

  @override
  State<PostCardWithActions> createState() => _PostCardWithActionsState();
}

class _PostCardWithActionsState extends State<PostCardWithActions> with AutomaticKeepAliveClientMixin {
  late PostActionCubit _postActionCubit;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _postActionCubit = _createCubit();
  }

  @override
  void didUpdateWidget(covariant PostCardWithActions oldWidget) {
    super.didUpdateWidget(oldWidget);

    final previousPost = oldWidget.feedViewPost.post;
    final currentPost = widget.feedViewPost.post;
    final postIdentityChanged =
        previousPost.uri.toString() != currentPost.uri.toString() || previousPost.cid != currentPost.cid;
    if (!postIdentityChanged) {
      return;
    }

    _postActionCubit.close();
    _postActionCubit = _createCubit();
  }

  @override
  void dispose() {
    _postActionCubit.close();
    super.dispose();
  }

  PostActionCubit _createCubit() {
    final post = widget.feedViewPost.post;
    final viewer = post.viewer;

    return PostActionCubit(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<PostActionCubit>.value(
      value: _postActionCubit,
      child: _PostCardWithActionsContent(
        feedViewPost: widget.feedViewPost,
        accountDid: widget.accountDid,
        variant: widget.variant,
        onDeleted: widget.onDeleted,
        onReplySubmitted: widget.onReplySubmitted,
        moderationContext: widget.moderationContext,
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
    this.onReplySubmitted,
    required this.moderationContext,
  });

  final FeedViewPost feedViewPost;
  final String accountDid;
  final PostCardVariant variant;
  final VoidCallback? onDeleted;
  final Future<void> Function(String replyParentUri)? onReplySubmitted;
  final bsky_moderation.ModerationBehaviorContext moderationContext;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostActionCubit, PostActionState>(
      listenWhen: (previous, current) =>
          (previous.error != current.error && current.error != null) || (!previous.isDeleted && current.isDeleted),
      listener: (context, state) {
        if (state.isDeleted) {
          showAppSnackBar(context, context.l10n.messagePostDeleted, behavior: SnackBarBehavior.floating);
          onDeleted?.call();
          return;
        }
        if (state.error != null) {
          final cubit = context.read<PostActionCubit>();
          final error = state.error!;
          showAppSnackBar(
            context,
            error,
            behavior: SnackBarBehavior.floating,
            actionLabel: context.l10n.buttonRetry,
            onAction: () {
              if (error.contains('like')) {
                cubit.toggleLike();
              } else if (error.contains('repost')) {
                cubit.toggleRepost();
              } else if (error.contains('delete')) {
                cubit.deletePost();
              }
            },
          );
          cubit.clearError();
        }
      },
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final resolvedVariant = _resolveVariant(context);
    Future<Object?> onTap() => context.push('/post?uri=${Uri.encodeQueryComponent(feedViewPost.post.uri.toString())}');
    if (resolvedVariant == PostCardVariant.grid) {
      return GridPostCard(
        feedViewPost: feedViewPost,
        footer: _buildFooter(context),
        onTap: onTap,
        moderationContext: moderationContext,
      );
    }
    if (resolvedVariant == PostCardVariant.compact) {
      return CompactPostCard(
        feedViewPost: feedViewPost,
        footer: _buildFooter(context),
        onTap: onTap,
        moderationContext: moderationContext,
      );
    }
    return PostCard(
      feedViewPost: feedViewPost,
      actionBar: _buildFooter(context),
      onTap: onTap,
      moderationContext: moderationContext,
    );
  }

  PostCardVariant _resolveVariant(BuildContext context) {
    if (variant != PostCardVariant.adaptive) {
      return variant;
    }

    try {
      final layout = context.select<SettingsCubit, FeedLayout>((cubit) => cubit.state.feedLayout);
      return layout == FeedLayout.compact ? PostCardVariant.compact : PostCardVariant.card;
    } catch (_) {
      return PostCardVariant.card;
    }
  }

  Widget _buildFooter(BuildContext context) {
    final post = feedViewPost.post;
    final isOffline = context.select<ConnectivityCubit, bool>((cubit) => cubit.state.isOffline);
    return BlocBuilder<PostActionCubit, PostActionState>(
      builder: (context, postActionState) {
        return BlocBuilder<SavedPostsCubit, SavedPostsState>(
          builder: (context, savedState) {
            return PostCardFooter(
              timestamp: formatPostTime(post.indexedAt, nowLabel: context.l10n.labelNow),
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
              onQuote: () => _onQuote(context),
              onLike: () => context.read<PostActionCubit>().toggleLike(),
              onSave: () => unawaited(_onToggleSave(context)),
              onLongPressSave: () => unawaited(_onToggleSave(context)),
              onCloudSave: () => unawaited(_onCloudSave(context)),
              onCloudUnsave: () => unawaited(_onCloudUnsave(context)),
              onMore: () => _showMoreOptions(context),
              showCounts: true,
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

    final result = await context.push(
      '/compose',
      extra: ComposeRouteArgs(
        replyParentUri: post.uri.toString(),
        replyParentCid: post.cid,
        replyRootUri: rootUri,
        replyRootCid: rootCid,
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

  Future<void> _onToggleSave(BuildContext context) async {
    final cubit = context.read<SavedPostsCubit>();
    final post = feedViewPost.post;
    unawaited(HapticHelper.lightImpact());
    await cubit.toggleSave(post);
  }

  Future<void> _onCloudSave(BuildContext context) async {
    final cubit = context.read<SavedPostsCubit>();
    final post = feedViewPost.post;
    unawaited(HapticHelper.lightImpact());
    await cubit.cloudSave(post);
  }

  Future<void> _onCloudUnsave(BuildContext context) async {
    final cubit = context.read<SavedPostsCubit>();
    final post = feedViewPost.post;
    unawaited(HapticHelper.lightImpact());
    await cubit.cloudUnsave(post.uri.toString());
  }

  void _onQuote(BuildContext context) {
    HapticHelper.selectionClick();
    final post = feedViewPost.post;
    final quotedText = _recordText(post.record);
    context.push(
      '/compose',
      extra: ComposeRouteArgs(
        quoteUri: post.uri.toString(),
        quoteCid: post.cid,
        quoteAuthorHandle: post.author.handle,
        quoteText: quotedText,
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    final post = feedViewPost.post;
    final isOffline = context.read<ConnectivityCubit>().state.isOffline;
    final repository = context.read<PostActionRepository>();

    unawaited(
      showPostOverflowMenu(
        context: context,
        post: post,
        accountDid: accountDid,
        repository: repository,
        onQuote: () => _onQuote(context),
        onShowReport: () => _showReportDialog(context),
        onDelete: () => _confirmDelete(context),
        isOffline: isOffline,
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final post = feedViewPost.post;
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider(
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
      title: Text(context.l10n.dialogDeletePostTitle),
      content: Text(context.l10n.dialogDeletePostContent),
      confirmLabel: context.l10n.buttonDelete,
      confirmDestructive: true,
      onConfirmed: () => context.read<PostActionCubit>().deletePost(),
    );
  }

  String _recordText(Map<String, dynamic> record) {
    try {
      return FeedPostRecord.fromJson(record).text;
    } catch (_) {
      final text = record['text'];
      return text is String ? text : '';
    }
  }
}
