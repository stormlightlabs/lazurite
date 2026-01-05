import 'dart:io';

import 'package:flutter/material.dart';

/// Horizontal row for adding and displaying media attachments.
class MediaPickerRow extends StatelessWidget {
  const MediaPickerRow({
    required this.mediaPaths,
    this.onAddMedia,
    this.onRemoveMedia,
    this.maxMedia = 4,
    super.key,
  });

  /// List of local file paths for attached media.
  final List<String> mediaPaths;

  /// Callback when user requests to add media.
  final VoidCallback? onAddMedia;

  /// Callback when user removes media at a given index.
  final ValueChanged<int>? onRemoveMedia;

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
          // Add button at the end
          if (index == mediaPaths.length) {
            return _AddMediaButton(onTap: onAddMedia, colorScheme: colorScheme);
          }

          // Media thumbnail
          return _MediaThumbnail(
            path: mediaPaths[index],
            onRemove: onRemoveMedia != null ? () => onRemoveMedia!(index) : null,
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
  const _MediaThumbnail({required this.path, required this.colorScheme, this.onRemove});

  final String path;
  final VoidCallback? onRemove;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    final hasFile = file.existsSync();

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 80,
            height: 80,
            child: hasFile
                ? Image.file(
                    file,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _BrokenImagePlaceholder(colorScheme: colorScheme),
                  )
                : _BrokenImagePlaceholder(colorScheme: colorScheme),
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
      ],
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
