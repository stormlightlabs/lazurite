/// Metadata extracted from a URL for link card previews.
///
/// Contains Open Graph tags and fallback data from HTML head tags.
class LinkMetadata {
  LinkMetadata({required this.url, this.title, this.description, this.imageUrl, this.siteName});

  /// The original URL that was fetched.
  final String url;

  /// Page title from og:title or <title> tag.
  final String? title;

  /// Page description from og:description or meta description.
  final String? description;

  /// Preview image URL from og:image.
  final String? imageUrl;

  /// Site name from og:site_name.
  final String? siteName;

  /// Whether this metadata has any useful information.
  bool get hasContent => title != null || description != null || imageUrl != null;

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (siteName != null) 'siteName': siteName,
    };
  }
}
