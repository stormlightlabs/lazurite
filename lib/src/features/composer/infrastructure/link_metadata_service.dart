import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/composer/domain/link_metadata.dart';

/// Service for fetching and parsing URL metadata for link card previews.
///
/// Fetches HTML content and extracts Open Graph tags and fallback metadata
/// from standard HTML meta tags.
class LinkMetadataService {
  LinkMetadataService({required Dio dio, required Logger logger}) : _dio = dio, _logger = logger;

  final Dio _dio;
  final Logger _logger;

  /// Fetches metadata for a given URL.
  ///
  /// Returns null if the URL cannot be fetched or parsed.
  /// Caches results for performance (future enhancement).
  Future<LinkMetadata?> fetchMetadata(String url) async {
    try {
      final normalizedUrl = _normalizeUrl(url);
      if (normalizedUrl == null) {
        _logger.warning('Invalid URL: $url');
        return null;
      }

      final response = await _dio.get<String>(
        normalizedUrl,
        options: Options(
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (status) => status != null && status < 400,
          headers: {
            'User-Agent':
                'Mozilla/5.0 (compatible; Lazurite/1.0; +https://github.com/bluesky-social/lazurite)',
          },
        ),
      );

      if (response.data == null) {
        _logger.warning('Empty response for URL: $normalizedUrl');
        return null;
      }

      return _parseHtml(normalizedUrl, response.data!);
    } on DioException catch (e) {
      _logger.warning('Failed to fetch URL metadata: $url', e);
      return null;
    } catch (e, stack) {
      _logger.error('Unexpected error fetching URL metadata: $url', e, stack);
      return null;
    }
  }

  /// Normalizes a URL by adding protocol if missing and validating format.
  String? _normalizeUrl(String url) {
    var normalized = url.trim();
    if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }

    try {
      final uri = Uri.parse(normalized);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return null;
      }
      return normalized;
    } catch (e) {
      return null;
    }
  }

  /// Parses HTML content to extract metadata.
  ///
  /// Prioritizes Open Graph tags, falls back to standard HTML meta tags.
  LinkMetadata _parseHtml(String url, String html) {
    final document = html_parser.parse(html);

    String? getMetaContent(String property, {String attribute = 'property'}) {
      final element = document.querySelector('meta[$attribute="$property"]');
      return element?.attributes['content'];
    }

    final ogTitle = getMetaContent('og:title');
    final ogDescription = getMetaContent('og:description');
    final ogImage = getMetaContent('og:image');
    final ogSiteName = getMetaContent('og:site_name');

    final title =
        ogTitle ??
        getMetaContent('twitter:title', attribute: 'name') ??
        document.querySelector('title')?.text;

    final description =
        ogDescription ??
        getMetaContent('twitter:description', attribute: 'name') ??
        getMetaContent('description', attribute: 'name');

    final imageUrl = ogImage ?? getMetaContent('twitter:image', attribute: 'name');

    final siteName =
        ogSiteName ?? getMetaContent('twitter:site', attribute: 'name') ?? Uri.parse(url).host;

    return LinkMetadata(
      url: url,
      title: title?.trim(),
      description: description?.trim(),
      imageUrl: imageUrl?.trim(),
      siteName: siteName.trim(),
    );
  }
}
