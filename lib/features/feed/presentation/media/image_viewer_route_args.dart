import 'package:lazurite/features/feed/presentation/media/media_route_payload_codec.dart';

/// Route arguments needed to open the full-screen image gallery.
///
/// These args are passed through `GoRouterState.extra` during normal in-app
/// taps, but they also know how to serialize themselves into the route URL so
/// `/images` can be restored after router refreshes or app process restoration.
class ImageViewerRouteArgs {
  const ImageViewerRouteArgs({required this.images, required this.initialIndex});

  final List<ImageViewerItem> images;
  final int initialIndex;

  /// Whether the route has at least one image and points at an existing item.
  bool get isValid => images.isNotEmpty && initialIndex >= 0 && initialIndex < images.length;

  /// Reconstructable route location for this image viewer state.
  String get location => MediaRoutePayloadCodec.location(
    path: '/images',
    payload: {
      'initialIndex': initialIndex,
      'images': [for (final image in images) image.toJson()],
    },
  );

  /// Parses args from transient router [extra], falling back to [uri].
  static ImageViewerRouteArgs? tryParse(Object? extra, Uri uri) {
    return tryParseExtra(extra) ?? tryParseUri(uri);
  }

  /// Parses the in-memory route args supplied by an in-app image tap.
  static ImageViewerRouteArgs? tryParseExtra(Object? extra) {
    if (extra is! ImageViewerRouteArgs || !extra.isValid) {
      return null;
    }
    return extra;
  }

  /// Parses route args encoded into `/images?payload=...`.
  static ImageViewerRouteArgs? tryParseUri(Uri uri) {
    final decoded = MediaRoutePayloadCodec.tryDecode(uri);
    if (decoded == null) {
      return null;
    }

    final initialIndex = decoded['initialIndex'];
    final imagesJson = decoded['images'];
    if (initialIndex is! int || imagesJson is! List) {
      return null;
    }

    final images = <ImageViewerItem>[];
    for (final imageJson in imagesJson) {
      final image = ImageViewerItem.tryParseJson(imageJson);
      if (image == null) {
        return null;
      }
      images.add(image);
    }

    final args = ImageViewerRouteArgs(images: images, initialIndex: initialIndex);
    return args.isValid ? args : null;
  }
}

/// A single image entry in the full-screen gallery.
///
/// The viewer keeps both full-size and thumbnail URLs such that the full-size
/// URL is shown/downloaded, while the thumbnail URL preserves enough source
/// metadata for route restoration and future viewer UI changes.
class ImageViewerItem {
  const ImageViewerItem({required this.fullsizeUrl, required this.thumbnailUrl, required this.heroTag, this.altText});

  final String fullsizeUrl;
  final String thumbnailUrl;
  final String heroTag;
  final String? altText;

  /// Encodes this item into the image viewer route payload.
  Map<String, Object?> toJson() => {
    'fullsizeUrl': fullsizeUrl,
    'thumbnailUrl': thumbnailUrl,
    'heroTag': heroTag,
    if (altText != null) 'altText': altText,
  };

  /// Parses an image item from a route payload object.
  static ImageViewerItem? tryParseJson(Object? json) {
    if (json is! Map<String, Object?>) {
      return null;
    }

    final fullsizeUrl = json['fullsizeUrl'];
    final thumbnailUrl = json['thumbnailUrl'];
    final heroTag = json['heroTag'];
    final altText = json['altText'];
    if (fullsizeUrl is! String || thumbnailUrl is! String || heroTag is! String) {
      return null;
    }
    if (fullsizeUrl.isEmpty || thumbnailUrl.isEmpty || heroTag.isEmpty) {
      return null;
    }
    String? parsedAltText;
    if (altText is String) {
      parsedAltText = altText;
    } else if (altText != null) {
      return null;
    }

    return ImageViewerItem(
      fullsizeUrl: fullsizeUrl,
      thumbnailUrl: thumbnailUrl,
      heroTag: heroTag,
      altText: parsedAltText,
    );
  }
}
