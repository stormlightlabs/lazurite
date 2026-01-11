import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lazurite/src/core/widgets/facet/facet_helper.dart';
import 'package:lazurite/src/features/composer/domain/facet_parser.dart';

/// A widget that displays text with rich text facets.
///
/// Facets are rich text features in Bluesky posts, including:
/// - Mentions (@handle) - link to user profiles
/// - Links (URLs) - open in browser
/// - Hashtags (#tag) - search for tag
///
/// This widget handles UTF-8 byte offset conversion, styling, and tap handlers.
///
/// Example:
/// ```dart
/// FacetText(
///   text: 'Hello @alice.bsky.social!',
///   facets: [
///     Facet(
///       index: FacetIndex(byteStart: 6, byteEnd: 24),
///       features: [MentionFeature(did: 'did:plc:alice')],
///     ),
///   ],
///   onMentionTap: (did) => navigateToProfile(did),
/// )
/// ```
class FacetText extends StatelessWidget {
  /// Creates a FacetText widget.
  ///
  /// [text] is the raw post text content.
  /// [facets] is the list of facets from the AT Protocol JSON.
  /// [onMentionTap] is called when a mention is tapped, receiving the DID.
  /// [onLinkTap] is called when a link is tapped, receiving the URI.
  /// [onHashtagTap] is called when a hashtag is tapped, receiving the tag.
  /// [style] is the base text style for plain text.
  /// [maxLines] limits the number of lines displayed.
  /// [overflow] controls how text overflow is handled.
  /// [textAlign] aligns the text.
  const FacetText({
    required this.text,
    this.facets = const [],
    this.onMentionTap,
    this.onLinkTap,
    this.onHashtagTap,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textAlign,
    super.key,
  });

  /// The text content to display.
  final String text;

  /// The facets to apply to the text.
  final List<Facet> facets;

  /// Called when a mention is tapped.
  ///
  /// Receives the DID of the mentioned user.
  final ValueChanged<String>? onMentionTap;

  /// Called when a link is tapped.
  ///
  /// Receives the URI of the link.
  final ValueChanged<String>? onLinkTap;

  /// Called when a hashtag is tapped.
  ///
  /// Receives the hashtag without the # symbol.
  final ValueChanged<String>? onHashtagTap;

  /// The base text style.
  final TextStyle? style;

  /// Maximum number of lines to display.
  final int? maxLines;

  /// How to handle text overflow.
  final TextOverflow overflow;

  /// How to align the text.
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final textSpan = _buildTextSpan(context);

    return Text.rich(textSpan, maxLines: maxLines, overflow: overflow, textAlign: textAlign);
  }

  TextSpan _buildTextSpan(BuildContext context) {
    if (facets.isEmpty) {
      return TextSpan(text: text, style: style);
    }

    final sortedFacets = List<Facet>.from(facets);
    sortedFacets.sort((a, b) => a.index.byteStart.compareTo(b.index.byteStart));

    final theme = Theme.of(context);
    final spans = <TextSpan>[];
    var lastEnd = 0;

    for (final facet in sortedFacets) {
      final start = FacetHelper.byteOffsetToCharOffset(text, facet.index.byteStart);
      final end = FacetHelper.byteOffsetToCharOffset(text, facet.index.byteEnd);

      if (start >= text.length || end > text.length || start >= end) {
        continue;
      }

      if (start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, start), style: style));
      }

      final facetText = text.substring(start, end);
      final type = FacetHelper.getFacetType(facet);

      final facetSpan = switch (type) {
        FacetType.mention => _buildMentionSpan(facet, facetText, theme),
        FacetType.link => _buildLinkSpan(facet, facetText, theme),
        FacetType.hashtag => _buildHashtagSpan(facet, facetText, theme),
        FacetType.unknown => null,
      };

      if (facetSpan != null) {
        spans.add(facetSpan);
      } else {
        spans.add(TextSpan(text: facetText, style: style));
      }

      lastEnd = end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: style));
    }

    return TextSpan(children: spans);
  }

  TextSpan _buildMentionSpan(Facet facet, String facetText, ThemeData theme) {
    final mention = FacetHelper.getMentionFeature(facet);
    return TextSpan(
      text: facetText,
      style: (style ?? theme.textTheme.bodyLarge)?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
      recognizer: onMentionTap != null && mention != null
          ? (TapGestureRecognizer()..onTap = () => onMentionTap!(mention.did))
          : null,
      semanticsLabel: 'Mention: $facetText',
    );
  }

  TextSpan _buildLinkSpan(Facet facet, String facetText, ThemeData theme) {
    final link = FacetHelper.getLinkFeature(facet);
    return TextSpan(
      text: facetText,
      style: (style ?? theme.textTheme.bodyLarge)?.copyWith(
        color: theme.colorScheme.primary,
        decoration: TextDecoration.underline,
      ),
      recognizer: onLinkTap != null && link != null
          ? (TapGestureRecognizer()..onTap = () => onLinkTap!(link.uri))
          : null,
      semanticsLabel: 'Link: $facetText',
    );
  }

  TextSpan _buildHashtagSpan(Facet facet, String facetText, ThemeData theme) {
    final hashtag = FacetHelper.getHashtagFeature(facet);
    return TextSpan(
      text: facetText,
      style: (style ?? theme.textTheme.bodyLarge)?.copyWith(color: theme.colorScheme.secondary),
      recognizer: onHashtagTap != null && hashtag != null
          ? (TapGestureRecognizer()..onTap = () => onHashtagTap!(hashtag.tag))
          : null,
      semanticsLabel: 'Hashtag: $facetText',
    );
  }
}
