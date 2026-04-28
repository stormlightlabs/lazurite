import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_embed_recordwithmedia.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_post.dart';
import 'package:bluesky/moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/color_filters.dart';
import 'package:lazurite/core/theme/spacing.dart';
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

const double _gridEmbedPreviewMaxHeight = 240;

/// Grid layout post card.
///
/// Image embeds are shown in a square greyscale region at the top.
/// All other embed types (external links, videos, quoted records) are rendered
/// via [PostEmbedView] in the content area below the body text.
///
/// Text-only posts (no images) use expanded [titleMedium] body text.
class GridPostCard extends StatelessWidget {
  const GridPostCard({
    super.key,
    required this.feedViewPost,
    this.footer,
    this.onTap,
    this.moderationContext = bsky_moderation.ModerationBehaviorContext.contentList,
  });

  final FeedViewPost feedViewPost;

  /// Optional footer widget. Defaults to a read-only [PostCardFooter] when null.
  final Widget? footer;
  final VoidCallback? onTap;
  final bsky_moderation.ModerationBehaviorContext moderationContext;

  @override
  Widget build(BuildContext context) {
    final post = feedViewPost.post;
    final record = _tryParseRecord(post.record);
    final primaryImageUrl = _extractPrimaryImageUrl(post.embed);
    final bodyText = record?.text ?? '';
    final colorScheme = context.colorScheme;
    final isCompactGrid = MediaQuery.of(context).size.width >= 600;
    final moderationService = maybeModerationService(context);
    final postUi = moderationService?.postUi(post, moderationContext) ?? const bsky_moderation.ModerationUI();
    final mediaUi =
        moderationService?.postUi(post, bsky_moderation.ModerationBehaviorContext.contentMedia) ??
        const bsky_moderation.ModerationUI();

    final contentEmbed = primaryImageUrl == null && post.embed != null
        ? PostEmbedView(feedViewPost: feedViewPost, embed: post.embed!, compact: isCompactGrid)
        : null;

    final resolvedFooter = footer ?? PostCardFooter(timestamp: formatPostTime(record?.createdAt ?? post.indexedAt));

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surface.withValues(alpha: 0.91),
      ),
      child: ModeratedBlurOverlay(
        ui: postUi,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (primaryImageUrl != null)
                ModeratedBlurOverlay(
                  ui: mediaUi,
                  fillWidth: false,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: ColorFiltered(
                      colorFilter: AppColorFilters.greyscale,
                      child: Image.network(
                        primaryImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, _, _) =>
                            ColoredBox(color: colorScheme.surfaceContainerHigh, child: const SizedBox.expand()),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: AppInsets.allMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAuthorRow(context, post.author),
                    if (postUi.alert || postUi.inform) ...[const SizedBox(height: 10), ModerationBadgeRow(ui: postUi)],
                    if (bodyText.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      if (primaryImageUrl == null && contentEmbed == null)
                        FacetText(
                          text: bodyText,
                          facets: record?.facets,
                          style: feedPostBodyTextStyle(context),
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        )
                      else if (!isCompactGrid)
                        FacetText(text: bodyText, facets: record?.facets, style: feedPostBodyTextStyle(context))
                      else
                        FacetText(
                          text: bodyText,
                          facets: record?.facets,
                          style: feedPostBodyTextStyle(context, compact: true),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                    if (contentEmbed != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      _buildEmbedPreview(contentEmbed, compact: isCompactGrid),
                    ],
                  ],
                ),
              ),
              resolvedFooter,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorRow(BuildContext context, ProfileViewBasic author) {
    final colorScheme = context.colorScheme;
    final moderationService = maybeModerationService(context);
    final avatarUi =
        moderationService?.profileBasicUi(author, bsky_moderation.ModerationBehaviorContext.avatar) ??
        const bsky_moderation.ModerationUI();
    return Row(
      children: [
        GestureDetector(
          key: const ValueKey('grid_post_card_avatar'),
          onTap: () => navigateToProfile(context, author.did),
          child: ProfileAvatar(
            size: 40,
            moderationUi: avatarUi,
            imageUrl: author.avatar,
            fallbackText: author.displayName ?? author.handle,
            shape: BoxShape.rectangle,
            border: Border.all(color: colorScheme.outlineVariant),
            placeholderTextStyle: context.textTheme.labelMedium,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: ActorNameWidget(
            displayName: author.displayName,
            handle: author.handle,
            showDisplayNameOnlyWhenPresent: true,
            displayNameStyle: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            handleStyle: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmbedPreview(Widget contentEmbed, {required bool compact}) {
    if (!compact) {
      return contentEmbed;
    }

    return SizedBox(
      height: _gridEmbedPreviewMaxHeight,
      child: ClipRect(
        child: SingleChildScrollView(physics: const NeverScrollableScrollPhysics(), child: contentEmbed),
      ),
    );
  }

  /// Returns the URL for the square image region when the post has image/video embeds.
  /// Returns null for external links and quoted records (rendered via [PostEmbedView]).
  String? _extractPrimaryImageUrl(UPostViewEmbed? embed) {
    if (embed == null) return null;
    if (embed.isEmbedImagesView) {
      final images = embed.embedImagesView!.images;
      return images.isNotEmpty ? images.first.thumb : null;
    }
    if (embed.isEmbedVideoView) {
      return embed.embedVideoView!.thumbnail;
    }
    if (embed.isEmbedRecordWithMediaView) {
      final media = embed.embedRecordWithMediaView!.media;
      if (media.isEmbedImagesView) {
        final images = media.embedImagesView!.images;
        return images.isNotEmpty ? images.first.thumb : null;
      }
      if (media.isEmbedVideoView) {
        return media.embedVideoView!.thumbnail;
      }
    }
    return null;
  }

  FeedPostRecord? _tryParseRecord(Map<String, dynamic> record) {
    try {
      return FeedPostRecord.fromJson(record);
    } catch (_) {
      return null;
    }
  }
}
