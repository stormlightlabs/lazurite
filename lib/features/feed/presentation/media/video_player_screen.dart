import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:lazurite/features/feed/presentation/media/media_actions.dart';
import 'package:lazurite/features/feed/presentation/media/video_player_route_args.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key, required this.args});

  final VideoPlayerRouteArgs args;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  Object? _initializationError;
  bool _isInitializing = true;
  bool _isDownloading = false;
  double _downloadProgress = 0;

  double get _aspectRatio => widget.args.aspectRatio ?? 16 / 9;

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
    final theme = Theme.of(context);
    final progressValue = _downloadProgress > 0 && _downloadProgress < 1 ? _downloadProgress : null;

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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
        children: [
          AspectRatio(
            aspectRatio: _aspectRatio,
            child: switch ((_isInitializing, _initializationError, _chewieController)) {
              (true, _, _) => _buildPlaceholder(showSpinner: true),
              (_, final Object error, _) => _buildErrorState(theme, error),
              (_, _, final ChewieController controller) => Chewie(controller: controller),
              _ => _buildPlaceholder(),
            },
          ),
          if (widget.args.altText?.trim().isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(widget.args.altText!, style: theme.textTheme.bodyMedium),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder({bool showSpinner = false}) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        if (widget.args.thumbnailUrl != null)
          Image.network(
            widget.args.thumbnailUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black26),
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
  }

  Widget _buildErrorState(ThemeData theme, Object error) {
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Failed to load video.\n$error', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
        ),
      ),
    );
  }

  Future<void> _initializePlayer() async {
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(widget.args.playlistUrl));
      await controller.initialize();

      if (widget.args.isGif) {
        await controller.setVolume(0);
      }

      final chewieController = ChewieController(
        videoPlayerController: controller,
        aspectRatio: _aspectRatio,
        autoInitialize: true,
        autoPlay: widget.args.isGif,
        looping: widget.args.isGif,
        showControls: !widget.args.isGif,
        allowMuting: !widget.args.isGif,
        allowPlaybackSpeedChanging: !widget.args.isGif,
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

  Future<void> _downloadVideo() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    await MediaActions.downloadVideo(
      context,
      widget.args.playlistUrl,
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
