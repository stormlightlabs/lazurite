import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/routes.dart';
import 'package:lazurite/src/core/widgets/facet/facet_helper.dart';
import 'package:lazurite/src/core/widgets/facet/facet_text.dart';
import 'package:lazurite/src/features/composer/domain/facet_parser.dart';
import 'package:url_launcher/url_launcher.dart';

/// Displays the body text of a Bluesky post with rich text facet support.
///
/// This widget handles rendering post text with mentions, links, and hashtags.
/// It falls back to plain text for posts without facets or when facet parsing fails.
///
/// Example:
/// ```dart
/// PostBody.withFacets(
///   text: 'Hello @alice.bsky.social!',
///   facets: [
///     {
///       'index': {'byteStart': 6, 'byteEnd': 24},
///       'features': [
///         {'$type': 'app.bsky.richtext.facet#mention', 'did': 'did:plc:alice'}
///       ]
///     }
///   ],
/// )
/// ```
class PostBody extends StatelessWidget {
  /// Creates a PostBody from facets data.
  ///
  /// This factory handles conversion from the raw facets list to JSON string.
  /// Use this when consuming API responses that provide facets as `List<dynamic>`.
  factory PostBody.withFacets({required String text, List<dynamic>? facets, Key? key}) {
    return PostBody(text: text, facetsJson: facets != null ? jsonEncode(facets) : null, key: key);
  }

  /// Creates a PostBody directly with pre-encoded facets JSON.
  ///
  /// Use this when facets are already stored as JSON strings.
  const PostBody({required this.text, this.facetsJson, super.key});

  /// The post text content.
  final String text;

  /// The facets as a JSON string (from AT Protocol API).
  final String? facetsJson;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final facets = facetsJson != null ? FacetHelper.parseFacets(facetsJson) : <Facet>[];

    if (facets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: FacetText(
        text: text,
        facets: facets,
        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
        onMentionTap: (did) => _handleMentionTap(context, did),
        onLinkTap: (uri) => _handleLinkTap(context, uri),
        onHashtagTap: (tag) => _handleHashtagTap(context, tag),
      ),
    );
  }

  /// Navigates to the profile screen when a mention is tapped.
  void _handleMentionTap(BuildContext context, String did) {
    context.go('/home/u/$did');
  }

  /// Opens the link in an external browser when tapped.
  void _handleLinkTap(BuildContext context, String uri) async {
    final linkUri = Uri.tryParse(uri);
    if (linkUri != null && await canLaunchUrl(linkUri)) {
      await launchUrl(linkUri, mode: LaunchMode.externalApplication);
    }
  }

  /// Navigates to the search screen with the hashtag query when tapped.
  void _handleHashtagTap(BuildContext context, String tag) {
    context.go('${AppRoutes.search}?q=%23$tag');
  }
}
