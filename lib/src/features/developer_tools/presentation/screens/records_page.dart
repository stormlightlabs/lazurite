import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/routes.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/utils/error_message.dart';
import 'package:lazurite/src/features/developer_tools/application/devtools_providers.dart';
import 'package:lazurite/src/features/developer_tools/domain/repo_record.dart';

class RecordsPage extends ConsumerStatefulWidget {
  const RecordsPage({required this.did, required this.collection, super.key});

  final String did;
  final String collection;

  @override
  ConsumerState<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends ConsumerState<RecordsPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(recordsProvider(widget.did, widget.collection).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recordsAsync = ref.watch(recordsProvider(widget.did, widget.collection));

    return Scaffold(
      appBar: AppBar(
        title: Text(_formatCollectionName(widget.collection), overflow: TextOverflow.ellipsis),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: recordsAsync.when(
        data: (state) {
          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Failed to load records', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage(state.error),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(recordsProvider(widget.did, widget.collection).notifier)
                            .refresh();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.records.isEmpty && !state.isLoading) {
            return Center(
              child: Text(
                'No records found',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(recordsProvider(widget.did, widget.collection).notifier).refresh(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.records.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.records.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final record = state.records[index];
                return _RecordTile(record: record);
              },
            ),
          );
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
                Text('Failed to load records', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  errorMessage(error),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(recordsProvider(widget.did, widget.collection));
                  },
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

  String _formatCollectionName(String nsid) {
    final parts = nsid.split('.');
    return parts.isNotEmpty ? parts.last : nsid;
  }
}

class _RecordTile extends ConsumerWidget {
  const _RecordTile({required this.record});

  final RepoRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pinnedUrisAsync = ref.watch(pinnedUrisProvider);

    final isPinned = pinnedUrisAsync.value?.contains(record.uri) ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.rkey,
                    style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: isPinned ? theme.colorScheme.primary : null,
                  ),
                  onPressed: () async {
                    final db = ref.read(appDatabaseProvider);
                    if (isPinned) {
                      await db.devToolsDao.deletePin(record.uri);
                    } else {
                      await db.devToolsDao.savePin(
                        uri: record.uri,
                        type: 'record',
                        label: record.rkey,
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'CID: ${record.cid}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (record.indexedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Indexed: ${_formatDate(record.indexedAt!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            _RecordPreview(record: record),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  context.goNamed(
                    AppRouteNames.devToolsRecord,
                    pathParameters: {
                      'collection': Uri.encodeComponent(record.collection),
                      'rkey': Uri.encodeComponent(record.rkey),
                    },
                  );
                },
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _RecordPreview extends StatelessWidget {
  const _RecordPreview({required this.record});

  final RepoRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildPreview(context),
    );
  }

  Widget _buildPreview(BuildContext context) {
    final theme = Theme.of(context);
    final collection = record.collection;

    if (collection == 'app.bsky.feed.post') {
      return _buildPostPreview(context);
    } else if (collection == 'app.bsky.actor.profile') {
      return _buildProfilePreview(context);
    } else if (collection == 'app.bsky.graph.follow') {
      return _buildFollowPreview(context);
    } else if (collection == 'app.bsky.feed.like') {
      return _buildLikePreview(context);
    }

    return _buildJsonPreview(theme);
  }

  Widget _buildPostPreview(BuildContext context) {
    final theme = Theme.of(context);
    final text = record.value['text'] as String?;
    final createdAt = record.value['createdAt'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.article, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('Post', style: theme.textTheme.labelSmall),
          ],
        ),
        if (text != null) ...[
          const SizedBox(height: 8),
          Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ],
        if (createdAt != null) ...[
          const SizedBox(height: 4),
          Text(
            'Posted: $createdAt',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }

  Widget _buildProfilePreview(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = record.value['displayName'] as String?;
    final description = record.value['description'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('Profile', style: theme.textTheme.labelSmall),
          ],
        ),
        if (displayName != null) ...[
          const SizedBox(height: 8),
          Text(displayName, style: theme.textTheme.titleSmall),
        ],
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _buildFollowPreview(BuildContext context) {
    final theme = Theme.of(context);
    final subject = record.value['subject'] as String?;

    return Row(
      children: [
        Icon(Icons.person_add, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Follow: ${subject ?? 'Unknown'}',
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLikePreview(BuildContext context) {
    final theme = Theme.of(context);
    final subject = record.value['subject'] as Map<String, dynamic>?;
    final uri = subject?['uri'] as String?;

    return Row(
      children: [
        Icon(Icons.favorite, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Like: ${uri ?? 'Unknown'}',
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildJsonPreview(ThemeData theme) {
    final keys = record.value.keys.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.code, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text('JSON Record', style: theme.textTheme.labelSmall),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          keys.map((key) => '$key: ${record.value[key]}').join('\n'),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
