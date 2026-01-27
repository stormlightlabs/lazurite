import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/app/routes.dart';
import 'package:lazurite/src/core/utils/error_message.dart';
import 'package:lazurite/src/features/developer_tools/application/devtools_providers.dart';
import 'package:lazurite/src/features/developer_tools/domain/repo_collection.dart';

class CollectionsPage extends ConsumerStatefulWidget {
  const CollectionsPage({required this.did, super.key});

  final String did;

  @override
  ConsumerState<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends ConsumerState<CollectionsPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget? _buildSuffixIcon(bool notEmpty) {
    if (notEmpty) {
      return IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          _searchController.clear();
          setState(() => _searchQuery = '');
        },
      );
    }
    return null;
  }

  Widget _buildEmptyView(bool isEmpty, TextTheme textTheme, ColorScheme colorScheme) {
    return Center(
      child: Text(
        isEmpty ? 'No collections found' : 'No collections matching "$_searchQuery"',
        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final collectionsAsync = ref.watch(filteredCollectionsProvider(widget.did, _searchQuery));
    final pinnedUrisAsync = ref.watch(pinnedUrisProvider);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/devtools'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search collections...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _buildSuffixIcon(_searchQuery.isNotEmpty),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: collectionsAsync.when(
              data: (collections) {
                if (collections.isEmpty) {
                  return _buildEmptyView(_searchQuery.isEmpty, textTheme, colorScheme);
                }

                return pinnedUrisAsync.when(
                  data: (pinnedUris) => ListView.builder(
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      final collection = collections[index];
                      return _CollectionTile(
                        did: widget.did,
                        collection: collection,
                        isPinned: pinnedUris.contains(collection.nsid),
                      );
                    },
                  ),
                  loading: () => ListView.builder(
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      return _CollectionTile(did: widget.did, collection: collections[index]);
                    },
                  ),
                  error: (error, stack) => ListView.builder(
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      return _CollectionTile(did: widget.did, collection: collections[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildAsyncErrorView(error, stack, textTheme, colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsyncErrorView(
    Object error,
    StackTrace stack,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to load collections', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              errorMessage(error),
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionTile extends ConsumerWidget {
  const _CollectionTile({required this.did, required this.collection, this.isPinned = false});

  final String did;
  final RepoCollection collection;
  final bool isPinned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListTile(
      title: Text(collection.nsid),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: isPinned ? theme.colorScheme.primary : null,
            ),
            onPressed: () async {
              final db = ref.read(appDatabaseProvider);
              if (isPinned) {
                await db.devToolsDao.deletePin(collection.nsid);
              } else {
                await db.devToolsDao.savePin(uri: collection.nsid, type: 'collection');
              }
            },
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () {
        context.goNamed(
          AppRouteNames.devToolsRecords,
          pathParameters: {'did': did, 'collection': Uri.encodeComponent(collection.nsid)},
        );
      },
    );
  }
}
