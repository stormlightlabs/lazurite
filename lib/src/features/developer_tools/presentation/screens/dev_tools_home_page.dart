import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/app/routes.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/developer_tools/application/devtools_providers.dart';

class DevToolsHomePage extends ConsumerWidget {
  const DevToolsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    final String did;
    final String pdsUrl;

    if (authState is AuthStateAuthenticated) {
      did = authState.session.did;
      pdsUrl = authState.session.pdsUrl;
    } else {
      did = 'Not authenticated';
      pdsUrl = 'Unknown';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Tools'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInfoCard(
            context,
            title: 'My DID',
            value: did,
            actionIcon: Icons.copy,
            onAction: () {
              Clipboard.setData(ClipboardData(text: did));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('DID copied to clipboard')));
            },
          ),
          const SizedBox(height: 16),
          _buildInfoCard(context, title: 'PDS Host', value: pdsUrl),
          const SizedBox(height: 24),
          Text('Quick Actions', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('Browse My Repository'),
              subtitle: const Text('Explore collections and records'),
              trailing: const Icon(Icons.chevron_right),
              onTap: authState is AuthStateAuthenticated
                  ? () => context.pushNamed(
                      AppRouteNames.devToolsCollections,
                      pathParameters: {'did': authState.session.did},
                    )
                  : null,
              enabled: authState is AuthStateAuthenticated,
            ),
          ),
          const SizedBox(height: 24),
          _OtherRepoInspector(),
          const SizedBox(height: 24),
          _RecentRecordsList(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String value,
    IconData? actionIcon,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (actionIcon != null && onAction != null)
                  IconButton(
                    icon: Icon(actionIcon, size: 20),
                    onPressed: onAction,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _OtherRepoInspector extends ConsumerStatefulWidget {
  @override
  ConsumerState<_OtherRepoInspector> createState() => _OtherRepoInspectorState();
}

class _OtherRepoInspectorState extends ConsumerState<_OtherRepoInspector> {
  final _controller = TextEditingController();
  bool _isResolving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBrowse() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isResolving = true;
      _error = null;
    });

    try {
      final did = await ref.read(resolvedDidProvider(input).future);
      if (!mounted) return;

      if (did != null) {
        await context.pushNamed(AppRouteNames.devToolsCollections, pathParameters: {'did': did});
      } else {
        setState(() => _error = 'Could not resolve handle or DID');
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Browse Other Repository', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'DID or Handle',
                    hintText: 'e.g. alice.bsky.social or did:plc:...',
                    suffixIcon: _isResolving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(icon: const Icon(Icons.search), onPressed: _handleBrowse),
                    errorText: _error,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _handleBrowse(),
                  enabled: !_isResolving,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isResolving ? null : _handleBrowse,
                    icon: const Icon(Icons.explore_outlined),
                    label: const Text('Inspect Repository'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentRecordsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentRecordsProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Records', style: theme.textTheme.titleMedium),
            if (recentAsync.value?.isNotEmpty ?? false)
              TextButton(
                onPressed: () => ref.read(appDatabaseProvider).devToolsDao.clearRecentRecords(),
                child: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        recentAsync.when(
          data: (records) {
            if (records.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No recent records',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }

            return Card(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: records.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final record = records[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.history_outlined),
                    title: Text(record.rkey, style: const TextStyle(fontFamily: 'monospace')),
                    subtitle: Text(
                      '${_formatCollection(record.collection)} • ${record.did.substring(0, 12)}...',
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 16),
                    onTap: () {
                      context.pushNamed(
                        AppRouteNames.devToolsRecord,
                        pathParameters: {
                          'did': record.did,
                          'collection': Uri.encodeComponent(record.collection),
                          'rkey': record.rkey,
                        },
                      );
                    },
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Error: $e'),
        ),
      ],
    );
  }

  String _formatCollection(String nsid) {
    return nsid.split('.').last;
  }
}
