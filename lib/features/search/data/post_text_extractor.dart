import 'package:bluesky_poptart/app/bsky/embed/record_with_media.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/post.dart';

/// Extracts a single searchable string from a [PostView] for embedding.
///
/// Concatenates (in order, separated by spaces):
/// 1. Post body text
/// 2. Alt-text from every image in an images embed
/// 3. Title + description from an external link-card embed
///
/// Returns an empty string if no text can be extracted.
class PostTextExtractor {
  const PostTextExtractor();

  String extract(PostView post) {
    final parts = <String>[];

    final recordText = _recordText(post.record);
    if (recordText.isNotEmpty) parts.add(recordText);

    final embed = post.embed;
    if (embed != null) {
      if (embed.isEmbedImagesView) {
        for (final image in embed.embedImagesView!.images) {
          final alt = image.alt.trim();
          if (alt.isNotEmpty) parts.add(alt);
        }
      } else if (embed.isEmbedExternalView) {
        final external = embed.embedExternalView!.external;
        final title = external.title.trim();
        if (title.isNotEmpty) parts.add(title);
        final desc = external.description.trim();
        if (desc.isNotEmpty) parts.add(desc);
      } else if (embed.isEmbedRecordWithMediaView) {
        final media = embed.embedRecordWithMediaView!.media;
        if (media.isEmbedImagesView) {
          for (final image in media.embedImagesView!.images) {
            final alt = image.alt.trim();
            if (alt.isNotEmpty) parts.add(alt);
          }
        } else if (media.isEmbedExternalView) {
          final external = media.embedExternalView!.external;
          final title = external.title.trim();
          if (title.isNotEmpty) parts.add(title);
          final desc = external.description.trim();
          if (desc.isNotEmpty) parts.add(desc);
        }
      }
    }

    return parts.join(' ');
  }

  String _recordText(Map<String, dynamic> record) {
    try {
      return FeedPostRecord.fromJson(record).text.trim();
    } catch (_) {
      return '';
    }
  }
}
