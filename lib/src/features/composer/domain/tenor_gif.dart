import 'package:equatable/equatable.dart';

/// Represents a GIF media object from Tenor API.
class TenorMedia with EquatableMixin {
  factory TenorMedia.fromJson(Map<String, dynamic> json) {
    return TenorMedia(
      previewUrl: json['preview'] as String? ?? '',
      url: json['url'] as String? ?? '',
      dims: TenorDimensions.fromJson(json['dims'] as Map<String, dynamic>? ?? {}),
      previewSize: json['preview_size'] as int?,
      size: json['size'] as int?,
    );
  }
  const TenorMedia({
    required this.previewUrl,
    required this.url,
    required this.dims,
    this.previewSize,
    this.size,
  });

  final String previewUrl;
  final String url;
  final TenorDimensions dims;
  final int? previewSize;
  final int? size;

  Map<String, dynamic> toJson() {
    return {
      'preview': previewUrl,
      'url': url,
      'dims': dims.toJson(),
      if (previewSize != null) 'preview_size': previewSize,
      if (size != null) 'size': size,
    };
  }

  @override
  List<Object?> get props => [previewUrl, url, dims, previewSize, size];
}

/// Represents dimensions of a Tenor GIF.
class TenorDimensions with EquatableMixin {
  factory TenorDimensions.fromJson(Map<String, dynamic> json) {
    return TenorDimensions(width: json['width'] as int? ?? 0, height: json['height'] as int? ?? 0);
  }
  const TenorDimensions({required this.width, required this.height});

  final int width;
  final int height;

  Map<String, dynamic> toJson() {
    return {'width': width, 'height': height};
  }

  @override
  List<Object?> get props => [width, height];
}

/// Represents a GIF result from Tenor API.
class TenorGif with EquatableMixin {
  factory TenorGif.fromJson(Map<String, dynamic> json) {
    final mediaFormats = <String, TenorMedia>{};
    final mediaFormatsJson = json['media_formats'];
    if (mediaFormatsJson != null && mediaFormatsJson is Map) {
      for (final entry in mediaFormatsJson.entries) {
        if (entry.key is String && entry.value is Map<String, dynamic>) {
          mediaFormats[entry.key as String] = TenorMedia.fromJson(
            entry.value as Map<String, dynamic>,
          );
        }
      }
    }

    return TenorGif(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      mediaFormats: mediaFormats,
      created: json['created'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['created'] as num).toInt() * 1000)
          : DateTime.now(),
      contentDescription: json['content_description'] as String?,
      url: json['url'] as String?,
      itemurl: json['itemurl'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      flags: (json['flags'] as List<dynamic>?)?.cast<String>(),
      hasaudio: json['hasaudio'] as bool?,
    );
  }
  const TenorGif({
    required this.id,
    required this.title,
    required this.mediaFormats,
    required this.created,
    this.contentDescription,
    this.url,
    this.itemurl,
    this.tags,
    this.flags,
    this.hasaudio,
  });

  final String id;
  final String title;
  final Map<String, TenorMedia> mediaFormats;
  final DateTime created;
  final String? contentDescription;
  final String? url;
  final String? itemurl;
  final List<String>? tags;
  final List<String>? flags;
  final bool? hasaudio;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'media_formats': mediaFormats.map((key, value) => MapEntry(key, value.toJson())),
      'created': created.millisecondsSinceEpoch ~/ 1000,
      if (contentDescription != null) 'content_description': contentDescription,
      if (url != null) 'url': url,
      if (itemurl != null) 'itemurl': itemurl,
      if (tags != null) 'tags': tags,
      if (flags != null) 'flags': flags,
      if (hasaudio != null) 'hasaudio': hasaudio,
    };
  }

  TenorMedia? get mediumGif => mediaFormats['mediumgif'];
  TenorMedia? get tinyGif => mediaFormats['tinygif'];
  TenorMedia? get gif => mediaFormats['gif'];

  String? get thumbnailUrl => tinyGif?.previewUrl ?? mediumGif?.previewUrl;

  String? get gifUrl => mediumGif?.url ?? gif?.url;

  @override
  List<Object?> get props => [
    id,
    title,
    mediaFormats,
    created,
    contentDescription,
    url,
    itemurl,
    tags,
    flags,
    hasaudio,
  ];
}

/// Represents search results from Tenor API.
class TenorSearchResponse with EquatableMixin {
  factory TenorSearchResponse.fromJson(Map<String, dynamic> json) {
    final results = <TenorGif>[];
    final resultsJson = json['results'] as List<dynamic>?;
    if (resultsJson != null) {
      for (final result in resultsJson) {
        if (result is Map<String, dynamic>) {
          results.add(TenorGif.fromJson(result));
        }
      }
    }

    return TenorSearchResponse(results: results, next: json['next'] as String?);
  }
  const TenorSearchResponse({required this.results, this.next});

  final List<TenorGif> results;
  final String? next;

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((gif) => gif.toJson()).toList(),
      if (next != null) 'next': next,
    };
  }

  @override
  List<Object?> get props => [results, next];
}
