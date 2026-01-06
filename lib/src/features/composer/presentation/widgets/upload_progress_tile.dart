import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/draft.dart';

/// Displays upload progress for a single media attachment.
class UploadProgressTile extends StatelessWidget {
  const UploadProgressTile({
    required this.filename,
    required this.status,
    this.thumbnailPath,
    this.progress = 0.0,
    this.onRetry,
    super.key,
  });

  /// Display filename for the media.
  final String filename;

  /// Local path for thumbnail preview.
  final String? thumbnailPath;

  /// Current upload status.
  final DraftMediaStatus status;

  /// Upload progress from 0.0 to 1.0.
  final double progress;

  /// Callback for retry action on failed uploads.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 48,
              height: 48,
              child: thumbnailPath != null
                  ? Image.file(
                      File(thumbnailPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _PlaceholderThumbnail(colorScheme: colorScheme),
                    )
                  : _PlaceholderThumbnail(colorScheme: colorScheme),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  filename,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (status == DraftMediaStatus.uploading)
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    color: colorScheme.primary,
                  )
                else
                  _StatusLabel(status: status, colorScheme: colorScheme),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusAction(status: status, colorScheme: colorScheme, onRetry: onRetry),
        ],
      ),
    );
  }
}

class _PlaceholderThumbnail extends StatelessWidget {
  const _PlaceholderThumbnail({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.image, color: colorScheme.onSurfaceVariant, size: 24),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status, required this.colorScheme});

  final DraftMediaStatus status;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (status) {
      DraftMediaStatus.pending => ('Pending', colorScheme.outline),
      DraftMediaStatus.uploading => ('Uploading', colorScheme.primary),
      DraftMediaStatus.uploaded => ('Uploaded', Colors.green),
      DraftMediaStatus.failed => ('Failed', colorScheme.error),
    };

    return Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color));
  }
}

class _StatusAction extends StatelessWidget {
  const _StatusAction({required this.status, required this.colorScheme, this.onRetry});

  final DraftMediaStatus status;
  final ColorScheme colorScheme;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      DraftMediaStatus.pending => Icon(
        Icons.hourglass_empty,
        color: colorScheme.outline,
        size: 20,
      ),
      DraftMediaStatus.uploading => SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
      ),
      DraftMediaStatus.uploaded => const Icon(Icons.check_circle, color: Colors.green, size: 20),
      DraftMediaStatus.failed => IconButton(
        onPressed: onRetry,
        icon: Icon(Icons.refresh, color: colorScheme.error),
        iconSize: 20,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    };
  }
}
