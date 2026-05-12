import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lazurite/core/logging/app_logger.dart';

part 'draft_embed_payload.freezed.dart';

@Freezed(fromJson: false, toJson: false)
sealed class DraftEmbedPayload with _$DraftEmbedPayload {
  const DraftEmbedPayload._();

  const factory DraftEmbedPayload.images({
    @Default(<String>[]) List<String> paths,
    @Default(<String>[]) List<String> altTexts,
  }) = DraftImagesEmbedPayload;

  const factory DraftEmbedPayload.video({required String path, @Default('') String alt}) = DraftVideoEmbedPayload;

  static DraftEmbedPayload? tryDecode(String? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) {
        return null;
      }
      return fromJson(Map<String, dynamic>.from(decoded));
    } catch (error) {
      log.d('Failed to decode draft embed payload: $error');
      return null;
    }
  }

  static DraftEmbedPayload? fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'images':
        return DraftEmbedPayload.images(paths: _stringList(json['paths']), altTexts: _stringList(json['altTexts']));
      case 'video':
        final path = json['path'];
        if (path is! String || path.isEmpty) {
          return null;
        }
        return DraftEmbedPayload.video(path: path, alt: json['alt'] as String? ?? '');
      default:
        return null;
    }
  }

  static String encodeMediaPaths(Iterable<String> paths) => jsonEncode(paths.toList(growable: false));

  static List<String> decodeMediaPaths(String payload) {
    final decoded = jsonDecode(payload);
    if (decoded is! List) {
      throw FormatException('Expected draft media paths to be a JSON list.', payload);
    }
    return decoded.whereType<String>().toList(growable: false);
  }

  String encode() => jsonEncode(toJson());

  Map<String, Object?> toJson() {
    return switch (this) {
      DraftImagesEmbedPayload(:final paths, :final altTexts) => {
        'type': 'images',
        'paths': paths,
        'altTexts': altTexts,
      },
      DraftVideoEmbedPayload(:final path, :final alt) => {'type': 'video', 'path': path, 'alt': alt},
    };
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) {
      return const [];
    }
    return value.whereType<String>().toList(growable: false);
  }
}
