import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:bsky_moderation/bsky_moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/feed/presentation/widgets/facet_text.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_footer.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_embed_view.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_text_styles.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_blur_overlay.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderation_badge_row.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';
import 'package:lazurite/shared/presentation/widgets/actor_name_widget.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';
import 'package:lazurite/shared/utils/parse_utils.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.feedViewPost,
    this.actionBar,
    this.onTap,
    this.moderationContext = bsky_moderation.ModerationBehaviorContext.contentList,
  });

  final FeedViewPost feedViewPost;

  /// Optional footer/action area. Defaults to a read-only [PostCardFooter]
  /// showing the post timestamp when null.
  ///
  /// The widget is rendered directly (no additional padding is applied by
  /// [PostCard]). [PostCardFooter] manages its own padding; custom widgets
  /// should do the same.
  final Widget? actionBar;
  final VoidCallback? onTap;
  final bsky_moderation.ModerationBehaviorContext moderationContext;

  @override
  Widget build(BuildContext context) {
    final post = feedViewPost.post;
    final record = tryParseRecord(post.record);
    final colorScheme = context.colorScheme;
    final moderationService = maybeModerationService(context);
    final postUi = moderationService?.postUi(post, moderationContext) ?? const bsky_moderation.ModerationUI();

    final resolvedFooter =
        actionBar ??
        PostCardFooter(timestamp: formatPostTime(record?.createdAt ?? post.indexedAt, nowLabel: context.l10n.labelNow));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surface.withValues(alpha: 0.9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModeratedBlurOverlay(
            ui: postUi,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, post.author),
                    if (postUi.alert || postUi.inform) ...[const SizedBox(height: 10), ModerationBadgeRow(ui: postUi)],
                    if (record?.reply != null) ...[const SizedBox(height: 8), _buildReplyContext(context)],
                    if (record != null && record.text.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      FacetText(text: record.text, facets: record.facets, style: feedPostBodyTextStyle(context)),
                    ],
                    if (post.embed != null) ...[
                      const SizedBox(height: 12),
                      PostEmbedView(feedViewPost: feedViewPost, embed: post.embed!),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
          resolvedFooter,
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileViewBasic author) {
    final colorScheme = context.colorScheme;
    final moderationService = maybeModerationService(context);
    final avatarUi =
        moderationService?.profileBasicUi(author, bsky_moderation.ModerationBehaviorContext.avatar) ??
        const bsky_moderation.ModerationUI();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          key: const ValueKey('post_card_avatar'),
          onTap: () => navigateToProfile(context, author.did),
          child: ProfileAvatar(
            size: 40,
            moderationUi: avatarUi,
            imageUrl: author.avatar,
            fallbackText: author.displayName ?? author.handle,
            shape: BoxShape.rectangle,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ActorNameWidget(
            displayName: author.displayName,
            handle: author.handle,
            displayNameStyle: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            handleStyle: context.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReplyContext(BuildContext context) {
    final parentPost = feedViewPost.reply?.parent.isPostView == true ? feedViewPost.reply!.parent.postView : null;
    if (parentPost == null) {
      return Row(
        children: [
          Icon(Icons.reply, size: 14, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              context.l10n.messageReplyInThread,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      );
    }

    final parentRecord = tryParseRecord(parentPost.record);
    final parentText = parentRecord?.text.trim() ?? '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colorScheme.outlineVariant),
        color: context.colorScheme.surfaceContainerLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.formatReplyingToHandle(parentPost.author.handle),
            style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
          if (parentText.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(parentText, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
