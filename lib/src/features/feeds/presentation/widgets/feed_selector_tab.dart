import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/routes.dart';
import 'package:lazurite/src/core/animations/animation_utils.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/application/sync_status_provider.dart';

/// Tab widget for selecting between pinned feeds.
///
/// For authenticated users, shows their pinned feeds with a persistent
/// "Manage Feeds" button.
/// For unauthenticated users, hides the feed selector entirely.
class FeedSelectorTab extends ConsumerWidget {
  const FeedSelectorTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState is AuthStateAuthenticated;

    if (!isAuthenticated) {
      return _buildUnauthenticatedView();
    }

    return _buildAuthenticatedView(context, ref);
  }

  /// Builds the feed selector for unauthenticated users.
  /// Returns an empty widget since unauthenticated users don't need feed selection.
  Widget _buildUnauthenticatedView() {
    return const SizedBox.shrink();
  }

  /// Builds the feed selector for authenticated users.
  /// Shows pinned feeds with a persistent "Manage Feeds" button.
  Widget _buildAuthenticatedView(BuildContext context, WidgetRef ref) {
    final pinnedFeedsAsync = ref.watch(pinnedFeedsProvider);
    final activeFeedUri = ref.watch(activeFeedProvider);

    return pinnedFeedsAsync.when(
      data: (feeds) {
        final manageButton = _ManageFeedsButton();

        if (feeds.isEmpty) {
          return SizedBox(
            height: 48,
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Pin feeds to choose them here'),
                ),
                manageButton,
                const SizedBox(width: 8),
              ],
            ),
          );
        }

        return SizedBox(
          height: 48,
          child: Row(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(left: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: feeds.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final feed = feeds[index];
                    final isActive = feed.uri == activeFeedUri;

                    return FilterChip(
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
              ),
              manageButton,
              const SizedBox(width: 8),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

class _ManageFeedsButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPending = ref.watch(hasPendingSyncProvider).asData?.value ?? false;
    return Stack(
      alignment: Alignment.center,
      children: [
        Tooltip(
          message: 'Manage Feeds',
          child: ScaleButton(
            child: IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () {
                context.push(AppRoutes.feeds);
              },
            ),
          ),
        ),
        if (hasPending)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            ),
          ),
      ],
    );
  }
}
