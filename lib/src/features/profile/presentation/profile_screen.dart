import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/feed_post_card.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/follow_button.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/media_tab.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/profile_header.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/replies_tab.dart';

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

/// Shared content for profile screens with tabbed feed views.
class ProfilePageContent extends ConsumerStatefulWidget {
  const ProfilePageContent({required this.did, required this.isCurrentUser, super.key});

  final String did;
  final bool isCurrentUser;

  @override
  ConsumerState<ProfilePageContent> createState() => _ProfilePageContentState();
}

class _ProfilePageContentState extends ConsumerState<ProfilePageContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _followButton(ProfileData p) => _ProfileFollowButton(
    subjectDid: p.did,
    isFollowing: p.viewerFollowing,
    followUri: p.viewerFollowUri,
  );

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider(widget.did));
    final feedAsync = ref.watch(authorFeedProvider(widget.did));

    return profileAsync.when(
      data: (profile) {
        final hasMore = ref.read(authorFeedProvider(widget.did).notifier).hasMore;

        return Scaffold(
          appBar: AppBar(
            title: Text(profile.displayNameOrHandle),
            actions: [
              if (widget.isCurrentUser)
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
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Posts'),
                Tab(text: 'Replies'),
                Tab(text: 'Media'),
              ],
            ),
          ),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
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
                    followButton: widget.isCurrentUser ? null : _followButton(profile),
                  ),
                ),
              ];
            },
            body: feedAsync.when(
              data: (items) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _PostsTab(
                      items: items.where((item) => !item.isReply).toList(),
                      hasMore: hasMore,
                      isLoading: false,
                      onLoadMore: () =>
                          ref.read(authorFeedProvider(widget.did).notifier).loadMore(),
                      onRefresh: () async {
                        await ref.read(profileProvider(widget.did).notifier).refresh();
                        await ref.read(authorFeedProvider(widget.did).notifier).refresh();
                      },
                    ),
                    RepliesTab(
                      items: items,
                      hasMore: hasMore,
                      isLoading: false,
                      onLoadMore: () =>
                          ref.read(authorFeedProvider(widget.did).notifier).loadMore(),
                      onRefresh: () async {
                        await ref.read(profileProvider(widget.did).notifier).refresh();
                        await ref.read(authorFeedProvider(widget.did).notifier).refresh();
                      },
                    ),
                    MediaTab(
                      items: items,
                      hasMore: hasMore,
                      isLoading: false,
                      onLoadMore: () =>
                          ref.read(authorFeedProvider(widget.did).notifier).loadMore(),
                      onRefresh: () async {
                        await ref.read(profileProvider(widget.did).notifier).refresh();
                        await ref.read(authorFeedProvider(widget.did).notifier).refresh();
                      },
                    ),
                  ],
                );
              },
              loading: () => const LoadingView(),
              error: (err, _) => Center(child: Text('Error loading posts: $err')),
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
          onRetry: () => ref.read(profileProvider(widget.did).notifier).refresh(),
        ),
      ),
    );
  }
}

/// Posts tab showing author's posts (excluding replies).
class _PostsTab extends StatefulWidget {
  const _PostsTab({
    required this.items,
    required this.hasMore,
    required this.isLoading,
    required this.onLoadMore,
    required this.onRefresh,
  });

  final List<FeedItem> items;
  final bool hasMore;
  final bool isLoading;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;

  @override
  State<_PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<_PostsTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.items.isEmpty && !widget.isLoading) {
      return const Center(child: Text('No posts yet'));
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= widget.items.length) {
            widget.onLoadMore();
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final item = widget.items[index];
          return FeedPostCard(
            uri: item.uri,
            authorDid: item.authorDid,
            authorHandle: item.authorHandle,
            authorDisplayName: item.authorDisplayName,
            authorAvatar: item.authorAvatar,
            text: item.text,
            indexedAt: item.indexedAt,
            replyCount: item.replyCount,
            repostCount: item.repostCount,
            likeCount: item.likeCount,
            onTap: () {
              final encodedUri = Uri.encodeComponent(item.uri);
              GoRouter.of(context).push('/home/t/$encodedUri');
            },
            onAvatarTap: () {
              final encodedDid = Uri.encodeComponent(item.authorDid);
              GoRouter.of(context).push('/home/u/$encodedDid');
            },
          );
        },
      ),
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
