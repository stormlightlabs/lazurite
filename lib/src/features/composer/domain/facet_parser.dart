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
  static final _urlRegex = RegExp(
    r'(?:https?://)?(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&/=]*)',
  );

  /// Regular expression for detecting #hashtags.
  ///
  /// Matches #tag format (letters, numbers, underscore).
  static final _hashtagRegex = RegExp(r'(?:^|[^\w])(#[a-zA-Z0-9_]+)');

  /// Parses text and returns a list of facets.
  ///
  /// Detects mentions, links, and hashtags, resolves handles to DIDs,
  /// and calculates byte offsets for each facet.
  ///
  /// Returns the facets as a JSON-encoded string suitable for storage.
  Future<String?> parse(String text) async {
    if (text.isEmpty) {
      return null;
    }

    final facets = <Facet>[];

    final mentions = await _detectMentions(text);
    facets.addAll(mentions);

    final links = _detectLinks(text);
    facets.addAll(links);

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
  Future<List<Facet>> _detectMentions(String text) async {
    final facets = <Facet>[];
    final matches = _mentionRegex.allMatches(text);

    for (final match in matches) {
      final fullMatch = match.group(1);
      if (fullMatch == null) continue;

      final handle = fullMatch.substring(1);

      try {
        final did = await _resolveHandle(handle);

        if (did != null) {
          final mentionStart = match.start + text.substring(match.start, match.end).indexOf('@');
          final mentionEnd = mentionStart + fullMatch.length;

          final byteStart = _calculateByteOffset(text, mentionStart);
          final byteEnd = _calculateByteOffset(text, mentionEnd);

          facets.add(
            Facet(
              index: FacetIndex(byteStart: byteStart, byteEnd: byteEnd),
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
  List<Facet> _detectLinks(String text) {
    final facets = <Facet>[];
    final matches = _urlRegex.allMatches(text);

    for (final match in matches) {
      final url = match.group(0);
      if (url == null) continue;

      if (url.startsWith('@') || (match.start > 0 && text[match.start - 1] == '@')) {
        continue;
      }

      var normalizedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        normalizedUrl = 'https://$url';
      }

      if (!_isValidUrl(normalizedUrl)) {
        continue;
      }

      final byteStart = _calculateByteOffset(text, match.start);
      final byteEnd = _calculateByteOffset(text, match.end);

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
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }
}
