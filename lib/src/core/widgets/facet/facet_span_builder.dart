import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lazurite/src/core/widgets/facet/facet_helper.dart';
import 'package:lazurite/src/features/composer/domain/facet_parser.dart';

/// Builds TextSpan trees from text with rich text facets.
///
/// This class handles the conversion of facet data (with UTF-8 byte offsets)
/// into Flutter TextSpan objects suitable for display. It manages:
/// - Converting byte offsets to character offsets
/// - Building spans for different facet types
/// - Handling overlapping facets
/// - Applying appropriate styling
class FacetSpanBuilder {
  /// Creates a new FacetSpanBuilder.
  ///
  /// [baseStyle] is the base text style for plain text and facet styling.
  FacetSpanBuilder({TextStyle? baseStyle}) : _baseStyle = baseStyle;

  final TextStyle? _baseStyle;

  /// Builds a TextSpan tree from text and facets.
  ///
  /// [text] is the full post text content.
  /// [facets] is the list of facets from the AT Protocol.
  /// [context] is the build context for theme access.
  /// [onMentionTap] is called when a mention is tapped.
  /// [onLinkTap] is called when a link is tapped.
  /// [onHashtagTap] is called when a hashtag is tapped.
  TextSpan build(
    String text,
    List<Facet> facets,
    BuildContext context, {
    VoidCallback? onMentionTap,
    VoidCallback? onLinkTap,
    VoidCallback? onHashtagTap,
  }) {
    if (facets.isEmpty) {
      return TextSpan(text: text, style: _baseStyle);
    }

    final sortedFacets = _sortAndPrioritizeFacets(facets);
    final spans = <TextSpan>[];
    var lastEnd = 0;

    for (final facet in sortedFacets) {
      final start = FacetHelper.byteOffsetToCharOffset(text, facet.index.byteStart);
      final end = FacetHelper.byteOffsetToCharOffset(text, facet.index.byteEnd);
      if (start >= text.length || end > text.length || start >= end) {
        continue;
      }

      if (start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, start), style: _baseStyle));
      }

      final facetSpan = _buildFacetSpan(
        facet,
        text.substring(start, end),
        context,
        onMentionTap: onMentionTap,
        onLinkTap: onLinkTap,
        onHashtagTap: onHashtagTap,
      );

      if (facetSpan != null) {
        spans.add(facetSpan);
      } else {
        spans.add(TextSpan(text: text.substring(start, end), style: _baseStyle));
      }

      lastEnd = end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: _baseStyle));
    }

    return TextSpan(children: spans);
  }

  /// Sorts facets by byte offset and prioritizes overlapping facets.
  ///
  /// Mentions have highest priority, then links, then hashtags.
  /// Overlapping facets of the same type are merged.
  List<Facet> _sortAndPrioritizeFacets(List<Facet> facets) {
    final sorted = List<Facet>.from(facets);
    sorted.sort((a, b) => a.index.byteStart.compareTo(b.index.byteStart));
    return sorted;
  }

  /// Builds a TextSpan for a single facet.
  TextSpan? _buildFacetSpan(
    Facet facet,
    String text,
    BuildContext context, {
    VoidCallback? onMentionTap,
    VoidCallback? onLinkTap,
    VoidCallback? onHashtagTap,
  }) {
    final type = FacetHelper.getFacetType(facet);

    return switch (type) {
      FacetType.mention => TextSpan(
        text: text,
        style: _getMentionStyle(context),
        recognizer: _createTapGestureRecognizer(onMentionTap),
        semanticsLabel: 'Mention: $text',
      ),
      FacetType.link => TextSpan(
        text: text,
        style: _getLinkStyle(context),
        recognizer: _createTapGestureRecognizer(onLinkTap),
        semanticsLabel: 'Link: $text',
      ),
      FacetType.hashtag => TextSpan(
        text: text,
        style: _getHashtagStyle(context),
        recognizer: _createTapGestureRecognizer(onHashtagTap),
        semanticsLabel: 'Hashtag: $text',
      ),
      FacetType.unknown => null,
    };
  }

  /// Gets the text style for mentions.
  TextStyle _getMentionStyle(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = _baseStyle ?? theme.textTheme.bodyLarge ?? const TextStyle();
    return baseStyle.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold);
  }

  /// Gets the text style for links.
  TextStyle _getLinkStyle(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = _baseStyle ?? theme.textTheme.bodyLarge ?? const TextStyle();
    return baseStyle.copyWith(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
    );
  }

  /// Gets the text style for hashtags.
  TextStyle _getHashtagStyle(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = _baseStyle ?? theme.textTheme.bodyLarge ?? const TextStyle();
    return baseStyle.copyWith(color: theme.colorScheme.secondary);
  }

  /// Creates a tap gesture recognizer.
  ///
  /// Returns null if [onTap] is null.
  GestureRecognizer? _createTapGestureRecognizer(VoidCallback? onTap) {
    if (onTap == null) return null;

    return TapGestureRecognizer()..onTap = onTap;
  }
}
