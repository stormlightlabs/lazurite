import 'package:lazurite/features/feed/presentation/media/media_route_payload_codec.dart';

/// Route arguments needed to open the full-screen video player.
///
/// The route receives these args through `GoRouterState.extra` for normal
/// in-app navigation and encodes the same state into `/video?payload=...` so the
/// player can be restored if `extra` is unavailable.
class VideoPlayerRouteArgs {
  const VideoPlayerRouteArgs({
    required this.playlistUrl,
    this.downloadUrl,
    this.thumbnailUrl,
    this.altText,
    this.aspectRatio,
    this.isGif = false,
  });

  final String playlistUrl;
  final String? downloadUrl;
  final String? thumbnailUrl;
  final String? altText;
  final double? aspectRatio;
  final bool isGif;

  /// Whether the route has a playable source URL.
  bool get isValid => playlistUrl.isNotEmpty;

  /// Reconstructable route location for this video player state.
  String get location => MediaRoutePayloadCodec.location(path: '/video', payload: toJson());

  /// Encodes this video into the route payload.
  Map<String, Object?> toJson() => {
    'playlistUrl': playlistUrl,
    if (downloadUrl != null) 'downloadUrl': downloadUrl,
    if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    if (altText != null) 'altText': altText,
    if (aspectRatio != null) 'aspectRatio': aspectRatio,
    'isGif': isGif,
  };

  /// Parses args from transient router [extra], falling back to [uri].
  static VideoPlayerRouteArgs? tryParse(Object? extra, Uri uri) {
    return tryParseExtra(extra) ?? tryParseUri(uri);
  }

  /// Parses the in-memory route args supplied by an in-app video tap.
  static VideoPlayerRouteArgs? tryParseExtra(Object? extra) {
    if (extra is! VideoPlayerRouteArgs || !extra.isValid) {
      return null;
    }
    return extra;
  }

  /// Parses route args encoded into `/video?payload=...`.
  static VideoPlayerRouteArgs? tryParseUri(Uri uri) {
    final decoded = MediaRoutePayloadCodec.tryDecode(uri);
    if (decoded == null) {
      return null;
    }
    return tryParseJson(decoded);
  }

  /// Parses a video route payload object.
  static VideoPlayerRouteArgs? tryParseJson(Map<String, Object?> json) {
    final playlistUrl = json['playlistUrl'];
    final downloadUrl = json['downloadUrl'];
    final thumbnailUrl = json['thumbnailUrl'];
    final altText = json['altText'];
    final aspectRatio = json['aspectRatio'];
    final isGif = json['isGif'];

    if (playlistUrl is! String || playlistUrl.isEmpty) {
      return null;
    }
    if (downloadUrl != null && downloadUrl is! String) {
      return null;
    }
    if (thumbnailUrl != null && thumbnailUrl is! String) {
      return null;
    }
    if (altText != null && altText is! String) {
      return null;
    }
    final double? parsedAspectRatio;
    if (aspectRatio is num) {
      parsedAspectRatio = aspectRatio.toDouble();
    } else if (aspectRatio == null) {
      parsedAspectRatio = null;
    } else {
      return null;
    }
    if (isGif != null && isGif is! bool) {
      return null;
    }

    return VideoPlayerRouteArgs(
      playlistUrl: playlistUrl,
      downloadUrl: downloadUrl as String?,
      thumbnailUrl: thumbnailUrl as String?,
      altText: altText as String?,
      aspectRatio: parsedAspectRatio,
      isGif: isGif as bool? ?? false,
    );
  }
}
