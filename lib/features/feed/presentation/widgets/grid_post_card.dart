import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_embed_recordwithmedia.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_post.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/feed/presentation/widgets/facet_text.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_footer.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_embed_view.dart';

const _greyscale = ColorFilter.matrix(<double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);

/// Grid layout post card.
///
/// Image embeds are shown in a square greyscale region at the top.
/// All other embed types (external links, videos, quoted records) are rendered
/// via [PostEmbedView] in the content area below the body text.
///
/// Text-only posts (no images) use expanded [titleMedium] body text.
class GridPostCard extends StatelessWidget {
  const GridPostCard({super.key, required this.feedViewPost, this.footer, this.onTap});

  final FeedViewPost feedViewPost;

  /// Optional footer widget. Defaults to a read-only [PostCardFooter] when null.
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final post = feedViewPost.post;
    final record = _tryParseRecord(post.record);
    final primaryImageUrl = _extractPrimaryImageUrl(post.embed);
    final bodyText = record?.text ?? '';
    final colorScheme = Theme.of(context).colorScheme;

    // Non-image embeds rendered in the content area
    final contentEmbed = primaryImageUrl == null && post.embed != null
        ? PostEmbedView(feedViewPost: feedViewPost, embed: post.embed!)
        : null;

    final resolvedFooter = footer ?? PostCardFooter(timestamp: formatPostTime(record?.createdAt ?? post.indexedAt));

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surfaceContainerLowest,
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (primaryImageUrl != null)
              AspectRatio(
                aspectRatio: 1.0,
                child: ColorFiltered(
                  colorFilter: _greyscale,
                  child: Image.network(
                    primaryImageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, _, _) =>
                        ColoredBox(color: colorScheme.surfaceContainerHigh, child: const SizedBox.expand()),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAuthorRow(context, post.author),
                  if (bodyText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    if (primaryImageUrl == null && contentEmbed == null)
                      // Text-only: larger, tighter body text
                      FacetText(
                        text: bodyText,
                        facets: record?.facets,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(letterSpacing: -0.5),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      FacetText(
                        text: bodyText,
                        facets: record?.facets,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                  if (contentEmbed != null) ...[const SizedBox(height: 8), contentEmbed],
                ],
              ),
            ),
            resolvedFooter,
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorRow(BuildContext context, ProfileViewBasic author) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        GestureDetector(
          key: const ValueKey('grid_post_card_avatar'),
          onTap: () => GoRouter.maybeOf(context)?.push('/profile/view?actor=${Uri.encodeQueryComponent(author.did)}'),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: author.avatar != null
                ? Image.network(author.avatar!, fit: BoxFit.cover)
                : Center(
                    child: Text(
                      _initials(author.displayName ?? author.handle),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (author.displayName != null && author.displayName!.isNotEmpty)
                Text(
                  author.displayName!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              Text(
                '@${author.handle}'.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: colorScheme.onSurfaceVariant,
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

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }
}
