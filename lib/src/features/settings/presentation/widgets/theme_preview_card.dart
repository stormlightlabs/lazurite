import 'package:flutter/material.dart';

/// Compact preview card showing a theme's color scheme.
///
/// Displays color samples for surfaces, text, and accents with a label.
class ThemePreviewCard extends StatelessWidget {
  const ThemePreviewCard({super.key, required this.label, required this.colorScheme});

  /// Label to display at the bottom (e.g., "Light" or "Dark").
  final String label;

  /// The color scheme to preview.
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_buildSurfaceSamples(), _buildAccentSamples(), _buildLabel(context)],
      ),
    );
  }

  Widget _buildSurfaceSamples() {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(child: ColoredBox(color: colorScheme.surface)),
          Expanded(child: ColoredBox(color: colorScheme.surfaceContainerLow)),
          Expanded(child: ColoredBox(color: colorScheme.surfaceContainerHigh)),
        ],
      ),
    );
  }

  Widget _buildAccentSamples() {
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          Expanded(child: ColoredBox(color: colorScheme.primary)),
          Expanded(child: ColoredBox(color: colorScheme.secondary)),
          Expanded(child: ColoredBox(color: colorScheme.tertiary)),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w500),
            ),
          ),
          _buildTextSample('Aa', colorScheme.onSurface),
          const SizedBox(width: 8),
          _buildTextSample('Aa', colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildTextSample(String text, Color color) {
    return Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
    );
  }
}
