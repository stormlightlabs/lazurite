import 'dart:convert';
import 'package:lazurite/core/theme/theme_extensions.dart';

import 'package:poptart_lex/app/bsky/richtext/facet.dart';
import 'package:poptart_bluesky_text/poptart_bluesky_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/router/in_app_link_resolver.dart';
import 'package:lazurite/features/search/data/hashtag_utils.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';
import 'package:url_launcher/url_launcher.dart';

class FacetText extends StatelessWidget {
  const FacetText({super.key, required this.text, this.facets, this.style, this.maxLines, this.overflow});

  final String text;
  final List<RichtextFacet>? facets;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(style: style, children: _buildTextSpans(context)),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }

  List<InlineSpan> _buildTextSpans(BuildContext context) {
    final bytes = utf8.encode(text);
    final segments = _segmentsFromFacets(bytes) ?? _segmentsFromEntities(bytes);

    if (segments.isEmpty) {
      return [TextSpan(text: text)];
    }

    final spans = <InlineSpan>[];
    var currentByteIndex = 0;

    for (final segment in segments) {
      final startByte = segment.start.clamp(0, bytes.length);
      final endByte = segment.end.clamp(startByte, bytes.length);

      if (startByte > currentByteIndex) {
        spans.add(TextSpan(text: _extractTextFromBytes(bytes, currentByteIndex, startByte)));
      }

      final segmentText = _extractTextFromBytes(bytes, startByte, endByte);
      spans.add(segment.toSpan(context, segmentText));
      currentByteIndex = endByte;
    }

    if (currentByteIndex < bytes.length) {
      spans.add(TextSpan(text: _extractTextFromBytes(bytes, currentByteIndex, bytes.length)));
    }

    return spans;
  }

  List<_TextSegment>? _segmentsFromFacets(List<int> bytes) {
    if (facets == null || facets!.isEmpty) {
      return null;
    }

    final sortedFacets = List<RichtextFacet>.from(facets!)
      ..sort((a, b) => a.index.byteStart.compareTo(b.index.byteStart));
    final segments = <_TextSegment>[];

    for (final facet in sortedFacets) {
      final segment = _segmentFromFacet(facet);
      if (segment == null) {
        continue;
      }

      if (facet.index.byteStart >= bytes.length) {
        continue;
      }

      segments.add(segment);
    }

    return segments;
  }

  List<_TextSegment> _segmentsFromEntities(List<int> bytes) {
    final entities = BlueskyText(text, enableMarkdown: false).entities.toList()
      ..sort((a, b) => a.indices.start.compareTo(b.indices.start));
    final segments = <_TextSegment>[];

    for (final entity in entities) {
      if (entity.indices.start >= bytes.length) {
        continue;
      }

      if (entity.type == EntityType.handle) {
        segments.add(_MentionSegment(entity.indices.start, entity.indices.end, entity.value.replaceFirst('@', '')));
        continue;
      }

      if (entity.type == EntityType.link) {
        segments.add(_LinkSegment(entity.indices.start, entity.indices.end, entity.value));
        continue;
      }

      if (entity.type == EntityType.tag) {
        segments.add(_TagSegment(entity.indices.start, entity.indices.end, entity.value.replaceFirst('#', '')));
      }
    }

    return segments;
  }

  _TextSegment? _segmentFromFacet(RichtextFacet facet) {
    for (final feature in facet.features) {
      if (feature.isRichtextFacetLink && feature.richtextFacetLink != null) {
        return _LinkSegment(facet.index.byteStart, facet.index.byteEnd, feature.richtextFacetLink!.uri);
      }

      if (feature.isRichtextFacetMention && feature.richtextFacetMention != null) {
        return _MentionSegment(facet.index.byteStart, facet.index.byteEnd, feature.richtextFacetMention!.did);
      }

      if (feature.isRichtextFacetTag && feature.richtextFacetTag != null) {
        return _TagSegment(facet.index.byteStart, facet.index.byteEnd, feature.richtextFacetTag!.tag);
      }
    }

    return null;
  }

  String _extractTextFromBytes(List<int> bytes, int start, int end) {
    return utf8.decode(bytes.sublist(start, end), allowMalformed: true);
  }
}

abstract class _TextSegment {
  const _TextSegment(this.start, this.end);

  final int start;
  final int end;

  TextSpan toSpan(BuildContext context, String text);

  TextStyle _linkStyle(BuildContext context) {
    return TextStyle(
      color: context.colorScheme.primary,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
    );
  }
}

final class _LinkSegment extends _TextSegment {
  const _LinkSegment(super.start, super.end, this.uri);

  final String uri;

  @override
  TextSpan toSpan(BuildContext context, String text) {
    return TextSpan(
      text: text,
      style: _linkStyle(context),
      recognizer: TapGestureRecognizer()..onTap = () => _openLink(context, uri),
    );
  }
}

final class _MentionSegment extends _TextSegment {
  const _MentionSegment(super.start, super.end, this.actor);

  final String actor;

  @override
  TextSpan toSpan(BuildContext context, String text) {
    return TextSpan(
      text: text,
      style: _linkStyle(context),
      recognizer: TapGestureRecognizer()..onTap = () => _openProfile(context, actor),
    );
  }
}

final class _TagSegment extends _TextSegment {
  const _TagSegment(super.start, super.end, this.tag);

  final String tag;

  @override
  TextSpan toSpan(BuildContext context, String text) {
    return TextSpan(
      text: text,
      style: _linkStyle(context),
      recognizer: TapGestureRecognizer()..onTap = () => _openHashtag(context, tag),
    );
  }
}

void _openProfile(BuildContext context, String actor) {
  navigateToProfile(context, actor);
}

void _openLink(BuildContext context, String rawLink) {
  final router = GoRouter.maybeOf(context);
  final inAppRoute = InAppLinkResolver.resolveRoute(rawLink);
  if (inAppRoute != null && router != null) {
    router.push(inAppRoute);
    return;
  }

  final uri = Uri.tryParse(rawLink);
  if (uri == null) {
    return;
  }

  _launchExternal(uri);
}

void _openHashtag(BuildContext context, String tag) {
  final normalizedTag = normalizeHashtag(tag);
  if (normalizedTag.isEmpty) {
    return;
  }

  final router = GoRouter.maybeOf(context);
  if (router == null) {
    return;
  }

  router.push('/hashtag?tag=${Uri.encodeQueryComponent(normalizedTag)}');
}

Future<void> _launchExternal(Uri url) async {
  await launchUrl(url, mode: LaunchMode.externalApplication);
}
