import 'package:bluesky_poptart/app/bsky/embed/external.dart';
import 'package:bluesky_poptart/app/bsky/embed/images.dart';
import 'package:bluesky_poptart/app/bsky/embed/record.dart';
import 'package:bluesky_poptart/app/bsky/embed/record_with_media.dart';
import 'package:bluesky_poptart/app/bsky/embed/video.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
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
import 'package:lazurite/features/feed/presentation/widgets/post_record_embed.dart';
import 'package:lazurite/features/moderation/domain/moderation_models.dart' as bsky_moderation;
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_blur_overlay.dart';
import 'package:lazurite/shared/presentation/widgets/external_link_preview_card.dart';

/// Renders the appropriate embed widget for a post embed.
///
/// Handles images, external links, videos, quoted records, and record-with-media.
/// Used by both [PostCard] and [GridPostCard].
class PostEmbedView extends StatelessWidget {
  const PostEmbedView({super.key, required this.feedViewPost, required this.embed, this.compact = false});

  static const int maxQuoteDepth = 2;

  final FeedViewPost feedViewPost;
  final UPostViewEmbed embed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final rootHeroNamespace = '${feedViewPost.post.uri}#${identityHashCode(this)}';
    return _buildEmbed(context, embed, heroNamespace: rootHeroNamespace, quoteDepth: 0) ?? const SizedBox.shrink();
  }

  Widget? _buildEmbed(
    BuildContext context,
    UPostViewEmbed embed, {
    required String heroNamespace,
    required int quoteDepth,
  }) {
    if (embed.isEmbedImagesView) {
      return _buildImagesEmbed(context, embed.embedImagesView!.images, heroNamespace: '$heroNamespace/images');
    }

    if (embed.isEmbedExternalView) {
      return _buildExternalEmbed(context, embed.embedExternalView!.external);
    }

    if (embed.isEmbedRecordView) {
      return _buildQuotedRecord(
        context,
        embed.embedRecordView!,
        heroNamespace: '$heroNamespace/record',
        quoteDepth: quoteDepth,
      );
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
          _buildQuotedRecord(
            context,
            recordWithMedia.record,
            heroNamespace: '$heroNamespace/rwm-record',
            quoteDepth: quoteDepth,
          ),
        ],
      );
    }
    if (embed.isUnknown) {
      return _buildUnknownEmbed(context);
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
    return _buildUnknownEmbed(context);
  }

  Widget _buildImagesEmbed(BuildContext context, List<EmbedImagesViewImage> images, {required String heroNamespace}) {
    if (compact) {
      return _buildCompactImagesEmbed(context, images, heroNamespace: heroNamespace);
    }

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

  Widget _buildCompactImagesEmbed(
    BuildContext context,
    List<EmbedImagesViewImage> images, {
    required String heroNamespace,
  }) {
    final moderationService = maybeModerationService(context);
    final mediaUi =
        moderationService?.postUi(feedViewPost.post, bsky_moderation.ModerationBehaviorContext.contentMedia) ??
        const bsky_moderation.ModerationUI();
    final visibleImages = images.take(4).toList();

    return ModeratedBlurOverlay(
      ui: mediaUi,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 88,
        child: Row(
          children: [
            for (var index = 0; index < visibleImages.length; index++) ...[
              if (index > 0) const SizedBox(width: 4),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GestureDetector(
                    onLongPressStart: (details) =>
                        _showImageContextMenu(context, details.globalPosition, image: visibleImages[index]),
                    child: InkWell(
                      onTap: () => _openImageViewer(context, images, initialIndex: index, heroNamespace: heroNamespace),
                      child: Hero(
                        tag: _imageHeroTag(heroNamespace, index),
                        child: CachedNetworkImage(
                          imageUrl: visibleImages[index].thumb,
                          cacheManager: LazuriteImageCacheManager.instance,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => ColoredBox(
                            color: context.colorScheme.surfaceContainerHighest,
                            child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 18)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
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

    final preview = ModeratedBlurOverlay(
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

    if (!compact) {
      return preview;
    }

    return SizedBox(height: 96, child: ClipRect(child: preview));
  }

  Widget _buildQuotedRecord(
    BuildContext context,
    EmbedRecordView recordView, {
    required String heroNamespace,
    required int quoteDepth,
  }) {
    return PostRecordEmbed(
      recordView: recordView,
      heroNamespace: heroNamespace,
      quoteDepth: quoteDepth,
      maxQuoteDepth: maxQuoteDepth,
      compact: compact,
      buildImagesEmbed: _buildImagesEmbed,
      buildExternalEmbed: _buildExternalEmbed,
      buildVideoEmbed: _buildVideoEmbed,
      buildUnknownEmbed: _buildUnknownEmbed,
    );
  }

  Widget _buildUnknownEmbed(BuildContext context) {
    return PostRecordResourceCard(
      icon: Icons.extension_outlined,
      fallbackText: context.l10n.labelUnknown,
      label: context.l10n.labelUnknown,
      title: context.l10n.labelUnknown,
      compact: compact,
    );
  }

  void _openImageViewer(
    BuildContext context,
    List<EmbedImagesViewImage> images, {
    required int initialIndex,
    required String heroNamespace,
  }) {
    final args = ImageViewerRouteArgs(
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
    );
    GoRouter.maybeOf(context)?.push(args.location, extra: args);
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
    final args = VideoPlayerRouteArgs(
      playlistUrl: video.playlist,
      downloadUrl: downloadUrl,
      thumbnailUrl: video.thumbnail,
      altText: video.alt,
      aspectRatio: ratio,
      isGif: isGif,
    );
    GoRouter.maybeOf(context)?.push(args.location, extra: args);
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
