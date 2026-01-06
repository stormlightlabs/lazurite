import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/routes.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/application/sync_status_provider.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_repository.dart';

/// Tab widget for selecting between pinned feeds.
///
/// For authenticated users, shows their pinned feeds plus a "Manage Feeds" button.
/// For unauthenticated users, shows only the "Discover" feed chip.
class FeedSelectorTab extends ConsumerWidget {
  const FeedSelectorTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState is AuthStateAuthenticated;

    if (!isAuthenticated) {
      return _buildUnauthenticatedView(context, ref);
    }

    return _buildAuthenticatedView(context, ref);
  }

  /// Builds the feed selector for unauthenticated users.
  /// Shows only the "Discover" chip with no management options.
  Widget _buildUnauthenticatedView(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            ChoiceChip(
              showCheckmark: false,
              label: const Text('Discover'),
              selected: true,
              onSelected: (_) => (),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the feed selector for authenticated users.
  /// Shows pinned feeds and a "Manage Feeds" button.
  Widget _buildAuthenticatedView(BuildContext context, WidgetRef ref) {
    final pinnedFeedsAsync = ref.watch(pinnedFeedsProvider);
    final activeFeedUri = ref.watch(activeFeedProvider);

    return pinnedFeedsAsync.when(
      data: (feeds) {
        final displayFeeds = feeds.isEmpty
            ? [
                SavedFeedData(
                  uri: FeedRepository.kHomeFeedUri,
                  displayName: 'Home',
                  creatorDid: '',
                  likeCount: 0,
                  sortOrder: 0,
                  isPinned: true,
                  lastSynced: DateTime.now(),
                ),
              ]
            : feeds;

        return SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: displayFeeds.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == displayFeeds.length) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.tune),
                      tooltip: 'Manage Feeds',
                      onPressed: () {
                        context.push(AppRoutes.feeds);
                      },
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        final hasPending =
                            ref.watch(hasPendingSyncProvider).asData?.value ?? false;
                        if (hasPending) {
                          return Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                );
              }

              final feed = displayFeeds[index];
              final isActive = feed.uri == activeFeedUri;

              return ChoiceChip(
                showCheckmark: false,
                label: Text(feed.displayName),
                avatar: feed.avatar != null
                    ? CircleAvatar(backgroundImage: NetworkImage(feed.avatar!))
                    : null,
                selected: isActive,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(activeFeedProvider.notifier).switchFeed(feed.uri);
                  }
                },
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
