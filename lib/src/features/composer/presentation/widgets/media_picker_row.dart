import 'dart:io';

import 'package:flutter/material.dart';

/// Horizontal row for adding and displaying media attachments.
class MediaPickerRow extends StatelessWidget {
  const MediaPickerRow({
    required this.mediaPaths,
    this.mediaTypes,
    this.onAddMedia,
    this.onRemoveMedia,
    this.onTapMedia,
    this.altTextIndicators = const [],
    this.maxMedia = 4,
    super.key,
  });

  /// List of local file paths for attached media.
  final List<String> mediaPaths;

  /// List of MIME types for attached media (optional).
  final List<String>? mediaTypes;

  /// Callback when user requests to add media.
  final VoidCallback? onAddMedia;

  /// Callback when user removes media at a given index.
  final ValueChanged<int>? onRemoveMedia;

  /// Callback when user taps on a media thumbnail (for editing alt text).
  final ValueChanged<int>? onTapMedia;

  /// List of booleans indicating whether each media has alt text.
  final List<bool> altTextIndicators;

  /// Maximum number of media attachments allowed.
  final int maxMedia;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canAddMore = mediaPaths.length < maxMedia;

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: mediaPaths.length + (canAddMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == mediaPaths.length) {
            return _AddMediaButton(onTap: onAddMedia, colorScheme: colorScheme);
          }
          final hasAltText = index < altTextIndicators.length && altTextIndicators[index];
          final mimeType = index < (mediaTypes?.length ?? 0) ? mediaTypes![index] : '';
          return _MediaThumbnail(
            path: mediaPaths[index],
            mimeType: mimeType,
            onRemove: onRemoveMedia != null ? () => onRemoveMedia!(index) : null,
            onTap: onTapMedia != null ? () => onTapMedia!(index) : null,
            hasAltText: hasAltText,
            colorScheme: colorScheme,
          );
        },
      ),
    );
  }
}

class _AddMediaButton extends StatelessWidget {
  const _AddMediaButton({required this.onTap, required this.colorScheme});

  final VoidCallback? onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.add_photo_alternate_outlined, color: colorScheme.primary, size: 32),
        ),
      ),
    );
  }
}

class _MediaThumbnail extends StatelessWidget {
  const _MediaThumbnail({
    required this.path,
    this.mimeType,
    required this.colorScheme,
    this.onRemove,
    this.onTap,
    this.hasAltText = false,
  });

  final String path;
  final String? mimeType;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final bool hasAltText;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    final hasFile = file.existsSync();
    final isVideo = mimeType != null && mimeType!.startsWith('video/');

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 80,
              child: isVideo
                  ? _VideoPlaceholder(colorScheme: colorScheme)
                  : hasFile
                  ? Image.file(
                      file,
                      fit: BoxFit.cover,
                      cacheWidth: 160,
                      cacheHeight: 160,
                      errorBuilder: (_, _, _) => _BrokenImagePlaceholder(colorScheme: colorScheme),
                    )
                  : _BrokenImagePlaceholder(colorScheme: colorScheme),
            ),
          ),
          if (isVideo)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_outline, color: Colors.white, size: 32),
                ),
              ),
            ),
          if (onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withAlpha(200),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 16, color: colorScheme.onSurface),
                ),
              ),
            ),
          if (hasAltText)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'ALT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BrokenImagePlaceholder extends StatelessWidget {
  const _BrokenImagePlaceholder({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.broken_image, color: colorScheme.error),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.video_library,
        color: colorScheme.onSurface.withValues(alpha: 0.5),
        size: 32,
      ),
    );
  }
}
