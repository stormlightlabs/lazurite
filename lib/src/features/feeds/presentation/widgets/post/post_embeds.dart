import 'package:flutter/material.dart';

import 'embeds/embed_external.dart';
import 'embeds/embed_images.dart';
import 'embeds/embed_record.dart';
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

      final aspectRatioData = embed['aspectRatio'] as Map<String, dynamic>?;

      return EmbedVideo(
        playlist: embed['playlist'] as String? ?? '',
        thumbnail: embed['thumbnail'] as String?,
        alt: embed['alt'] as String?,
        cid: cid,
        authorDid: authorDid,
        aspectRatio: aspectRatioData,
        durationSeconds: (embed['durationSeconds'] as num?)?.toInt(),
      );
    }

    if (type == 'app.bsky.embed.external#view') {
      final external = embed['external'] as Map<String, dynamic>?;
      if (external != null) {
        return EmbedExternal(external: external);
      }
    }

    if (type == 'app.bsky.embed.record#view') {
      final recordData = embed['record'] as Map<String, dynamic>?;
      if (recordData != null) {
        return EmbedRecord(record: recordData);
      }
    }

    if (type == 'app.bsky.embed.recordWithMedia#view') {
      final media = embed['media'] as Map<String, dynamic>?;
      final recordData = embed['record'] as Map<String, dynamic>?;
      final nestedRecord = recordData?['record'] as Map<String, dynamic>?;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (media != null) PostEmbeds(embed: media, authorDid: authorDid, record: record),
          if (nestedRecord != null) ...[
            const SizedBox(height: 8),
            EmbedRecord(record: nestedRecord),
          ],
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
