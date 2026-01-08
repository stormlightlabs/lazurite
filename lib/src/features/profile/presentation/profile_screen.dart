import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/routes.dart';
import 'package:lazurite/src/core/constants/layout_constants.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/feed_post_card.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/follow_button.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/media_tab.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/pinned_post_card.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/profile_actions_sheet.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/profile_header.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/replies_tab.dart';

/// Profile screen showing the current user's profile.
class ProfileScreen extends ConsumerWidget {
  /// Creates a profile screen.
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return switch (authState) {
      AuthStateAuthenticated(:final session) => ProfilePageContent(
        did: session.did,
        isCurrentUser: true,
      ),
      AuthStateLoading() => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const LoadingView(),
      ),
      AuthStateError(:final error) => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(child: Text('Authentication error: $error')),
      ),
      _ => const _SignInRequiredView(),
    };
  }
}

class _SignInRequiredView extends StatelessWidget {
  const _SignInRequiredView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Sign in to view your profile',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Login to sync your posts, followers, and saved preferences.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('Sign in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Future<void> _showMoreOptions(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => ProfileActionsSheet(did: widget.did, isCurrentUser: widget.isCurrentUser),
    );
  }

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
                onPressed: () => _showMoreOptions(context),
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
          body: RefreshIndicator(
            onRefresh: () async {
              await ref.read(profileProvider(widget.did).notifier).refresh();
              await ref.read(authorFeedProvider(widget.did).notifier).refresh();
            },
            edgeOffset: kRefreshIndicatorEdgeOffset,
            displacement: kRefreshIndicatorDisplacement,
            child: NestedScrollView(
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
                        items: items
                            .where(
                              (item) =>
                                  !item.isReply &&
                                  (profile.pinnedPostUri == null ||
                                      item.uri != profile.pinnedPostUri),
                            )
                            .toList(),
                        pinnedPostUri: profile.pinnedPostUri,
                        hasMore: hasMore,
                        isLoading: false,
                        onLoadMore: () =>
                            ref.read(authorFeedProvider(widget.did).notifier).loadMore(),
                      ),
                      RepliesTab(
                        items: items,
                        hasMore: hasMore,
                        isLoading: false,
                        onLoadMore: () =>
                            ref.read(authorFeedProvider(widget.did).notifier).loadMore(),
                      ),
                      MediaTab(
                        items: items,
                        hasMore: hasMore,
                        isLoading: false,
                        onLoadMore: () =>
                            ref.read(authorFeedProvider(widget.did).notifier).loadMore(),
                      ),
                    ],
                  );
                },
                loading: () => const LoadingView(),
                error: (err, _) => Center(child: Text('Error loading posts: $err')),
              ),
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
    this.pinnedPostUri,
    required this.hasMore,
    required this.isLoading,
    required this.onLoadMore,
  });

  final List<FeedItem> items;
  final String? pinnedPostUri;
  final bool hasMore;
  final bool isLoading;
  final VoidCallback onLoadMore;

  @override
  State<_PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<_PostsTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.items.isEmpty && !widget.isLoading && widget.pinnedPostUri == null) {
      return const Center(child: Text('No posts yet'));
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount:
          widget.items.length + (widget.hasMore ? 1 : 0) + (widget.pinnedPostUri != null ? 1 : 0),
      itemBuilder: (context, index) {
        int itemIndex = index;

        if (widget.pinnedPostUri != null) {
          if (index == 0) {
            return PinnedPostCard(widget.pinnedPostUri!);
          }
          itemIndex--;
        }

        if (itemIndex >= widget.items.length) {
          widget.onLoadMore();
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final item = widget.items[itemIndex];
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
