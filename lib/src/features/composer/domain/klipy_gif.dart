import 'package:freezed_annotation/freezed_annotation.dart';

part 'klipy_gif.freezed.dart';
part 'klipy_gif.g.dart';

/// Represents a media format from Klipy API (url, dimensions, size).
@freezed
abstract class KlipyMediaFormat with _$KlipyMediaFormat {
  const factory KlipyMediaFormat({
    @Default('') String url,
    @Default(0) int width,
    @Default(0) int height,
    int? size,
  }) = _KlipyMediaFormat;

  factory KlipyMediaFormat.fromJson(Map<String, dynamic> json) => _$KlipyMediaFormatFromJson(json);
}

/// Represents all format variants for a single size (gif, webp, jpg, mp4, webm).
@freezed
abstract class KlipyFormatVariants with _$KlipyFormatVariants {
  const factory KlipyFormatVariants({
    KlipyMediaFormat? gif,
    KlipyMediaFormat? webp,
    KlipyMediaFormat? jpg,
    KlipyMediaFormat? mp4,
    KlipyMediaFormat? webm,
  }) = _KlipyFormatVariants;

  factory KlipyFormatVariants.fromJson(Map<String, dynamic> json) =>
      _$KlipyFormatVariantsFromJson(json);
}

/// Represents all size variants for a GIF (hd, md, sm, xs).
@freezed
abstract class KlipyFile with _$KlipyFile {
  const factory KlipyFile({
    KlipyFormatVariants? hd,
    KlipyFormatVariants? md,
    KlipyFormatVariants? sm,
    KlipyFormatVariants? xs,
  }) = _KlipyFile;

  factory KlipyFile.fromJson(Map<String, dynamic> json) => _$KlipyFileFromJson(json);
}

/// Represents a GIF result from Klipy API.
@freezed
abstract class KlipyGif with _$KlipyGif {
  const factory KlipyGif({
    @Default(0) int id,
    @Default('') String slug,
    @Default('') String title,
    @Default(KlipyFile()) KlipyFile file,
    List<String>? tags,
    String? type,
    @JsonKey(name: 'blur_preview') String? blurPreview,
  }) = _KlipyGif;

  const KlipyGif._();

  factory KlipyGif.fromJson(Map<String, dynamic> json) => _$KlipyGifFromJson(json);

  /// URL for the thumbnail (small webp preferred, falls back to gif).
  String? get thumbnailUrl {
    return file.sm?.webp?.url ?? file.sm?.gif?.url ?? file.xs?.webp?.url ?? file.xs?.gif?.url;
  }

  /// URL for the full GIF (medium size preferred).
  String? get gifUrl {
    return file.md?.gif?.url ?? file.hd?.gif?.url ?? file.sm?.gif?.url;
  }

  /// URL to attribute/link back to Klipy.
  String get itemUrl => 'https://klipy.com/gif/$slug';
}

/// Represents search results from Klipy API.
@freezed
abstract class KlipySearchResponse with _$KlipySearchResponse {
  const factory KlipySearchResponse({
    @Default([]) List<KlipyGif> results,
    @JsonKey(name: 'current_page') @Default(1) int currentPage,
    @JsonKey(name: 'per_page') @Default(24) int perPage,
    @JsonKey(name: 'has_next') @Default(false) bool hasNext,
  }) = _KlipySearchResponse;

  const KlipySearchResponse._();

  factory KlipySearchResponse.fromJson(Map<String, dynamic> json) =>
      _$KlipySearchResponseFromJson(json);

  /// Creates a [KlipySearchResponse] from the raw Klipy API response which
  /// wraps the pagination data in a 'data' field.
  factory KlipySearchResponse.fromApiResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    if (data != null) {
      return KlipySearchResponse.fromJson({...data, 'results': data['data']});
    }

    return KlipySearchResponse.fromJson(json);
  }

  /// Next page number if there are more results.
  int? get nextPage => hasNext ? currentPage + 1 : null;
}
