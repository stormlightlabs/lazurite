import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/system_info_provider.dart';

/// Tab displaying system information.
///
/// Shows:
/// - Flutter version and build mode
/// - Platform and OS version
/// - Screen size, pixel ratio, safe area
/// - Memory usage (when available)
/// - Frame rate (when available)
class SystemInfoTab extends ConsumerWidget {
  const SystemInfoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemInfoAsync = ref.watch(systemInfoProvider);
    final theme = Theme.of(context);

    return systemInfoAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error', style: TextStyle(color: theme.colorScheme.error)),
      ),
      data: (systemInfo) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
              theme: theme,
              title: 'Build',
              items: [
                _InfoItem(
                  label: 'Apps Version',
                  value: '${systemInfo.appVersion}+${systemInfo.buildNumber}',
                ),
                if (systemInfo.gitVersion != null)
                  _InfoItem(label: 'Git Version', value: systemInfo.gitVersion!),
                _InfoItem(label: 'Flutter Version', value: systemInfo.flutterVersion),
                _InfoItem(label: 'Build Mode', value: systemInfo.buildMode),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              theme: theme,
              title: 'Platform',
              items: [
                _InfoItem(label: 'Platform', value: systemInfo.platform),
                _InfoItem(label: 'OS Version', value: systemInfo.osVersion),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              theme: theme,
              title: 'Display',
              items: [
                _InfoItem(
                  label: 'Screen Size',
                  value:
                      '${systemInfo.screenSize.width.toStringAsFixed(0)} × '
                      '${systemInfo.screenSize.height.toStringAsFixed(0)}',
                ),
                _InfoItem(label: 'Pixel Ratio', value: systemInfo.pixelRatio.toStringAsFixed(2)),
                _InfoItem(label: 'Safe Area', value: _formatInsets(systemInfo.safeAreaInsets)),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              theme: theme,
              title: 'Performance',
              items: [
                _InfoItem(
                  label: 'Memory (RSS)',
                  value: systemInfo.memoryUsage != null
                      ? _formatBytes(systemInfo.memoryUsage!)
                      : 'N/A',
                ),
                _InfoItem(
                  label: 'FPS',
                  value: systemInfo.currentFps != null
                      ? '${systemInfo.currentFps!.toStringAsFixed(1)} fps'
                      : 'N/A',
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    required List<_InfoItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: items.map((item) {
              final isLast = item == items.last;
              return _buildRow(theme, item, showDivider: !isLast);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(ThemeData theme, _InfoItem item, {required bool showDivider}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Flexible(
                child: Text(
                  item.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 12,
            endIndent: 12,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _formatInsets(EdgeInsets insets) {
    if (insets == EdgeInsets.zero) return 'None';
    return 'T:${insets.top.toInt()} B:${insets.bottom.toInt()} '
        'L:${insets.left.toInt()} R:${insets.right.toInt()}';
  }
}

class _InfoItem {
  const _InfoItem({required this.label, required this.value});
  final String label;
  final String value;
}
