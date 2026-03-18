import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/feed/bloc/feed_bloc.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/profile/cubit/profile_action_cubit.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';
import 'package:lazurite/features/profile/presentation/widgets/profile_action_buttons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.actor, this.showBackButton = false});

  final String? actor;
  final bool showBackButton;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  static const double _headerExpandedHeight = 120;
  static const _tabs = [
    (label: 'Posts', filter: FeedFilter.postsNoReplies),
    (label: 'Replies', filter: FeedFilter.postsAndAuthorThreads),
    (label: 'Media', filter: FeedFilter.postsWithMedia),
  ];

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadProfileAndFeed();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actor != widget.actor) {
      _tabController.index = 0;
      _loadProfileAndFeed();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadProfileAndFeed({FeedFilter? filter}) {
    final actor = _resolvedActor;
    if (actor == null) {
      return;
    }

    context.read<ProfileBloc>().add(ProfileLoadRequested(actor: actor));
    context.read<FeedBloc>().add(FeedLoadRequested(actor: actor, filter: filter ?? _currentFilter));
  }

  String? get _resolvedActor {
    final authState = context.read<AuthBloc>().state;
    if (!authState.isAuthenticated) {
      return null;
    }

    return widget.actor ?? authState.tokens?.did;
  }

  FeedFilter get _currentFilter => _tabs[_tabController.index].filter;

  Future<void> _refresh() async {
    context.read<ProfileBloc>().add(const ProfileRefreshRequested());
    context.read<FeedBloc>().add(const FeedRefreshRequested());
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          return BlocBuilder<FeedBloc, FeedState>(
            builder: (context, feedState) {
              final profile = profileState.profile;
              final currentUserDid = context.read<AuthBloc>().state.tokens?.did;
              final isOwnProfile = profile?.did == currentUserDid;

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: _headerExpandedHeight,
                      floating: true,
                      pinned: true,
                      snap: true,
                      stretch: true,
                      title: innerBoxIsScrolled ? Text(profile?.displayName ?? profile?.handle ?? 'Profile') : null,
                      flexibleSpace: FlexibleSpaceBar(background: _buildBanner(context, profile)),
                      leading: widget.showBackButton
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => context.canPop() ? context.pop() : context.go('/profile'),
                            )
                          : const AppShellMenuButton(),
                      actions: [
                        IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => context.go('/settings')),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: switch (profileState.status) {
                        ProfileStatus.loading => const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        ProfileStatus.error => _buildProfileError(context, profileState.errorMessage),
                        _ => _buildProfileSummary(context, profile, isOwnProfile),
                      },
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverTabBarDelegate(
                        TabBar(
                          controller: _tabController,
                          tabs: [for (final tab in _tabs) Tab(text: tab.label)],
                          onTap: (index) => _loadProfileAndFeed(filter: _tabs[index].filter),
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [for (var i = 0; i < _tabs.length; i++) _buildFeedList(feedState, _tabs[i].filter)],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBanner(BuildContext context, ProfileViewDetailed? profile) {
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surfaceContainerHighest,
            Theme.of(context).colorScheme.surfaceContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );

    if (profile?.banner == null) {
      return fallback;
    }

    return Image.network(profile!.banner!, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback);
  }

  Widget _buildProfileError(BuildContext context, String? errorMessage) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Unable to load profile', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(errorMessage ?? 'Unknown error', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          FilledButton(onPressed: _loadProfileAndFeed, child: const Text('Try again')),
        ],
      ),
    );
  }

  Widget _buildProfileSummary(BuildContext context, ProfileViewDetailed? profile, bool isOwnProfile) {
    if (profile == null) {
      return const SizedBox.shrink();
    }

    final metaChildren = <Widget>[
      if (profile.pronouns?.isNotEmpty ?? false)
        _buildMetaChip(context, Icons.record_voice_over_outlined, profile.pronouns!),
      if (profile.website?.isNotEmpty ?? false)
        _buildMetaChip(context, Icons.link_outlined, profile.website!, onTap: () => _launchWebsite(profile.website!)),
      if (profile.createdAt != null)
        _buildMetaChip(
          context,
          Icons.calendar_today_outlined,
          'Joined ${DateFormat.yMMMM().format(profile.createdAt!)}',
        ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(profile),
          const SizedBox(height: 16),
          Text(
            profile.displayName ?? profile.handle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '@${profile.handle}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          if (profile.description?.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            Text(profile.description!, style: Theme.of(context).textTheme.bodyLarge),
          ],
          if (metaChildren.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: metaChildren),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildStat(context, profile.followsCount ?? 0, 'Following'),
              _buildStat(context, profile.followersCount ?? 0, 'Followers'),
              _buildStat(context, profile.postsCount ?? 0, 'Posts'),
            ],
          ),
          if (isOwnProfile) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.push('/saved'),
              icon: const Icon(Icons.bookmark_outline),
              label: const Text('Saved Posts'),
            ),
          ],
          if (!isOwnProfile) ...[const SizedBox(height: 16), _buildProfileActions(context, profile)],
        ],
      ),
    );
  }

  Widget _buildAvatar(ProfileViewDetailed profile) {
    final avatarUrl = profile.avatar;

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 4),
      ),
      child: CircleAvatar(
        radius: 44,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null
            ? Text(_initials(profile.displayName ?? profile.handle), style: Theme.of(context).textTheme.headlineSmall)
            : null,
      ),
    );
  }

  Widget _buildMetaChip(BuildContext context, IconData icon, String label, {VoidCallback? onTap}) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return chip;
    }

    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(999), child: chip);
  }

  Widget _buildStat(BuildContext context, int count, String label) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          TextSpan(
            text: _formatCount(count),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: ' $label',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActions(BuildContext context, ProfileViewDetailed profile) {
    final viewer = profile.viewer;

    return BlocProvider(
      create: (context) => ProfileActionCubit(
        profileActionRepository: context.read<ProfileActionRepository>(),
        actorDid: profile.did,
        isFollowing: viewer?.following != null,
        isMuted: viewer?.muted ?? false,
        isBlocked: viewer?.blocking != null,
        isBlockedBy: viewer?.blockedBy ?? false,
        followUri: viewer?.following?.toString(),
        blockUri: viewer?.blocking?.toString(),
      ),
      child: BlocConsumer<ProfileActionCubit, ProfileActionState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!), behavior: SnackBarBehavior.floating));
            context.read<ProfileActionCubit>().clearError();
          }
        },
        builder: (context, state) => ProfileActionButtons(
          isFollowing: state.isFollowing,
          isMuted: state.isMuted,
          isBlocked: state.isBlocked,
          isBlockedBy: state.isBlockedBy,
          isLoadingFollow: state.isLoadingFollow,
          isLoadingMute: state.isLoadingMute,
          isLoadingBlock: state.isLoadingBlock,
          onFollow: () => context.read<ProfileActionCubit>().toggleFollow(),
          onUnfollow: () => context.read<ProfileActionCubit>().toggleFollow(),
          onMute: () => context.read<ProfileActionCubit>().toggleMute(),
          onUnmute: () => context.read<ProfileActionCubit>().toggleMute(),
          onBlock: () => context.read<ProfileActionCubit>().toggleBlock(),
          onUnblock: () => context.read<ProfileActionCubit>().toggleBlock(),
          onMore: () => _showProfileMoreOptions(context, profile),
        ),
      ),
    );
  }

  void _showProfileMoreOptions(BuildContext context, ProfileViewDetailed profile) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy DID'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: profile.did));
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('DID copied to clipboard'), behavior: SnackBarBehavior.floating),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Profile'),
              onTap: () {
                Navigator.pop(sheetContext);
                final url = 'https://bsky.app/profile/${profile.handle}';
                Share.share(url);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedList(FeedState feedState, FeedFilter tabFilter) {
    if (feedState.isLoading && feedState.filter == tabFilter) {
      return const Center(child: CircularProgressIndicator());
    }

    if (feedState.hasError && feedState.filter == tabFilter) {
      return Center(child: Text(feedState.errorMessage ?? 'Failed to load posts'));
    }

    if (feedState.filter != tabFilter) {
      return const SizedBox.shrink();
    }

    if (!feedState.hasPosts) {
      return Center(child: Text(_emptyLabel(tabFilter)));
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels > notification.metrics.maxScrollExtent - 300 &&
              feedState.hasMore &&
              !feedState.isLoadingMore) {
            context.read<FeedBloc>().add(const FeedLoadMoreRequested());
          }

          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: feedState.posts.length + (feedState.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= feedState.posts.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return PostCardWithActions(feedViewPost: feedState.posts[index], accountDid: _resolvedActor ?? '');
          },
        ),
      ),
    );
  }

  String _emptyLabel(FeedFilter filter) {
    switch (filter) {
      case FeedFilter.postsNoReplies:
        return 'No posts yet';
      case FeedFilter.postsAndAuthorThreads:
        return 'No replies or threads yet';
      case FeedFilter.postsWithMedia:
        return 'No media posts yet';
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }

    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }

    return '$count';
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  Future<void> _launchWebsite(String website) async {
    final uri = Uri.tryParse(website.startsWith('http') ? website : 'https://$website');
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(color: Theme.of(context).scaffoldBackgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
