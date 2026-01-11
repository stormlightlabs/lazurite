import 'dart:convert';

import 'package:lazurite/src/features/composer/domain/facet_parser.dart';

/// Helper utilities for working with facets in post display.
///
/// Facets use UTF-8 byte offsets from the AT Protocol, but Flutter uses
/// UTF-16 code units for strings. This helper provides conversion utilities.
class FacetHelper {
  FacetHelper._();

  /// Converts UTF-8 byte offset to character offset in a string.
  ///
  /// The AT Protocol uses UTF-8 byte offsets for facet positions, but
  /// Dart strings use UTF-16 code units. This function converts between them.
  ///
  /// [text] is the full text content.
  /// [byteOffset] is the UTF-8 byte offset to convert.
  ///
  /// Returns the UTF-16 code unit offset in the string (for use with substring).
  ///
  /// Byte offsets represent positions BETWEEN bytes (0 = before first byte).
  ///
  /// Examples with 'aébc' (where 'é' is 2 bytes):
  /// - byteOffset 0 → char 0 (start of 'a')
  /// - byteOffset 1 → char 1 (after 'a', start of 'é')
  /// - byteOffset 2 → char 1 (within 'é', returns char 'é' is at)
  /// - byteOffset 3 → char 2 (after 'é', start of 'b')
  /// - byteOffset 4 → char 3 (after 'b', start of 'c')
  static int byteOffsetToCharOffset(String text, int byteOffset) {
    if (byteOffset <= 0) return 0;
    if (text.isEmpty) return 0;

    final bytes = utf8.encode(text);
    if (byteOffset >= bytes.length) return text.length;

    var codeUnitIndex = 0;
    var byteCount = 0;

    for (final rune in text.runes) {
      final charByteLength = rune <= 0x7F
          ? 1
          : rune <= 0x7FF
          ? 2
          : rune <= 0xFFFF
          ? 3
          : 4;

      if (byteOffset == byteCount) {
        return codeUnitIndex;
      }

      if (byteOffset > byteCount && byteOffset < byteCount + charByteLength) {
        return codeUnitIndex;
      }

      if (byteOffset == byteCount + charByteLength) {
        return codeUnitIndex + (rune >= 0x10000 ? 2 : 1);
      }

      byteCount += charByteLength;
      codeUnitIndex += (rune >= 0x10000 ? 2 : 1);
    }

    if (byteOffset == byteCount) {
      return codeUnitIndex;
    }

    return codeUnitIndex;
  }

  /// Parses facets JSON string into a list of Facet objects.
  ///
  /// [facetsJson] is the JSON string from the AT Protocol response.
  /// Can be null or empty for posts without facets.
  ///
  /// Returns a list of Facet objects, or an empty list if parsing fails
  /// or the input is null/empty.
  static List<Facet> parseFacets(String? facetsJson) {
    if (facetsJson == null || facetsJson.isEmpty) return [];

    try {
      final List<dynamic> facetList = jsonDecode(facetsJson) as List<dynamic>;
      return facetList.map((dynamic item) {
        final facetJson = item as Map<String, dynamic>;
        final indexJson = facetJson['index'] as Map<String, dynamic>;
        final index = FacetIndex(
          byteStart: indexJson['byteStart'] as int,
          byteEnd: indexJson['byteEnd'] as int,
        );

        final featuresJson = facetJson['features'] as List<dynamic>;
        final features = featuresJson.map((f) {
          final featureJson = f as Map<String, dynamic>;
          final featureType = featureJson[r'$type'] as String?;

          if (featureType == 'app.bsky.richtext.facet#mention') {
            return MentionFeature(did: featureJson['did'] as String);
          } else if (featureType == 'app.bsky.richtext.facet#link') {
            return LinkFeature(uri: featureJson['uri'] as String);
          } else if (featureType == 'app.bsky.richtext.facet#tag') {
            return HashtagFeature(tag: featureJson['tag'] as String);
          } else {
            throw ArgumentError('Unknown facet type: $featureType');
          }
        }).toList();

        return Facet(index: index, features: features);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Extracts the first mention feature from a facet.
  ///
  /// Returns null if the facet doesn't contain a mention feature.
  static MentionFeature? getMentionFeature(Facet facet) {
    for (final feature in facet.features) {
      if (feature is MentionFeature) return feature;
    }
    return null;
  }

  /// Extracts the first link feature from a facet.
  ///
  /// Returns null if the facet doesn't contain a link feature.
  static LinkFeature? getLinkFeature(Facet facet) {
    for (final feature in facet.features) {
      if (feature is LinkFeature) return feature;
    }
    return null;
  }

  /// Extracts the first hashtag feature from a facet.
  ///
  /// Returns null if the facet doesn't contain a hashtag feature.
  static HashtagFeature? getHashtagFeature(Facet facet) {
    for (final feature in facet.features) {
      if (feature is HashtagFeature) return feature;
    }
    return null;
  }

  /// Determines the primary feature type of a facet.
  ///
  /// Prioritizes mentions > links > hashtags when multiple features exist.
  static FacetType getFacetType(Facet facet) {
    if (getMentionFeature(facet) != null) return FacetType.mention;
    if (getLinkFeature(facet) != null) return FacetType.link;
    if (getHashtagFeature(facet) != null) return FacetType.hashtag;
    return FacetType.unknown;
  }
}

/// The type of a facet for display purposes.
enum FacetType {
  /// An @mention that links to a user profile.
  mention,

  /// A URL link that opens in a browser.
  link,

  /// A #hashtag that links to search results.
  hashtag,

  /// An unknown or unsupported facet type.
  unknown,
}
