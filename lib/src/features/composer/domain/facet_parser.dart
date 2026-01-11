import 'dart:convert';

import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

/// A facet represents rich text features in post content.
///
/// Facets include mentions (@handle), links (https://...), and hashtags (#topic).
/// Each facet has a byte range (UTF-8 encoded) and associated features.
class Facet {
  Facet({required this.index, required this.features});

  final FacetIndex index;
  final List<FacetFeature> features;

  Map<String, dynamic> toJson() {
    return {'index': index.toJson(), 'features': features.map((f) => f.toJson()).toList()};
  }
}

/// Byte range for a facet in UTF-8 encoded text.
class FacetIndex {
  FacetIndex({required this.byteStart, required this.byteEnd});

  final int byteStart;
  final int byteEnd;

  Map<String, dynamic> toJson() {
    return {'byteStart': byteStart, 'byteEnd': byteEnd};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FacetIndex && other.byteStart == byteStart && other.byteEnd == byteEnd;
  }

  @override
  int get hashCode => byteStart.hashCode ^ byteEnd.hashCode;
}

/// A feature within a facet (mention, link, hashtag, etc.).
abstract class FacetFeature {
  Map<String, dynamic> toJson();
}

/// A mention facet feature (@handle → DID).
class MentionFeature implements FacetFeature {
  MentionFeature({required this.did});

  final String did;

  @override
  Map<String, dynamic> toJson() {
    return {'\$type': 'app.bsky.richtext.facet#mention', 'did': did};
  }
}

/// A link facet feature (URL).
class LinkFeature implements FacetFeature {
  LinkFeature({required this.uri});

  final String uri;

  @override
  Map<String, dynamic> toJson() {
    return {'\$type': 'app.bsky.richtext.facet#link', 'uri': uri};
  }
}

/// A hashtag facet feature (#topic).
class HashtagFeature implements FacetFeature {
  HashtagFeature({required this.tag});

  final String tag;

  @override
  Map<String, dynamic> toJson() {
    return {'\$type': 'app.bsky.richtext.facet#tag', 'tag': tag};
  }
}

/// Parses text to detect and build facets for mentions, links, and hashtags.
///
/// Facets are used to encode rich text features in Bluesky posts. This parser
/// detects @mentions, URLs, and #hashtags, resolves handles to DIDs via the
/// identity service, and calculates byte offsets for proper UTF-8 encoding.
class FacetParser {
  FacetParser({required XrpcClient api, required Logger logger}) : _api = api, _logger = logger;

  final XrpcClient _api;
  final Logger _logger;

  /// Regular expression for detecting @mentions.
  ///
  /// Matches @handle or @handle.domain format.
  /// Handle must start with letter/digit, contain only alphanumeric, hyphen, or period.
  static final _mentionRegex = RegExp(
    r'(?:^|[^\w])(@([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)',
  );

  /// Regular expression for detecting URLs.
  ///
  /// Matches http://, https://, and common TLDs without protocol.
  /// This pattern validates against common TLDs and handles trailing punctuation.
  static final _urlRegex = RegExp(
    r'(?:https?://[^\s]+|(?:www\.)?[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?:\.[a-zA-Z]{2,}){1,2}(?::\d+)?(?:/[^\s]*)?)[^\s.<>()\[\]{}"'
    '.,;:!?]*',
  );

  /// Characters that should be trimmed from the end of detected URLs.
  /// Allows word chars, path chars, and port numbers (with colon).
  static final _trailingUrlPunctuation = RegExp(r'[^\w/~\-:?]+$');

  /// Regular expression for detecting #hashtags.
  ///
  /// Matches #tag format where tag starts with letter, number, or underscore, followed by letters,
  /// numbers, or underscores.
  ///
  /// The full match must not contain hyphens.
  static final _hashtagRegex = RegExp(r'(?:^|[^\w/])(#[a-zA-Z0-9_]+)');

  /// Parses text and returns a list of facets.
  ///
  /// Detects mentions, links, and hashtags, resolves handles to DIDs, and calculates byte offsets
  /// for each facet.
  ///
  /// Returns the facets as a JSON-encoded string suitable for storage.
  Future<String?> parse(String text) async {
    if (text.isEmpty) {
      return null;
    }

    final facets = <Facet>[];
    final mentionMatches = _mentionRegex.allMatches(text);
    final mentionRanges = <FacetIndex>{};
    final mentions = await _detectMentions(text, mentionMatches, mentionRanges);
    final links = _detectLinks(text, excludeRanges: mentionRanges);

    facets.addAll(links);
    facets.addAll(mentions);

    final hashtags = _detectHashtags(text);
    facets.addAll(hashtags);

    if (facets.isEmpty) {
      return null;
    }

    facets.sort((a, b) => a.index.byteStart.compareTo(b.index.byteStart));

    final facetsJson = facets.map((f) => f.toJson()).toList();
    return jsonEncode(facetsJson);
  }

  /// Detects @mentions in text and resolves them to DIDs.
  ///
  /// Returns a list of mention facets with byte offsets and resolved DIDs.
  /// Populates [mentionRanges] with all mention match ranges (for excluding from URL detection).
  Future<List<Facet>> _detectMentions(
    String text,
    Iterable<RegExpMatch> matches,
    Set<FacetIndex> mentionRanges,
  ) async {
    final facets = <Facet>[];

    for (final match in matches) {
      final fullMatch = match.group(1);
      if (fullMatch == null) continue;

      final handle = fullMatch.substring(1);

      final mentionStart = match.start + text.substring(match.start, match.end).indexOf('@');
      final mentionEnd = mentionStart + fullMatch.length;
      final byteStart = _calculateByteOffset(text, mentionStart);
      final byteEnd = _calculateByteOffset(text, mentionEnd);
      final range = FacetIndex(byteStart: byteStart, byteEnd: byteEnd);
      mentionRanges.add(range);

      try {
        final did = await _resolveHandle(handle);

        if (did != null) {
          facets.add(
            Facet(
              index: range,
              features: [MentionFeature(did: did)],
            ),
          );
        }
      } catch (e, stack) {
        _logger.warning('Failed to resolve handle: $handle', e, stack);
      }
    }

    return facets;
  }

  /// Detects URLs in text.
  ///
  /// Returns a list of link facets with byte offsets.
  /// [excludeRanges] is a set of byte ranges to exclude from URL detection (e.g., mentions).
  List<Facet> _detectLinks(String text, {Set<FacetIndex> excludeRanges = const {}}) {
    final facets = <Facet>[];
    final matches = _urlRegex.allMatches(text);

    for (final match in matches) {
      final url = match.group(0);
      if (url == null) continue;

      final trimmedUrl = url.replaceAll(_trailingUrlPunctuation, '');

      if (trimmedUrl.isEmpty) continue;

      final byteStart = _calculateByteOffset(text, match.start);
      final byteEnd = _calculateByteOffset(text, match.start + trimmedUrl.length);

      bool overlaps = false;
      for (final range in excludeRanges) {
        if (byteStart < range.byteEnd && byteEnd > range.byteStart) {
          overlaps = true;
          break;
        }
      }
      if (overlaps) continue;

      var normalizedUrl = trimmedUrl;
      if (!trimmedUrl.startsWith('http://') && !trimmedUrl.startsWith('https://')) {
        normalizedUrl = 'https://$trimmedUrl';
      }

      if (!_isValidUrl(normalizedUrl)) {
        continue;
      }

      facets.add(
        Facet(
          index: FacetIndex(byteStart: byteStart, byteEnd: byteEnd),
          features: [LinkFeature(uri: normalizedUrl)],
        ),
      );
    }

    return facets;
  }

  /// Detects #hashtags in text.
  ///
  /// Returns a list of hashtag facets with byte offsets.
  List<Facet> _detectHashtags(String text) {
    final facets = <Facet>[];
    final matches = _hashtagRegex.allMatches(text);

    for (final match in matches) {
      final fullMatch = match.group(1);
      if (fullMatch == null) continue;

      final tag = fullMatch.substring(1);

      if (tag.isEmpty) continue;

      if (RegExp(r'^_+$').hasMatch(tag)) continue;

      if (RegExp(r'^\d+$').hasMatch(tag)) continue;

      if (match.end < text.length && text[match.end] == '-') {
        continue;
      }

      final hashtagStart = match.start + text.substring(match.start, match.end).indexOf('#');
      final hashtagEnd = hashtagStart + fullMatch.length;

      final byteStart = _calculateByteOffset(text, hashtagStart);
      final byteEnd = _calculateByteOffset(text, hashtagEnd);

      facets.add(
        Facet(
          index: FacetIndex(byteStart: byteStart, byteEnd: byteEnd),
          features: [HashtagFeature(tag: tag)],
        ),
      );
    }

    return facets;
  }

  /// Resolves a handle to a DID via the identity service.
  ///
  /// Returns the DID if successful, null otherwise.
  Future<String?> _resolveHandle(String handle) async {
    try {
      final response = await _api.call(
        'com.atproto.identity.resolveHandle',
        params: {'handle': handle},
      );

      return response['did'] as String?;
    } catch (e) {
      _logger.warning('Handle resolution failed for $handle: $e');
      return null;
    }
  }

  /// Calculates the byte offset for a character position in UTF-8 encoded text.
  ///
  /// Dart strings use UTF-16 internally, but AT Protocol requires UTF-8 byte offsets.
  /// This method converts character positions to UTF-8 byte offsets.
  int _calculateByteOffset(String text, int charOffset) {
    if (charOffset == 0) {
      return 0;
    }

    final substring = text.substring(0, charOffset);

    final bytes = utf8.encode(substring);
    return bytes.length;
  }

  /// Validates if a string is a valid URL.
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority && uri.host.contains('.');
    } catch (e) {
      return false;
    }
  }
}
