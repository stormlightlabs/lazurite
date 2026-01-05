import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/application/sync_status_provider.dart';

class FeedManagementScreen extends ConsumerWidget {
  const FeedManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsState = ref.watch(allFeedsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Feeds'),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final hasPending = ref.watch(hasPendingSyncProvider).asData?.value ?? false;
              if (hasPending) {
                return const Tooltip(
                  message: 'Syncing preferences...',
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.sync, size: 20),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/feeds/discover'),
          ),
        ],
      ),
      body: appsState.when(
        data: (feeds) {
          if (feeds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No saved feeds.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/feeds/discover'),
                    child: const Text('Discover Feeds'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: feeds.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final feed = feeds[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: feed.avatar != null ? NetworkImage(feed.avatar!) : null,
                  child: feed.avatar == null ? const Icon(Icons.rss_feed) : null,
                ),
                title: Text(feed.displayName),
                subtitle: Text(feed.isPinned ? 'Pinned' : 'Saved'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(feed.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                      onPressed: () => ref
                          .read(feedMutationProvider.notifier)
                          .saveFeed(feed.uri, pin: !feed.isPinned),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          ref.read(feedMutationProvider.notifier).removeFeed(feed.uri),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const LoadingView(),
        error: (err, stack) => ErrorView(
          title: 'Failed to load feeds',
          message: err.toString(),
          onRetry: () {
            ref.invalidate(allFeedsProvider);
          },
        ),
      ),
    );
  }
}
