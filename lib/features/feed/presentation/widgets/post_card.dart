import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_embed_external.dart';
import 'package:bluesky/app_bsky_embed_images.dart';
import 'package:bluesky/app_bsky_embed_record.dart';
import 'package:bluesky/app_bsky_embed_recordwithmedia.dart';
import 'package:bluesky/app_bsky_embed_video.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_post.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lazurite/features/feed/presentation/widgets/facet_text.dart';
import 'package:url_launcher/url_launcher.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.feedViewPost, this.actionBar});

  final FeedViewPost feedViewPost;
  final Widget? actionBar;

  @override
  Widget build(BuildContext context) {
    final post = feedViewPost.post;
    final record = _tryParseRecord(post.record);
    final embed = _buildEmbed(context, post.embed);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, post.author, record?.createdAt ?? post.indexedAt),
            if (record?.reply != null) ...[const SizedBox(height: 8), _buildReplyLabel(context)],
            if (record != null && record.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              FacetText(text: record.text, facets: record.facets, style: Theme.of(context).textTheme.bodyLarge),
            ],
            if (embed != null) ...[const SizedBox(height: 12), embed],
            const SizedBox(height: 12),
            actionBar ?? _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileViewBasic author, DateTime createdAt) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          backgroundImage: author.avatar != null ? NetworkImage(author.avatar!) : null,
          child: author.avatar == null
              ? Text(_initials(author.displayName ?? author.handle), style: Theme.of(context).textTheme.labelLarge)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author.displayName ?? author.handle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '@${author.handle} · ${_formatTime(createdAt)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReplyLabel(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.reply, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          'Reply in a thread',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final post = feedViewPost.post;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(context, Icons.chat_bubble_outline, '${post.replyCount ?? 0}'),
        _buildActionButton(context, Icons.repeat, '${post.repostCount ?? 0}'),
        _buildActionButton(context, Icons.favorite_border, '${post.likeCount ?? 0}'),
        _buildActionButton(context, Icons.share_outlined, ''),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String count) {
    final iconColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            if (count.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(count, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: iconColor)),
            ],
          ],
        ),
      ),
    );
  }

  Widget? _buildEmbed(BuildContext context, UPostViewEmbed? embed) {
    if (embed == null) {
      return null;
    }

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

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
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
          return InkWell(
            onTap: () => _launchExternal(Uri.parse(image.fullsize)),
            child: Image.network(
              image.thumb,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(child: Icon(Icons.image_not_supported_outlined)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExternalEmbed(BuildContext context, EmbedExternalViewExternal external) {
    return InkWell(
      onTap: () => _launchExternal(Uri.parse(external.uri)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (external.thumb != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  external.thumb!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(height: 0),
                ),
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
      onTap: () => _launchExternal(Uri.parse(video.playlist)),
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
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
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            final router = GoRouter.maybeOf(context);
            if (router != null) {
              router.push('/profile/view?actor=${Uri.encodeQueryComponent(quoted.author.did)}');
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      backgroundImage: quoted.author.avatar != null ? NetworkImage(quoted.author.avatar!) : null,
                      child: quoted.author.avatar == null
                          ? Text(_initials(quoted.author.displayName ?? quoted.author.handle))
                          : null,
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget? _buildQuotedEmbeds(BuildContext context, List<UEmbedRecordViewRecordEmbeds>? embeds) {
    if (embeds == null || embeds.isEmpty) {
      return null;
    }

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

  FeedPostRecord? _tryParseRecord(Map<String, dynamic> record) {
    try {
      return FeedPostRecord.fromJson(record);
    } catch (_) {
      return null;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'now';
    }

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    }

    if (difference.inDays < 1) {
      return '${difference.inHours}h';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d';
    }

    return DateFormat('MMM d').format(time);
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }
}

Future<void> _launchExternal(Uri url) async {
  await launchUrl(url, mode: LaunchMode.externalApplication);
}
