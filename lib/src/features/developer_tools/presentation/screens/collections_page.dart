import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/features/developer_tools/application/devtools_providers.dart';
import 'package:lazurite/src/features/developer_tools/domain/repo_collection.dart';

class CollectionsPage extends ConsumerStatefulWidget {
  const CollectionsPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final collectionsAsync = ref.watch(filteredCollectionsProvider(_searchQuery));
    final pinnedUrisAsync = ref.watch(pinnedUrisProvider);

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
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: collectionsAsync.when(
              data: (collections) {
                if (collections.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No collections found'
                          : 'No collections matching "$_searchQuery"',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return pinnedUrisAsync.when(
                  data: (pinnedUris) => ListView.builder(
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      final collection = collections[index];
                      return _CollectionTile(
                        collection: collection,
                        isPinned: pinnedUris.contains(collection.nsid),
                      );
                    },
                  ),
                  loading: () => ListView.builder(
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      return _CollectionTile(collection: collections[index]);
                    },
                  ),
                  error: (error, stack) => ListView.builder(
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      return _CollectionTile(collection: collections[index]);
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
                      Text('Failed to load collections', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionTile extends ConsumerWidget {
  const _CollectionTile({required this.collection, this.isPinned = false});

  final RepoCollection collection;
  final bool isPinned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListTile(
      title: Text(collection.nsid),
      subtitle: Text(
        '${collection.count} ${collection.count == 1 ? 'record' : 'records'}',
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
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
        // TODO: Navigate to RecordsPage
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Opening ${collection.nsid}...')));
      },
    );
  }
}
