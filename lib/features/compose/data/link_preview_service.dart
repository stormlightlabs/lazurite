import 'dart:convert';
import 'dart:io';

import 'package:bluesky_text/bluesky_text.dart';
import 'package:http/http.dart' as http;

class LinkPreviewData {
  const LinkPreviewData({required this.uri, required this.title, required this.description, this.thumbnailUrl});

  final String uri;
  final String title;
  final String description;
  final String? thumbnailUrl;

  Map<String, dynamic> toExternalEmbedJson() {
    return {
      r'$type': 'app.bsky.embed.external',
      'external': {'uri': uri, 'title': title, 'description': description},
    };
  }
}

class LinkPreviewService {
  LinkPreviewService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static String? firstLink(String text) {
    final entities = BlueskyText(text, enableMarkdown: false).entities;
    for (final entity in entities) {
      if (!entity.isLink) {
        continue;
      }
      final parsed = _normalizeUri(entity.value);
      if (parsed != null) {
        return parsed.toString();
      }
    }
    return null;
  }

  Future<LinkPreviewData?> fetch(String rawUrl) async {
    final uri = _normalizeUri(rawUrl);
    if (uri == null) {
      return null;
    }

    final response = await _httpClient
        .get(
          uri,
          headers: const {
            'User-Agent':
                'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko)',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
          },
        )
        .timeout(const Duration(seconds: 4));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Link preview request failed (${response.statusCode})', uri: uri);
    }

    final html = _decodeHtml(response.bodyBytes);
    final title =
        _readMetaContent(html, 'property', 'og:title') ??
        _readMetaContent(html, 'name', 'twitter:title') ??
        _readHtmlTag(html, 'title') ??
        ExternalLinkHost.host(uri.toString());
    final description =
        _readMetaContent(html, 'property', 'og:description') ??
        _readMetaContent(html, 'name', 'description') ??
        _readMetaContent(html, 'name', 'twitter:description') ??
        '';
    final image = _readMetaContent(html, 'property', 'og:image') ?? _readMetaContent(html, 'name', 'twitter:image');

    return LinkPreviewData(
      uri: uri.toString(),
      title: _truncate(title, 300),
      description: _truncate(description, 1000),
      thumbnailUrl: _normalizeImageUrl(image, base: uri),
    );
  }

  Future<({List<int> bytes, String mimeType})?> fetchThumbnail(String rawUrl) async {
    final uri = _normalizeUri(rawUrl);
    if (uri == null) {
      return null;
    }

    final response = await _httpClient
        .get(
          uri,
          headers: const {
            'User-Agent':
                'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko)',
            'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
          },
        )
        .timeout(const Duration(seconds: 4));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final mime = _normalizeMimeType(response.headers['content-type']);
    if (mime == null || !mime.startsWith('image/')) {
      return null;
    }

    final bytes = response.bodyBytes;
    const maxThumbBytes = 1 * 1024 * 1024;
    if (bytes.isEmpty || bytes.length > maxThumbBytes) {
      return null;
    }

    return (bytes: bytes, mimeType: mime);
  }

  static String _decodeHtml(List<int> bodyBytes) {
    try {
      return utf8.decode(bodyBytes, allowMalformed: true);
    } catch (_) {
      return latin1.decode(bodyBytes, allowInvalid: true);
    }
  }

  static Uri? _normalizeUri(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final parsed = Uri.tryParse(trimmed);
    if (parsed != null && parsed.hasScheme) {
      if ((parsed.scheme == 'http' || parsed.scheme == 'https') && parsed.host.isNotEmpty) {
        return parsed;
      }
      return null;
    }

    final withScheme = Uri.tryParse('https://$trimmed');
    if (withScheme != null && withScheme.host.isNotEmpty) {
      return withScheme;
    }

    return null;
  }

  static String? _readMetaContent(String html, String keyAttr, String keyValue) {
    final normalizedKey = RegExp.escape(keyValue);
    final regex = RegExp(
      '<meta\\s+[^>]*$keyAttr\\s*=\\s*["\']$normalizedKey["\'][^>]*content\\s*=\\s*["\']([^"\']*)["\'][^>]*>',
      caseSensitive: false,
      dotAll: true,
    );
    final match = regex.firstMatch(html);
    return match == null ? null : _collapseWhitespace(_decodeHtmlEntities(match.group(1)!));
  }

  static String? _readHtmlTag(String html, String tag) {
    final regex = RegExp('<$tag[^>]*>(.*?)</$tag>', caseSensitive: false, dotAll: true);
    final match = regex.firstMatch(html);
    return match == null ? null : _collapseWhitespace(_decodeHtmlEntities(match.group(1)!));
  }

  static String _decodeHtmlEntities(String input) {
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  static String _collapseWhitespace(String input) {
    return input.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _truncate(String text, int maxChars) {
    if (text.length <= maxChars) {
      return text;
    }
    return text.substring(0, maxChars).trimRight();
  }

  static String? _normalizeImageUrl(String? rawImageUrl, {required Uri base}) {
    if (rawImageUrl == null || rawImageUrl.trim().isEmpty) {
      return null;
    }

    final trimmed = rawImageUrl.trim();
    final parsed = Uri.tryParse(trimmed);
    if (parsed == null) {
      return null;
    }
    if (parsed.hasScheme) {
      return parsed.toString();
    }
    return base.resolveUri(parsed).toString();
  }

  static String? _normalizeMimeType(String? rawContentType) {
    if (rawContentType == null || rawContentType.trim().isEmpty) {
      return null;
    }
    final normalized = rawContentType.split(';').first.trim().toLowerCase();
    return normalized.isEmpty ? null : normalized;
  }
}

class ExternalLinkHost {
  static String host(String rawUri) {
    final uri = Uri.tryParse(rawUri);
    final host = uri?.host.trim();
    if (host == null || host.isEmpty) {
      return rawUri;
    }
    return host;
  }
}
