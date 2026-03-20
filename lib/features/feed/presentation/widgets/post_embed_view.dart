import 'package:bluesky/app_bsky_embed_external.dart';
import 'package:bluesky/app_bsky_embed_images.dart';
import 'package:bluesky/app_bsky_embed_record.dart';
import 'package:bluesky/app_bsky_embed_recordwithmedia.dart';
import 'package:bluesky/app_bsky_embed_video.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_post.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/feed/presentation/media/image_viewer_route_args.dart';
import 'package:lazurite/features/feed/presentation/media/media_actions.dart';
import 'package:lazurite/features/feed/presentation/media/video_player_route_args.dart';
import 'package:lazurite/features/feed/presentation/widgets/facet_text.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders the appropriate embed widget for a post embed.
///
/// Handles images, external links, videos, quoted records, and record-with-media.
/// Used by both [PostCard] and [GridPostCard].
class PostEmbedView extends StatelessWidget {
  const PostEmbedView({super.key, required this.feedViewPost, required this.embed});

  final FeedViewPost feedViewPost;
  final UPostViewEmbed embed;

  @override
  Widget build(BuildContext context) {
    return _buildEmbed(context, embed) ?? const SizedBox.shrink();
  }

  Widget? _buildEmbed(BuildContext context, UPostViewEmbed embed) {
    if (embed.isEmbedImagesView) {
      return _buildImagesEmbed(context, embed.embedImagesView!.images);
    }

    if (embed.isEmbedExternalView) {
      return _buildExternalEmbed(context, embed.embedExternalView!.external);
    }

    if (embed.isEmbedRecordView) {
      return _buildQuotedRecord(context, embed.embedRecordView!);
    }

    if (embed.isEmbedVideoView) {
      return _buildVideoEmbed(context, embed.embedVideoView!);
    }

    if (embed.isEmbedRecordWithMediaView) {
      final recordWithMedia = embed.embedRecordWithMediaView!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecordWithMediaMedia(context, recordWithMedia.media),
          const SizedBox(height: 8),
          _buildQuotedRecord(context, recordWithMedia.record),
        ],
      );
    }

    return null;
  }

  Widget _buildRecordWithMediaMedia(BuildContext context, UEmbedRecordWithMediaViewMedia media) {
    if (media.isEmbedImagesView) {
      return _buildImagesEmbed(context, media.embedImagesView!.images);
    }
    if (media.isEmbedExternalView) {
      return _buildExternalEmbed(context, media.embedExternalView!.external);
    }
    if (media.isEmbedVideoView) {
      return _buildVideoEmbed(context, media.embedVideoView!);
    }
    return const SizedBox.shrink();
  }

  Widget _buildImagesEmbed(BuildContext context, List<EmbedImagesViewImage> images) {
    final crossAxisCount = images.length == 1 ? 1 : 2;
    final childAspectRatio = images.length == 1 ? 16 / 9 : 1.0;
    final postUri = feedViewPost.post.uri.toString();

    return GridView.builder(
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
        final heroTag = _imageHeroTag(postUri, index);

        return GestureDetector(
          onLongPressStart: (details) => _showImageContextMenu(context, details.globalPosition, image: image),
          child: InkWell(
            onTap: () => _openImageViewer(context, images, initialIndex: index),
            child: Hero(
              tag: heroTag,
              child: Image.network(
                image.thumb,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(child: Icon(Icons.image_not_supported_outlined)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExternalEmbed(BuildContext context, EmbedExternalViewExternal external) {
    return InkWell(
      onTap: () => _launchExternal(Uri.parse(external.uri)),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (external.thumb != null)
              Image.network(
                external.thumb!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(height: 0),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    external.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (external.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      external.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    Uri.parse(external.uri).host,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoEmbed(BuildContext context, EmbedVideoView video) {
    return InkWell(
      onTap: () => _openVideoViewer(context, video),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: video.aspectRatio == null ? 16 / 9 : video.aspectRatio!.width / video.aspectRatio!.height,
            child: video.thumbnail == null
                ? ColoredBox(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const SizedBox.expand(),
                  )
                : Image.network(
                    video.thumbnail!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuotedRecord(BuildContext context, EmbedRecordView recordView) {
    final record = recordView.record;

    if (record.isEmbedRecordViewRecord) {
      final quoted = record.embedRecordViewRecord!;
      final quotedRecord = _tryParseRecord(quoted.value);
      final nestedEmbed = _buildQuotedEmbeds(context, quoted.embeds);

      return Container(
        decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor)),
        child: InkWell(
          onTap: () {
            GoRouter.maybeOf(context)?.push('/post?uri=${Uri.encodeComponent(quoted.uri.toString())}');
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: quoted.author.avatar != null
                          ? Image.network(quoted.author.avatar!, fit: BoxFit.cover)
                          : Center(child: Text(_initials(quoted.author.displayName ?? quoted.author.handle))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${quoted.author.displayName ?? quoted.author.handle} @${quoted.author.handle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                if (quotedRecord != null && quotedRecord.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  FacetText(
                    text: quotedRecord.text,
                    facets: quotedRecord.facets,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
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
      return _buildUnavailableQuote(context, 'Quoted post not found');
    }
    if (record.isEmbedRecordViewBlocked) {
      return _buildUnavailableQuote(context, 'Quoted post is blocked');
    }
    if (record.isEmbedRecordViewDetached) {
      return _buildUnavailableQuote(context, 'Quoted post is unavailable');
    }

    return const SizedBox.shrink();
  }

  Widget _buildUnavailableQuote(BuildContext context, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget? _buildQuotedEmbeds(BuildContext context, List<UEmbedRecordViewRecordEmbeds>? embeds) {
    if (embeds == null || embeds.isEmpty) return null;

    final embed = embeds.first;

    if (embed.isEmbedImagesView) {
      return _buildImagesEmbed(context, embed.embedImagesView!.images);
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
          _buildRecordWithMediaMedia(context, recordWithMedia.media),
          const SizedBox(height: 8),
          _buildQuotedRecord(context, recordWithMedia.record),
        ],
      );
    }

    return null;
  }

  void _openImageViewer(BuildContext context, List<EmbedImagesViewImage> images, {required int initialIndex}) {
    GoRouter.maybeOf(context)?.push(
      '/images',
      extra: ImageViewerRouteArgs(
        images: [
          for (var i = 0; i < images.length; i++)
            ImageViewerItem(
              fullsizeUrl: images[i].fullsize,
              thumbnailUrl: images[i].thumb,
              altText: images[i].alt,
              heroTag: _imageHeroTag(feedViewPost.post.uri.toString(), i),
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
      items: const [
        PopupMenuItem<_ImageThumbnailAction>(value: _ImageThumbnailAction.save, child: Text('Save image')),
        PopupMenuItem<_ImageThumbnailAction>(value: _ImageThumbnailAction.share, child: Text('Share')),
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
    final ratio = video.aspectRatio == null ? null : video.aspectRatio!.width / video.aspectRatio!.height;
    final isGif = video.presentation?.knownValue == KnownEmbedVideoViewPresentation.gif;
    GoRouter.maybeOf(context)?.push(
      '/video',
      extra: VideoPlayerRouteArgs(
        playlistUrl: video.playlist,
        thumbnailUrl: video.thumbnail,
        altText: video.alt,
        aspectRatio: ratio,
        isGif: isGif,
      ),
    );
  }

  String _imageHeroTag(String postUri, int index) => 'post-image-$postUri-$index';

  String _downloadFileName(String url) {
    final uri = Uri.tryParse(url);
    final segment = uri?.pathSegments.isNotEmpty == true ? uri!.pathSegments.last : 'image.jpg';
    return segment.isEmpty ? 'image.jpg' : segment;
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

Future<void> _launchExternal(Uri url) async {
  await launchUrl(url, mode: LaunchMode.externalApplication);
}

enum _ImageThumbnailAction { save, share }
