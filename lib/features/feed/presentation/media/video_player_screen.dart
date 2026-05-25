import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:lazurite/core/cache/lazurite_image_cache.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/feed/presentation/media/media_actions.dart';
import 'package:lazurite/features/feed/presentation/media/media_alt_text_panel.dart';
import 'package:lazurite/features/feed/presentation/media/video_layout.dart';
import 'package:lazurite/features/feed/presentation/media/video_player_route_args.dart';
import 'package:video_player/video_player.dart';

/// Full-screen player for a video embedded in a feed post.
///
/// The screen receives validated [VideoPlayerRouteArgs] from the router, then
/// creates and owns the platform video controller and Chewie UI controller for
/// the lifetime of the route.
class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key, required this.args});

  final VideoPlayerRouteArgs args;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

/// Runtime state for video playback, initialization errors, and downloads.
///
/// Controller setup is asynchronous, so this state keeps the placeholder,
/// failure UI, and playback UI mutually exclusive while initialization runs.
class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  Object? _initializationError;
  bool _isInitializing = true;
  bool _isDownloading = false;
  double _downloadProgress = 0;

  double get _aspectRatio => normalizeVideoAspectRatio(widget.args.aspectRatio);

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressValue = _downloadProgress > 0 && _downloadProgress < 1 ? _downloadProgress : null;
    final altText = widget.args.altText?.trim();
    final hasAltText = altText?.isNotEmpty ?? false;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Video'),
        actions: [
          IconButton(
            tooltip: 'Download',
            onPressed: _isDownloading ? null : _downloadVideo,
            icon: _isDownloading
                ? SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(value: progressValue, strokeWidth: 2.4, color: Colors.white),
                  )
                : const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final videoSize = containedVideoSize(
                      availableSize: Size(constraints.maxWidth, constraints.maxHeight),
                      aspectRatio: _aspectRatio,
                    );
                    return Center(
                      child: SizedBox(
                        width: videoSize.width,
                        height: videoSize.height,
                        child: switch ((_isInitializing, _initializationError, _chewieController)) {
                          (true, _, _) => _buildPlaceholder(showSpinner: true),
                          (_, final Object error, _) => _buildErrorState(context, error),
                          (_, _, final ChewieController controller) => Chewie(controller: controller),
                          _ => _buildPlaceholder(),
                        },
                      ),
                    );
                  },
                ),
              ),
              if (hasAltText)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: MediaAltTextPanel(
                    text: altText!,
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: context.textTheme.bodyMedium,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder({bool showSpinner = false}) => Stack(
    fit: StackFit.expand,
    alignment: Alignment.center,
    children: [
      if (widget.args.thumbnailUrl != null)
        CachedNetworkImage(
          imageUrl: widget.args.thumbnailUrl!,
          cacheManager: LazuriteImageCacheManager.instance,
          fit: BoxFit.cover,
          errorWidget: (_, _, _) => const ColoredBox(color: Colors.black26),
        )
      else
        const ColoredBox(color: Colors.black26),
      if (showSpinner) const Center(child: CircularProgressIndicator()),
      if (!showSpinner)
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.65), shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
          ),
        ),
    ],
  );

  Widget _buildErrorState(BuildContext context, Object error) => ColoredBox(
    color: context.colorScheme.surfaceContainerHighest,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Failed to load video.\n$error', textAlign: TextAlign.center, style: context.textTheme.bodyMedium),
      ),
    ),
  );

  Future<void> _initializePlayer() async {
    try {
      final sourceUri = Uri.parse(widget.args.playlistUrl);
      final controller = VideoPlayerController.networkUrl(sourceUri, formatHint: _inferVideoFormat(sourceUri));
      await controller.initialize();
      await controller.setLooping(widget.args.isGif);

      if (widget.args.isGif) {
        await controller.setVolume(0);
      }

      final chewieController = ChewieController(
        videoPlayerController: controller,
        aspectRatio: _aspectRatio,
        autoInitialize: false,
        autoPlay: widget.args.isGif,
        looping: widget.args.isGif,
        showControls: !widget.args.isGif,
        allowMuting: !widget.args.isGif,
        allowPlaybackSpeedChanging: !widget.args.isGif,
        progressIndicatorDelay: Platform.isAndroid ? const Duration(days: 1) : null,
        placeholder: _buildPlaceholder(),
      );

      if (!mounted) {
        chewieController.dispose();
        await controller.dispose();
        return;
      }

      setState(() {
        _videoController = controller;
        _chewieController = chewieController;
        _isInitializing = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _initializationError = error;
        _isInitializing = false;
      });
    }
  }

  VideoFormat? _inferVideoFormat(Uri uri) {
    final path = uri.path.toLowerCase();
    if (path.endsWith('.m3u8')) {
      return VideoFormat.hls;
    }
    if (path.endsWith('.mpd')) {
      return VideoFormat.dash;
    }
    return null;
  }

  Future<void> _downloadVideo() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    await MediaActions.downloadVideo(
      context,
      widget.args.playlistUrl,
      preferredDownloadUrl: widget.args.downloadUrl,
      suggestedName: 'lazurite-video.mp4',
      onProgress: (value) {
        if (!mounted) {
          return;
        }
        setState(() {
          _downloadProgress = value;
        });
      },
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isDownloading = false;
      _downloadProgress = 0;
    });
  }
}
