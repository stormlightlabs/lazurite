import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:video_player/video_player.dart';

class LocalVideoPreview extends StatefulWidget {
  const LocalVideoPreview({super.key, required this.videoPath, required this.height});

  final String videoPath;
  final double height;

  @override
  State<LocalVideoPreview> createState() => _LocalVideoPreviewState();
}

class _LocalVideoPreviewState extends State<LocalVideoPreview> {
  VideoPlayerController? _controller;
  Object? _error;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = _controller;
    final filename = widget.videoPath.split('/').last;

    return Container(
      key: const ValueKey('video-alt-preview'),
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: GestureDetector(
        onTap: controller != null && controller.value.isInitialized ? _togglePlayback : null,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            if (controller != null && controller.value.isInitialized)
              FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              )
            else
              VideoPreviewFallback(filename: filename, isLoading: _isInitializing, error: _error),
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.62), shape: BoxShape.circle),
                child: Icon(
                  controller?.value.isPlaying == true ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initialize() async {
    final file = File(widget.videoPath);
    if (!file.existsSync()) {
      return;
    }

    setState(() {
      _isInitializing = true;
    });

    try {
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      await controller.setLooping(true);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isInitializing = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _isInitializing = false;
      });
    }
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }

    if (mounted) {
      setState(() {});
    }
  }
}

class VideoPreviewFallback extends StatelessWidget {
  const VideoPreviewFallback({super.key, required this.filename, required this.isLoading, required this.error});

  final String filename;
  final bool isLoading;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.4))
            else
              Icon(Icons.videocam_outlined, size: 40, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 10),
            Text(
              filename.isEmpty ? context.l10n.labelVideo : filename,
              key: const ValueKey('video-alt-preview-filename'),
              style: theme.textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(
                context.l10n.messageComposePreviewUnavailable,
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
