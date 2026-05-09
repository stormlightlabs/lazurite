import 'package:poptart_lex/app/bsky/embed/external.dart';
import 'package:poptart_lex/app/bsky/embed/images.dart';
import 'package:poptart_lex/app/bsky/embed/record.dart';
import 'package:poptart_lex/app/bsky/embed/record_with_media.dart';
import 'package:poptart_lex/app/bsky/embed/video.dart';
import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:bsky_moderation/bsky_moderation.dart' as bsky_moderation;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/cache/lazurite_image_cache.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/feed/presentation/media/image_viewer_route_args.dart';
import 'package:lazurite/features/feed/presentation/media/media_actions.dart';
import 'package:lazurite/features/feed/presentation/media/video_layout.dart';
import 'package:lazurite/features/feed/presentation/media/video_player_route_args.dart';
import 'package:lazurite/features/feed/presentation/widgets/facet_text.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_text_styles.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_blur_overlay.dart';
import 'package:lazurite/shared/presentation/widgets/actor_name_widget.dart';
import 'package:lazurite/shared/presentation/widgets/external_link_preview_card.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';
import 'package:lazurite/shared/utils/parse_utils.dart';

/// Renders the appropriate embed widget for a post embed.
///
/// Handles images, external links, videos, quoted records, and record-with-media.
/// Used by both [PostCard] and [GridPostCard].
class PostEmbedView extends StatelessWidget {
  const PostEmbedView({super.key, required this.feedViewPost, required this.embed, this.compact = false});

  final FeedViewPost feedViewPost;
  final UPostViewEmbed embed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final rootHeroNamespace = '${feedViewPost.post.uri}#${identityHashCode(this)}';
    return _buildEmbed(context, embed, heroNamespace: rootHeroNamespace) ?? const SizedBox.shrink();
  }

  Widget? _buildEmbed(BuildContext context, UPostViewEmbed embed, {required String heroNamespace}) {
    if (embed.isEmbedImagesView) {
      return _buildImagesEmbed(context, embed.embedImagesView!.images, heroNamespace: '$heroNamespace/images');
    }

    if (embed.isEmbedExternalView) {
      return _buildExternalEmbed(context, embed.embedExternalView!.external);
    }

    if (embed.isEmbedRecordView) {
      return _buildQuotedRecord(context, embed.embedRecordView!, heroNamespace: '$heroNamespace/record');
    }

    if (embed.isEmbedVideoView) {
      return _buildVideoEmbed(context, embed.embedVideoView!);
    }

    if (embed.isEmbedRecordWithMediaView) {
      final recordWithMedia = embed.embedRecordWithMediaView!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecordWithMediaMedia(context, recordWithMedia.media, heroNamespace: '$heroNamespace/rwm-media'),
          const SizedBox(height: 8),
          _buildQuotedRecord(context, recordWithMedia.record, heroNamespace: '$heroNamespace/rwm-record'),
        ],
      );
    }

    return null;
  }

  Widget _buildRecordWithMediaMedia(
    BuildContext context,
    UEmbedRecordWithMediaViewMedia media, {
    required String heroNamespace,
  }) {
    if (media.isEmbedImagesView) {
      return _buildImagesEmbed(context, media.embedImagesView!.images, heroNamespace: '$heroNamespace/images');
    }
    if (media.isEmbedExternalView) {
      return _buildExternalEmbed(context, media.embedExternalView!.external);
    }
    if (media.isEmbedVideoView) {
      return _buildVideoEmbed(context, media.embedVideoView!);
    }
    return const SizedBox.shrink();
  }

  Widget _buildImagesEmbed(BuildContext context, List<EmbedImagesViewImage> images, {required String heroNamespace}) {
    final crossAxisCount = images.length == 1 ? 1 : 2;
    final childAspectRatio = images.length == 1 ? 16 / 9 : 1.0;
    final moderationService = maybeModerationService(context);
    final mediaUi =
        moderationService?.postUi(feedViewPost.post, bsky_moderation.ModerationBehaviorContext.contentMedia) ??
        const bsky_moderation.ModerationUI();

    return ModeratedBlurOverlay(
      ui: mediaUi,
      borderRadius: BorderRadius.circular(12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: images.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: childAspectRatio,
        ),
        itemBuilder: (context, index) {
          final image = images[index];
          final heroTag = _imageHeroTag(heroNamespace, index);

          return GestureDetector(
            onLongPressStart: (details) => _showImageContextMenu(context, details.globalPosition, image: image),
            child: InkWell(
              onTap: () => _openImageViewer(context, images, initialIndex: index, heroNamespace: heroNamespace),
              child: Hero(
                tag: heroTag,
                child: CachedNetworkImage(
                  imageUrl: image.thumb,
                  cacheManager: LazuriteImageCacheManager.instance,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => ColoredBox(
                    color: context.colorScheme.surfaceContainerHighest,
                    child: const Center(child: Icon(Icons.image_not_supported_outlined)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExternalEmbed(BuildContext context, EmbedExternalViewExternal external) => ExternalLinkPreviewCard(
    uri: external.uri,
    title: external.title,
    description: external.description,
    thumbUrl: external.thumb,
    compact: compact,
    cacheManager: LazuriteImageCacheManager.instance,
  );

  Widget _buildVideoEmbed(BuildContext context, EmbedVideoView video) {
    final moderationService = maybeModerationService(context);
    final mediaUi =
        moderationService?.postUi(feedViewPost.post, bsky_moderation.ModerationBehaviorContext.contentMedia) ??
        const bsky_moderation.ModerationUI();

    final aspectRatio = normalizeVideoAspectRatio(_rawAspectRatio(video));

    return ModeratedBlurOverlay(
      ui: mediaUi,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _openVideoViewer(context, video),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: aspectRatio,
              child: video.thumbnail == null
                  ? ColoredBox(color: context.colorScheme.surfaceContainerHighest, child: const SizedBox.expand())
                  : CachedNetworkImage(
                      imageUrl: video.thumbnail!,
                      cacheManager: LazuriteImageCacheManager.instance,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => ColoredBox(
                        color: context.colorScheme.surfaceContainerHighest,
                        child: const SizedBox.expand(),
                      ),
                    ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.65), shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
            ),
            if (video.alt?.isNotEmpty ?? false)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Text(
                  video.alt!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotedRecord(BuildContext context, EmbedRecordView recordView, {required String heroNamespace}) {
    final record = recordView.record;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (record.isEmbedRecordViewRecord) {
      final quoted = record.embedRecordViewRecord!;
      final quotedRecord = tryParseRecord(quoted.value);
      final nestedHeroNamespace = '$heroNamespace/quote:${quoted.uri}';
      final nestedEmbed = _buildQuotedEmbeds(context, quoted.embeds, heroNamespace: '$nestedHeroNamespace/embeds');

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.surfaceContainerLow,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            GoRouter.maybeOf(context)?.push('/post?uri=${Uri.encodeComponent(quoted.uri.toString())}');
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileAvatar(
                      size: 28,
                      imageUrl: quoted.author.avatar,
                      fallbackText: quoted.author.displayName ?? quoted.author.handle,
                      shape: BoxShape.rectangle,
                      border: Border.all(color: context.colorScheme.outlineVariant),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ActorNameWidget(
                        displayName: quoted.author.displayName,
                        handle: quoted.author.handle,
                        displayNameStyle: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        handleStyle: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        uppercaseHandle: false,
                      ),
                    ),
                  ],
                ),
                if (quotedRecord != null && quotedRecord.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  FacetText(
                    text: quotedRecord.text,
                    facets: quotedRecord.facets,
                    style: feedPostBodyTextStyle(context, compact: compact, nested: true),
                    maxLines: compact ? 6 : null,
                    overflow: compact ? TextOverflow.ellipsis : TextOverflow.visible,
                  ),
                ],
                if (nestedEmbed != null) ...[const SizedBox(height: 8), nestedEmbed],
              ],
            ),
          ),
        ),
      );
    }

    if (record.isEmbedRecordViewNotFound) {
      return _buildUnavailableQuote(context, context.l10n.messageQuotedPostNotFound);
    }
    if (record.isEmbedRecordViewBlocked) {
      return _buildUnavailableQuote(context, context.l10n.messageQuotedPostBlocked);
    }
    if (record.isEmbedRecordViewDetached) {
      return _buildUnavailableQuote(context, context.l10n.messageQuotedPostUnavailable);
    }

    return const SizedBox.shrink();
  }

  Widget _buildUnavailableQuote(BuildContext context, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
    );
  }

  Widget? _buildQuotedEmbeds(
    BuildContext context,
    List<UEmbedRecordViewRecordEmbeds>? embeds, {
    required String heroNamespace,
  }) {
    if (embeds == null || embeds.isEmpty) return null;

    final embed = embeds.first;

    if (embed.isEmbedImagesView) {
      return _buildImagesEmbed(context, embed.embedImagesView!.images, heroNamespace: '$heroNamespace/images');
    }
    if (embed.isEmbedExternalView) {
      return _buildExternalEmbed(context, embed.embedExternalView!.external);
    }
    if (embed.isEmbedVideoView) {
      return _buildVideoEmbed(context, embed.embedVideoView!);
    }
    if (embed.isEmbedRecordWithMediaView) {
      final recordWithMedia = embed.embedRecordWithMediaView!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecordWithMediaMedia(context, recordWithMedia.media, heroNamespace: '$heroNamespace/rwm-media'),
          const SizedBox(height: 8),
          _buildQuotedRecord(context, recordWithMedia.record, heroNamespace: '$heroNamespace/rwm-record'),
        ],
      );
    }

    return null;
  }

  void _openImageViewer(
    BuildContext context,
    List<EmbedImagesViewImage> images, {
    required int initialIndex,
    required String heroNamespace,
  }) {
    GoRouter.maybeOf(context)?.push(
      '/images',
      extra: ImageViewerRouteArgs(
        images: [
          for (var i = 0; i < images.length; i++)
            ImageViewerItem(
              fullsizeUrl: images[i].fullsize,
              thumbnailUrl: images[i].thumb,
              altText: images[i].alt,
              heroTag: _imageHeroTag(heroNamespace, i),
            ),
        ],
        initialIndex: initialIndex,
      ),
    );
  }

  Future<void> _showImageContextMenu(
    BuildContext context,
    Offset globalPosition, {
    required EmbedImagesViewImage image,
  }) async {
    final selected = await showMenu<_ImageThumbnailAction>(
      context: context,
      position: RelativeRect.fromLTRB(globalPosition.dx, globalPosition.dy, globalPosition.dx, globalPosition.dy),
      items: [
        PopupMenuItem<_ImageThumbnailAction>(
          value: _ImageThumbnailAction.save,
          child: Text(context.l10n.labelSaveImage),
        ),
        PopupMenuItem<_ImageThumbnailAction>(value: _ImageThumbnailAction.share, child: Text(context.l10n.buttonShare)),
      ],
    );

    if (!context.mounted || selected == null) return;

    switch (selected) {
      case _ImageThumbnailAction.save:
        await MediaActions.downloadImage(context, image.fullsize, suggestedName: _downloadFileName(image.fullsize));
      case _ImageThumbnailAction.share:
        await MediaActions.shareImage(context, image.fullsize);
    }
  }

  void _openVideoViewer(BuildContext context, EmbedVideoView video) {
    final ratio = normalizeVideoAspectRatio(_rawAspectRatio(video));
    final isGif = video.presentation?.knownValue == KnownEmbedVideoViewPresentation.gif;
    final downloadUrl = MediaActions.buildBlueskyBlobDownloadUrl(playlistUrl: video.playlist);
    GoRouter.maybeOf(context)?.push(
      '/video',
      extra: VideoPlayerRouteArgs(
        playlistUrl: video.playlist,
        downloadUrl: downloadUrl,
        thumbnailUrl: video.thumbnail,
        altText: video.alt,
        aspectRatio: ratio,
        isGif: isGif,
      ),
    );
  }

  double? _rawAspectRatio(EmbedVideoView video) {
    final ratio = video.aspectRatio;
    if (ratio == null || ratio.height == 0) {
      return null;
    }
    return ratio.width / ratio.height;
  }

  String _imageHeroTag(String heroNamespace, int index) => 'post-image-$heroNamespace-$index';

  String _downloadFileName(String url) {
    final uri = Uri.tryParse(url);
    final segment = uri?.pathSegments.isNotEmpty == true ? uri!.pathSegments.last : 'image.jpg';
    return segment.isEmpty ? 'image.jpg' : segment;
  }
}

enum _ImageThumbnailAction { save, share }
