import 'package:flutter/material.dart';

import 'embeds/embed_external.dart';
import 'embeds/embed_images.dart';
import 'embeds/embed_video.dart';

class PostEmbeds extends StatelessWidget {
  const PostEmbeds({required this.embed, required this.authorDid, this.record, super.key});

  final Map<String, dynamic> embed;
  final String authorDid;
  final Map<String, dynamic>? record;

  @override
  Widget build(BuildContext context) {
    final type = embed[r'$type'] as String?;

    if (type == 'app.bsky.embed.images#view') {
      final images = embed['images'] as List<dynamic>? ?? [];
      return EmbedImages(images: images);
    }

    if (type == 'app.bsky.embed.video#view') {
      String? cid;
      if (record != null &&
          record![r'$type'] == 'app.bsky.feed.post' &&
          record!['embed'] != null &&
          record!['embed'][r'$type'] == 'app.bsky.embed.video') {
        final video = record!['embed']['video'];
        if (video != null && video['ref'] != null) {
          cid = video['ref'][r'$link'] as String?;
        }
      }

      return EmbedVideo(
        playlist: embed['playlist'] as String? ?? '',
        thumbnail: embed['thumbnail'] as String?,
        alt: embed['alt'] as String?,
        cid: cid,
        authorDid: authorDid,
      );
    }

    if (type == 'app.bsky.embed.external#view') {
      final external = embed['external'] as Map<String, dynamic>?;
      if (external != null) {
        return EmbedExternal(external: external);
      }
    }

    if (type == 'app.bsky.embed.recordWithMedia#view') {
      final media = embed['media'] as Map<String, dynamic>?;
      if (media != null) {
        return PostEmbeds(embed: media, authorDid: authorDid, record: record);
      }
    }

    //TODO: other embeds (Record)
    return const SizedBox.shrink();
  }
}
