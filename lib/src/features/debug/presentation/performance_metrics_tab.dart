import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/performance_monitor_notifier.dart';

/// A tab in the debug overlay that displays performance diagnostics.
class PerformanceMetricsTab extends ConsumerWidget {
  const PerformanceMetricsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(performanceMonitorProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          theme: theme,
          title: 'Frame Rate',
          child: _MetricCard(
            label: 'Current FPS',
            value: '${state.fps.toStringAsFixed(1)} fps',
            color: _getFpsColor(state.fps, theme),
          ),
        ),
        const SizedBox(height: 16),
        _buildSection(
          theme: theme,
          title: 'Image Cache',
          items: [
            _InfoItem(label: 'Live Images', value: '${state.imageCacheLiveCount}'),
            _InfoItem(label: 'Pending Images', value: '${state.imageCachePendingCount}'),
            _InfoItem(label: 'Cache Size', value: _formatBytes(state.imageCacheByteCount)),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          theme: theme,
          title: 'Widget Rebuilds',
          trailing: IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () => ref.read(performanceMonitorProvider.notifier).resetRebuildCounts(),
            tooltip: 'Reset Counts',
          ),
          child: state.rebuildCounts.isEmpty
              ? _buildEmptyState(theme, 'No rebuilds tracked yet.')
              : Column(
                  children: state.rebuildCounts.entries.map((e) {
                    return _InfoRow(
                      label: e.key,
                      value: '${e.value}',
                      showDivider: e.key != state.rebuildCounts.keys.last,
                      theme: theme,
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 16),
        _buildSection(
          theme: theme,
          title: 'Database Performance',
          child: state.queryTimes.isEmpty
              ? _buildEmptyState(theme, 'No queries logged.')
              : Column(
                  children: [
                    _MetricCard(
                      label: 'Avg Query Time',
                      value: '${_calculateAvg(state.queryTimes).toStringAsFixed(2)} ms',
                    ),
                    const SizedBox(height: 8),
                    _MetricCard(
                      label: 'Max Query Time',
                      value: '${_calculateMax(state.queryTimes).toStringAsFixed(2)} ms',
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    Widget? child,
    List<_InfoItem>? items,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              child ??
              Column(
                children: items!.map((item) {
                  final isLast = item == items.last;
                  return _InfoRow(
                    label: item.label,
                    value: item.value,
                    showDivider: !isLast,
                    theme: theme,
                  );
                }).toList(),
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, String message) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Color? _getFpsColor(double fps, ThemeData theme) {
    if (fps >= 55) return Colors.green;
    if (fps >= 30) return Colors.orange;
    return theme.colorScheme.error;
  }

  double _calculateAvg(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _calculateMax(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a > b ? a : b);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.showDivider,
    required this.theme,
  });
  final String label;
  final String value;
  final bool showDivider;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
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
}

class _InfoItem {
  const _InfoItem({required this.label, required this.value});
  final String label;
  final String value;
}
