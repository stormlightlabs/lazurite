import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_json/flutter_json.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/features/developer_tools/application/devtools_providers.dart';
import 'package:lazurite/src/features/developer_tools/domain/repo_record.dart';

/// A page that displays the full details of a single ATProto record.
///
/// Shows metadata (AT URI, CID, indexedAt), a collapsible JSON tree viewer,
/// and copy/export actions.
class RecordDetailPage extends ConsumerWidget {
  const RecordDetailPage({required this.collection, required this.rkey, super.key});

  final String collection;
  final String rkey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recordAsync = ref.watch(recordDetailProvider(collection, rkey));

    return Scaffold(
      appBar: AppBar(
        title: Text(rkey, overflow: TextOverflow.ellipsis),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share JSON',
            onPressed: () {
              recordAsync.whenData((record) {
                if (record != null) {
                  _shareRecord(context, record);
                }
              });
            },
          ),
        ],
      ),
      body: recordAsync.when(
        data: (record) {
          if (record == null) {
            return Center(
              child: Text(
                'Record not found',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          return _RecordDetailContent(record: record);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text('Failed to load record', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(recordDetailProvider(collection, rkey)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _shareRecord(BuildContext context, RepoRecord record) {
    final jsonString = const JsonEncoder.withIndent('  ').convert(record.toJson());
    Clipboard.setData(ClipboardData(text: jsonString));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Record JSON copied to clipboard')));
  }
}

class _RecordDetailContent extends StatelessWidget {
  const _RecordDetailContent({required this.record});

  final RepoRecord record;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetadataHeader(record: record),
          const SizedBox(height: 24),
          ..._buildBlobPreviews(context),
          _JsonTreeSection(record: record),
        ],
      ),
    );
  }

  List<Widget> _buildBlobPreviews(BuildContext context) {
    final blobs = _findBlobs(record.value);
    if (blobs.isEmpty) return [];

    return [
      Text('Blobs', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      ...blobs.map((blob) => _BlobPreview(blob: blob)),
      const SizedBox(height: 24),
    ];
  }

  List<Map<String, dynamic>> _findBlobs(dynamic value, [List<Map<String, dynamic>>? results]) {
    results ??= [];

    if (value is Map<String, dynamic>) {
      if (value[r'$type'] == 'blob' && value['ref'] != null) {
        results.add(value);
      } else {
        for (final v in value.values) {
          _findBlobs(v, results);
        }
      }
    } else if (value is List) {
      for (final item in value) {
        _findBlobs(item, results);
      }
    }

    return results;
  }
}

class _MetadataHeader extends StatelessWidget {
  const _MetadataHeader({required this.record});

  final RepoRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Metadata', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            _MetadataRow(label: 'AT URI', value: record.uri, copyable: true),
            const Divider(height: 24),
            _MetadataRow(label: 'CID', value: record.cid, copyable: true),
            if (record.indexedAt != null) ...[
              const Divider(height: 24),
              _MetadataRow(
                label: 'Indexed At',
                value: _formatDate(record.indexedAt!),
                copyable: false,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:'
        '${date.second.toString().padLeft(2, '0')} UTC';
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.label, required this.value, this.copyable = false});

  final String label;
  final String value;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
        if (copyable)
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$label copied to clipboard')));
            },
            tooltip: 'Copy $label',
          ),
      ],
    );
  }
}

class _JsonTreeSection extends StatelessWidget {
  const _JsonTreeSection({required this.record});

  final RepoRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Record Value', style: theme.textTheme.titleMedium),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy JSON',
              onPressed: () {
                final jsonString = const JsonEncoder.withIndent('  ').convert(record.value);
                Clipboard.setData(ClipboardData(text: jsonString));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('JSON copied to clipboard')));
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 500),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: JsonWidget(
            json: record.value,
            initialExpandDepth: 2,
            keyColor: isDark ? Colors.cyan : Colors.blue.shade800,
            stringColor: isDark ? Colors.lightGreen : Colors.green.shade800,
            boolColor: isDark ? Colors.purple.shade300 : Colors.purple.shade700,
          ),
        ),
      ],
    );
  }
}

class _BlobPreview extends StatelessWidget {
  const _BlobPreview({required this.blob});

  final Map<String, dynamic> blob;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mimeType = blob['mimeType'] as String? ?? 'unknown';
    final size = blob['size'] as int? ?? 0;
    final ref = blob['ref'] as Map<String, dynamic>?;
    final link = ref?[r'$link'] as String?;

    final isImage = mimeType.startsWith('image/');
    final isVideo = mimeType.startsWith('video/');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isImage
              ? Icons.image
              : isVideo
              ? Icons.videocam
              : Icons.attachment,
          color: theme.colorScheme.primary,
        ),
        title: Text(mimeType),
        subtitle: Text(
          '${_formatSize(size)}${link != null ? ' • CID: ${link.substring(0, 12)}...' : ''}',
        ),
        trailing: link != null
            ? IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: link));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Blob CID copied to clipboard')));
                },
              )
            : null,
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
