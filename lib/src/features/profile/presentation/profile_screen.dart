import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/follow_button.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/profile_header.dart';

/// Profile screen showing the current user's profile.
class ProfileScreen extends ConsumerWidget {
  /// Creates a profile screen.
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState is! AuthStateAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Please sign in to view your profile')),
      );
    }

    final did = authState.session.did;

    return ProfilePageContent(did: did, isCurrentUser: true);
  }
}

/// Profile page for viewing any user's profile.
class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.did, super.key});

  final String did;

  @override
  Widget build(BuildContext context) {
    return ProfilePageContent(did: did, isCurrentUser: false);
  }
}

/// Shared content for profile screens.
class ProfilePageContent extends ConsumerWidget {
  const ProfilePageContent({required this.did, required this.isCurrentUser, super.key});

  final String did;
  final bool isCurrentUser;

  Widget _followButton(ProfileData p) => _ProfileFollowButton(
    subjectDid: p.did,
    isFollowing: p.viewerFollowing,
    followUri: p.viewerFollowUri,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(did));
    final feedAsync = ref.watch(authorFeedProvider(did));

    return profileAsync.when(
      data: (profile) {
        final hasMore = ref.read(authorFeedProvider(did).notifier).hasMore;

        return Scaffold(
          appBar: AppBar(
            title: Text(profile.displayNameOrHandle),
            actions: [
              if (isCurrentUser)
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push('/settings'),
                ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // TODO: Show more options
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await ref.read(profileProvider(did).notifier).refresh();
              await ref.read(authorFeedProvider(did).notifier).refresh();
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ProfileHeader(
                    profile: profile,
                    onFollowersPressed: () {
                      final encodedDid = Uri.encodeComponent(profile.did);
                      context.push('/profile/followers/$encodedDid');
                    },
                    onFollowingPressed: () {
                      final encodedDid = Uri.encodeComponent(profile.did);
                      context.push('/profile/following/$encodedDid');
                    },
                    followButton: isCurrentUser ? null : _followButton(profile),
                  ),
                ),
                feedAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const SliverFillRemaining(child: Center(child: Text('No posts yet')));
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index >= items.length) {
                          if (hasMore) {
                            ref.read(authorFeedProvider(did).notifier).loadMore();
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return null;
                        }

                        final item = items[index];
                        return _PostCard(item: item);
                      }, childCount: items.length + (hasMore ? 1 : 0)),
                    );
                  },
                  loading: () => const SliverFillRemaining(child: LoadingView()),
                  error: (err, _) {
                    return SliverFillRemaining(
                      child: Center(child: Text('Error loading posts: $err')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const LoadingView(),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: ErrorView(
          title: 'Failed to load profile',
          message: error.toString(),
          onRetry: () => ref.read(profileProvider(did).notifier).refresh(),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        final encodedUri = Uri.encodeComponent(item.uri);
        GoRouter.of(context).push('/home/t/$encodedUri');
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.text,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ActionItem(icon: Icons.chat_bubble_outline, count: item.replyCount),
                    const SizedBox(width: 24),
                    _ActionItem(icon: Icons.repeat, count: item.repostCount),
                    const SizedBox(width: 24),
                    _ActionItem(icon: Icons.favorite_outline, count: item.likeCount),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurface.withAlpha(153)),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
        ],
      ],
    );
  }
}

/// Follow button that connects to the FollowNotifier for mutations.
class _ProfileFollowButton extends ConsumerWidget {
  const _ProfileFollowButton({
    required this.subjectDid,
    required this.isFollowing,
    this.followUri,
  });

  final String subjectDid;
  final bool isFollowing;
  final String? followUri;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followState = ref.watch(followProvider);
    final isLoading = followState.isLoading;

    final authState = ref.watch(authProvider);
    final isDisabled = authState is! AuthStateAuthenticated;

    return FollowButton(
      isFollowing: isFollowing,
      isLoading: isLoading,
      isDisabled: isDisabled,
      onPressed: () {
        if (isFollowing && followUri != null) {
          ref.read(followProvider.notifier).unfollow(subjectDid, followUri!);
        } else {
          ref.read(followProvider.notifier).follow(subjectDid);
        }
      },
    );
  }
}
