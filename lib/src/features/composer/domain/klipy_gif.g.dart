// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'klipy_gif.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KlipyMediaFormat _$KlipyMediaFormatFromJson(Map<String, dynamic> json) => _KlipyMediaFormat(
  url: json['url'] as String? ?? '',
  width: (json['width'] as num?)?.toInt() ?? 0,
  height: (json['height'] as num?)?.toInt() ?? 0,
  size: (json['size'] as num?)?.toInt(),
);

Map<String, dynamic> _$KlipyMediaFormatToJson(_KlipyMediaFormat instance) => <String, dynamic>{
  'url': instance.url,
  'width': instance.width,
  'height': instance.height,
  'size': instance.size,
};

_KlipyFormatVariants _$KlipyFormatVariantsFromJson(
  Map<String, dynamic> json,
) => _KlipyFormatVariants(
  gif: json['gif'] == null ? null : KlipyMediaFormat.fromJson(json['gif'] as Map<String, dynamic>),
  webp: json['webp'] == null
      ? null
      : KlipyMediaFormat.fromJson(json['webp'] as Map<String, dynamic>),
  jpg: json['jpg'] == null ? null : KlipyMediaFormat.fromJson(json['jpg'] as Map<String, dynamic>),
  mp4: json['mp4'] == null ? null : KlipyMediaFormat.fromJson(json['mp4'] as Map<String, dynamic>),
  webm: json['webm'] == null
      ? null
      : KlipyMediaFormat.fromJson(json['webm'] as Map<String, dynamic>),
);

Map<String, dynamic> _$KlipyFormatVariantsToJson(_KlipyFormatVariants instance) =>
    <String, dynamic>{
      'gif': instance.gif,
      'webp': instance.webp,
      'jpg': instance.jpg,
      'mp4': instance.mp4,
      'webm': instance.webm,
    };

_KlipyFile _$KlipyFileFromJson(Map<String, dynamic> json) => _KlipyFile(
  hd: json['hd'] == null ? null : KlipyFormatVariants.fromJson(json['hd'] as Map<String, dynamic>),
  md: json['md'] == null ? null : KlipyFormatVariants.fromJson(json['md'] as Map<String, dynamic>),
  sm: json['sm'] == null ? null : KlipyFormatVariants.fromJson(json['sm'] as Map<String, dynamic>),
  xs: json['xs'] == null ? null : KlipyFormatVariants.fromJson(json['xs'] as Map<String, dynamic>),
);

Map<String, dynamic> _$KlipyFileToJson(_KlipyFile instance) => <String, dynamic>{
  'hd': instance.hd,
  'md': instance.md,
  'sm': instance.sm,
  'xs': instance.xs,
};

_KlipyGif _$KlipyGifFromJson(Map<String, dynamic> json) => _KlipyGif(
  id: (json['id'] as num?)?.toInt() ?? 0,
  slug: json['slug'] as String? ?? '',
  title: json['title'] as String? ?? '',
  file: json['file'] == null
      ? const KlipyFile()
      : KlipyFile.fromJson(json['file'] as Map<String, dynamic>),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  type: json['type'] as String?,
  blurPreview: json['blur_preview'] as String?,
);

Map<String, dynamic> _$KlipyGifToJson(_KlipyGif instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'title': instance.title,
  'file': instance.file,
  'tags': instance.tags,
  'type': instance.type,
  'blur_preview': instance.blurPreview,
};

_KlipySearchResponse _$KlipySearchResponseFromJson(Map<String, dynamic> json) =>
    _KlipySearchResponse(
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => KlipyGif.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 24,
      hasNext: json['has_next'] as bool? ?? false,
    );

Map<String, dynamic> _$KlipySearchResponseToJson(_KlipySearchResponse instance) =>
    <String, dynamic>{
      'results': instance.results,
      'current_page': instance.currentPage,
      'per_page': instance.perPage,
      'has_next': instance.hasNext,
    };
