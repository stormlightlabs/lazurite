import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/feed/presentation/widgets/facet_text.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_embed_view.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_repost_context.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_text_styles.dart';
import 'package:poptart_bluesky_moderation/poptart_bluesky_moderation.dart' as bsky_moderation;
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_blur_overlay.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderation_badge_row.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';
import 'package:lazurite/shared/utils/format_utils.dart';
import 'package:lazurite/shared/utils/parse_utils.dart';

/// Compact post card style used by profile-scoped search and compact feed layout.
class CompactPostCard extends StatelessWidget {
  const CompactPostCard({
    super.key,
    required this.feedViewPost,
    this.footer,
    this.onTap,
    this.moderationContext = bsky_moderation.ModerationBehaviorContext.contentList,
  });

  final FeedViewPost feedViewPost;
  final Widget? footer;
  final VoidCallback? onTap;
  final bsky_moderation.ModerationBehaviorContext moderationContext;

  @override
  Widget build(BuildContext context) {
    final post = feedViewPost.post;
    final record = tryParseRecord(post.record);
    final createdAt = record?.createdAt ?? post.indexedAt;
    final moderationService = maybeModerationService(context);
    final postUi = moderationService?.postUi(post, moderationContext) ?? const bsky_moderation.ModerationUI();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      child: ModeratedBlurOverlay(
        ui: postUi,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (feedViewPost.reason?.isReasonRepost == true) ...[
                      PostRepostContext(reason: feedViewPost.reason),
                      const SizedBox(height: 6),
                    ],
                    _buildHeader(context, post.author, createdAt),
                    if (postUi.alert || postUi.inform) ...[const SizedBox(height: 8), ModerationBadgeRow(ui: postUi)],
                    if (record != null && record.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      FacetText(
                        text: record.text,
                        facets: record.facets,
                        style: feedPostBodyTextStyle(context, compact: true),
                      ),
                    ],
                    if (post.embed != null) ...[
                      const SizedBox(height: 8),
                      PostEmbedView(feedViewPost: feedViewPost, embed: post.embed!, compact: true),
                    ],
                  ],
                ),
              ),
            ),
            ...[?footer],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileViewBasic author, DateTime createdAt) {
    final moderationService = maybeModerationService(context);
    final avatarUi =
        moderationService?.profileBasicUi(author, bsky_moderation.ModerationBehaviorContext.avatar) ??
        const bsky_moderation.ModerationUI();

    return InkWell(
      onTap: () => navigateToProfile(context, author.did),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileAvatar(
            size: 36,
            moderationUi: avatarUi,
            imageUrl: author.avatar,
            fallbackText: author.displayName ?? author.handle,
            shape: BoxShape.circle,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author.displayName ?? author.handle,
                  style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '@${author.handle} · ${formatRelativeTime(createdAt, nowLabel: context.l10n.commonNow)}',
                  style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
