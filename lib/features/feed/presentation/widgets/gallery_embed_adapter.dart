import 'package:bluesky_poptart/app/bsky/embed/defs.dart' as embed_defs;
import 'package:bluesky_poptart/app/bsky/embed/images.dart';

List<EmbedImagesViewImage> galleryImagesFromUnknownEmbed(Map<String, dynamic>? json) {
  if (json == null || json[r'$type'] != 'app.bsky.embed.gallery#view') {
    return const [];
  }

  final rawItems = json['items'];
  if (rawItems is! List) {
    return const [];
  }

  final images = <EmbedImagesViewImage>[];
  for (final item in rawItems) {
    if (item is! Map) continue;
    final image = _galleryImageFromJson(Map<String, dynamic>.from(item));
    if (image != null) images.add(image);
  }
  return images;
}

EmbedImagesViewImage? _galleryImageFromJson(Map<String, dynamic> json) {
  final thumbnail = json['thumbnail'];
  final fullsize = json['fullsize'];
  final alt = json['alt'];
  if (thumbnail is! String || fullsize is! String || alt is! String) {
    return null;
  }

  return EmbedImagesViewImage(
    $type: 'app.bsky.embed.gallery#viewImage',
    thumb: thumbnail,
    fullsize: fullsize,
    alt: alt,
    aspectRatio: _aspectRatioFromJson(json['aspectRatio']),
  );
}

embed_defs.AspectRatio? _aspectRatioFromJson(Object? value) {
  if (value is! Map) return null;
  final json = Map<String, dynamic>.from(value);
  final width = json['width'];
  final height = json['height'];
  if (width is! int || height is! int) return null;
  return embed_defs.AspectRatio(width: width, height: height);
}
