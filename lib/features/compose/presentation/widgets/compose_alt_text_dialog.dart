import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/features/compose/bloc/compose_bloc.dart';
import 'package:lazurite/features/compose/presentation/widgets/compose_video_preview.dart';

class ImageAltTextDialog extends StatefulWidget {
  const ImageAltTextDialog({
    super.key,
    required this.imagePath,
    required this.initialAltText,
    required this.onCancel,
    required this.onSave,
  });

  final String imagePath;
  final String initialAltText;
  final VoidCallback onCancel;
  final ValueChanged<String> onSave;

  @override
  State<ImageAltTextDialog> createState() => _ImageAltTextDialogState();
}

class _ImageAltTextDialogState extends State<ImageAltTextDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialAltText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final imageHeight = (size.height * 0.32).clamp(140.0, 280.0).toDouble();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) widget.onSave(_controller.text);
      },
      child: Dialog(
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560, maxHeight: size.height * 0.9),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(context.l10n.messageComposeImageAltTextTitle, style: theme.textTheme.titleLarge),
                    ),
                    IconButton(
                      tooltip: context.l10n.labelClose,
                      onPressed: () => widget.onSave(_controller.text),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: imageHeight,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
                  ),
                  child: Image.file(
                    key: const ValueKey('alt-text-image-preview'),
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Center(child: Icon(Icons.broken_image_outlined, size: 40, color: colorScheme.onSurfaceVariant)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const ValueKey('alt-text-field'),
                  controller: _controller,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 1000,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: context.l10n.messageComposeDescribeImage,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: widget.onCancel, child: Text(context.l10n.buttonCancel)),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => widget.onSave(_controller.text),
                      child: Text(context.l10n.buttonSave),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VideoAltTextDialog extends StatefulWidget {
  const VideoAltTextDialog({super.key, required this.video, required this.onCancel, required this.onSave});

  final VideoAttachment video;
  final VoidCallback onCancel;
  final ValueChanged<String> onSave;

  @override
  State<VideoAltTextDialog> createState() => _VideoAltTextDialogState();
}

class _VideoAltTextDialogState extends State<VideoAltTextDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.video.altText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final previewHeight = (size.height * 0.32).clamp(140.0, 280.0).toDouble();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) widget.onSave(_controller.text);
      },
      child: Dialog(
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560, maxHeight: size.height * 0.9),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(context.l10n.messageComposeVideoAltTextTitle, style: theme.textTheme.titleLarge),
                    ),
                    IconButton(
                      tooltip: context.l10n.labelClose,
                      onPressed: () => widget.onSave(_controller.text),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LocalVideoPreview(videoPath: widget.video.localPath, height: previewHeight),
                const SizedBox(height: 16),
                TextField(
                  key: const ValueKey('video-alt-text-field'),
                  controller: _controller,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 1000,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: context.l10n.messageComposeDescribeVideo,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: widget.onCancel, child: Text(context.l10n.buttonCancel)),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => widget.onSave(_controller.text),
                      child: Text(context.l10n.buttonSave),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
