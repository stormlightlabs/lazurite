class VideoPlayerRouteArgs {
  const VideoPlayerRouteArgs({
    required this.playlistUrl,
    this.thumbnailUrl,
    this.altText,
    this.aspectRatio,
    this.isGif = false,
  });

  final String playlistUrl;
  final String? thumbnailUrl;
  final String? altText;
  final double? aspectRatio;
  final bool isGif;
}
