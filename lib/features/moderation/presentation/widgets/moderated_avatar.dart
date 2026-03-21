import 'package:bluesky/moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';

class ModeratedAvatar extends StatelessWidget {
  const ModeratedAvatar({
    super.key,
    required this.size,
    required this.initials,
    this.imageUrl,
    this.ui,
    this.shape = BoxShape.circle,
    this.borderRadius,
    this.border,
    this.placeholderTextStyle,
  });

  final double size;
  final String initials;
  final String? imageUrl;
  final bsky_moderation.ModerationUI? ui;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final Border? border;
  final TextStyle? placeholderTextStyle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shouldMask = ui?.blur ?? false;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
        border: border,
      ),
      clipBehavior: Clip.antiAlias,
      child: shouldMask
          ? Icon(Icons.shield_outlined, color: colorScheme.onSurfaceVariant, size: size * 0.44)
          : imageUrl != null
          ? Image.network(imageUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => _buildFallback(context))
          : _buildFallback(context),
    );
  }

  Widget _buildFallback(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(child: Text(initials, style: placeholderTextStyle ?? theme.textTheme.labelLarge)),
    );
  }
}
