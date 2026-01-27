import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/utils/error_message.dart';
import 'package:lazurite/src/core/widgets/widgets.dart';
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

          return ReorderableListView.builder(
            itemCount: feeds.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final reorderedUris = feeds.map((f) => f.uri).toList();
              final item = reorderedUris.removeAt(oldIndex);
              reorderedUris.insert(newIndex, item);
              ref.read(feedMutationProvider.notifier).reorder(reorderedUris);
            },
            proxyDecorator: (child, index, animation) => AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final elevation = lerpDouble(0, 8, animation.value)!;
                return Material(elevation: elevation, shadowColor: Colors.black26, child: child);
              },
              child: child,
            ),
            itemBuilder: (context, index) {
              final feed = feeds[index];
              return ListTile(
                key: ValueKey(feed.uri),
                leading: Avatar(imageUrl: feed.avatar, fallbackIcon: Icons.rss_feed, radius: 20),
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
                    ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
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
          message: errorMessage(err),
          onRetry: () => ref.invalidate(allFeedsProvider),
        ),
      ),
    );
  }
}
