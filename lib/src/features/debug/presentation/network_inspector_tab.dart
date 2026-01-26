import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';

/// Tab for inspecting network traffic in the debug drawer.
class NetworkInspectorTab extends ConsumerWidget {
  const NetworkInspectorTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final theme = Theme.of(context);

    return StreamBuilder<List<DevNetworkLog>>(
      stream: db.devToolsDao.watchLogs(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final logs = snapshot.data!;
        if (logs.isEmpty) {
          return Center(
            child: Text(
              'No network logs recorded.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return Column(
          children: [
            _buildToolbar(context, ref, logs.length),
            Expanded(
              child: ListView.separated(
                itemCount: logs.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return _LogItem(log: log);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToolbar(BuildContext context, WidgetRef ref, int count) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surfaceContainer,
      child: Row(
        children: [
          Text(
            '$count Requests',
            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              ref.read(appDatabaseProvider).devToolsDao.clearLogs();
            },
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Clear'),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  const _LogItem({required this.log});

  final DevNetworkLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(log.statusCode, theme);
    final timeFormat = DateFormat('HH:mm:ss');

    return InkWell(
      onTap: () => _showDetails(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    log.statusCode.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  log.method,
                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${log.durationMs}ms',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              log.url,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              timeFormat.format(log.timestamp),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (log.error != null) ...[
              const SizedBox(height: 4),
              Text(
                log.error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(int statusCode, ThemeData theme) {
    if (statusCode >= 200 && statusCode < 300) return Colors.green;
    if (statusCode >= 300 && statusCode < 400) return Colors.blue;
    if (statusCode >= 400 && statusCode < 500) return Colors.orange;
    if (statusCode >= 500) return theme.colorScheme.error;
    return theme.colorScheme.onSurface;
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _LogDetailsSheet(log: log),
    );
  }
}

class _LogDetailsSheet extends StatelessWidget {
  const _LogDetailsSheet({required this.log});

  final DevNetworkLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            SelectableText(log.url, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            _buildSection(context, 'General', [
              _buildPair('Method', log.method),
              _buildPair('Status', '${log.statusCode}'),
              _buildPair('Duration', '${log.durationMs}ms'),
              _buildPair('Time', DateFormat('HH:mm:ss.SSS').format(log.timestamp)),
            ]),
            const Divider(height: 32),
            _buildSection(context, 'Request Headers', [_buildJsonOrText(log.requestHeaders)]),
            const SizedBox(height: 16),
            _buildSection(context, 'Request Body', [
              _buildJsonOrText(log.requestBody ?? '(Empty)'),
            ]),
            const Divider(height: 32),
            _buildSection(context, 'Response Headers', [_buildJsonOrText(log.responseHeaders)]),
            const SizedBox(height: 16),
            _buildSection(context, 'Response Body', [
              _buildJsonOrText(log.responseBody ?? '(Empty)'),
            ]),
            if (log.error != null) ...[
              const Divider(height: 32),
              _buildSection(context, 'Error', [
                Text(log.error!, style: TextStyle(color: theme.colorScheme.error)),
              ]),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildPair(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }

  Widget _buildJsonOrText(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(text, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
    );
  }
}
