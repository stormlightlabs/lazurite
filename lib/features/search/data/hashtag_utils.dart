import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/post.dart';
import 'package:bluesky_poptart/app/bsky/richtext/facet.dart';
import 'package:poptart_bluesky_text/poptart_bluesky_text.dart';
import 'package:lazurite/shared/utils/parse_utils.dart';

String normalizeHashtag(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) {
    return '';
  }

  final withoutPound = trimmed.replaceFirst(RegExp(r'^#+'), '');
  if (withoutPound.isEmpty) {
    return '';
  }

  final token = withoutPound.split(RegExp(r'\s+')).first;
  return token.replaceFirst(RegExp(r'^#+'), '').trim();
}

List<String> extractRelatedHashtags(List<PostView> posts, {required String currentTag, int limit = 12}) {
  final normalizedCurrent = normalizeHashtag(currentTag).toLowerCase();
  final counts = <String, int>{};
  final canonical = <String, String>{};

  for (final post in posts) {
    final record = tryParseRecord(post.record);
    if (record == null) {
      continue;
    }

    final seenInPost = <String>{};

    for (final tag in _extractTags(record)) {
      final normalized = normalizeHashtag(tag).toLowerCase();
      if (normalized.isEmpty || normalized == normalizedCurrent || seenInPost.contains(normalized)) {
        continue;
      }

      seenInPost.add(normalized);
      counts.update(normalized, (value) => value + 1, ifAbsent: () => 1);
      canonical.putIfAbsent(normalized, () => normalizeHashtag(tag));
    }
  }

  final entries = counts.entries.toList(growable: false)
    ..sort((a, b) {
      final countCompare = b.value.compareTo(a.value);
      if (countCompare != 0) {
        return countCompare;
      }
      return a.key.compareTo(b.key);
    });

  return entries.take(limit).map((entry) => canonical[entry.key] ?? entry.key).toList(growable: false);
}

Iterable<String> _extractTags(FeedPostRecord record) sync* {
  final facets = record.facets;
  if (facets != null) {
    for (final facet in facets) {
      for (final feature in facet.features) {
        if (feature.isRichtextFacetTag && feature.richtextFacetTag != null) {
          yield feature.richtextFacetTag!.tag;
        }
      }
    }
  }

  final text = record.text;
  if (text.isEmpty) {
    return;
  }

  try {
    for (final entity in BlueskyText(text, enableMarkdown: false).entities) {
      if (entity.type == EntityType.tag) {
        yield entity.value;
      }
    }
  } catch (_) {
    for (final match in RegExp(r'(?<!\w)#([A-Za-z0-9_]+)').allMatches(text)) {
      final value = match.group(1);
      if (value != null && value.isNotEmpty) {
        yield value;
      }
    }
  }
}
