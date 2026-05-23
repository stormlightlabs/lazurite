import 'package:lazurite/features/feed/presentation/media/media_route_payload_codec.dart';

class ImageViewerRouteArgs {
  const ImageViewerRouteArgs({required this.images, required this.initialIndex});

  final List<ImageViewerItem> images;
  final int initialIndex;

  bool get isValid => images.isNotEmpty && initialIndex >= 0 && initialIndex < images.length;

  String get location => MediaRoutePayloadCodec.location(
    path: '/images',
    payload: {
      'initialIndex': initialIndex,
      'images': [for (final image in images) image.toJson()],
    },
  );

  static ImageViewerRouteArgs? tryParse(Object? extra, Uri uri) {
    return tryParseExtra(extra) ?? tryParseUri(uri);
  }

  static ImageViewerRouteArgs? tryParseExtra(Object? extra) {
    if (extra is! ImageViewerRouteArgs || !extra.isValid) {
      return null;
    }
    return extra;
  }

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

class ImageViewerItem {
  const ImageViewerItem({required this.fullsizeUrl, required this.thumbnailUrl, required this.heroTag, this.altText});

  final String fullsizeUrl;
  final String thumbnailUrl;
  final String heroTag;
  final String? altText;

  Map<String, Object?> toJson() => {
    'fullsizeUrl': fullsizeUrl,
    'thumbnailUrl': thumbnailUrl,
    'heroTag': heroTag,
    if (altText != null) 'altText': altText,
  };

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
