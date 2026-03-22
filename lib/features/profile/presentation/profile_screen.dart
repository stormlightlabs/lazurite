import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart' as bsky_graph;
import 'package:bluesky/moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/core/theme/feed_architecture.dart';
import 'package:lazurite/core/widgets/sliver_tab_bar_delegate.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/compose/presentation/compose_route_args.dart';
import 'package:lazurite/features/feed/bloc/feed_bloc.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/features/lists/cubit/add_to_list_cubit.dart';
import 'package:lazurite/features/lists/cubit/my_lists_cubit.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:lazurite/features/lists/presentation/widgets/list_row_tile.dart';
import 'package:lazurite/features/starter_packs/cubit/actor_starter_packs_cubit.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';
import 'package:lazurite/features/starter_packs/presentation/widgets/starter_pack_card.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_avatar.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderation_badge_row.dart';
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/profile/cubit/profile_action_cubit.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';
import 'package:lazurite/features/profile/presentation/widgets/profile_action_buttons.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const _greyscale = ColorFilter.matrix(<double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.actor, this.showBackButton = false});

  final String? actor;
  final bool showBackButton;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  static const _feedTabs = [
    (label: 'Posts', filter: FeedFilter.postsNoReplies),
    (label: 'Replies', filter: FeedFilter.postsAndAuthorThreads),
    (label: 'Media', filter: FeedFilter.postsWithMedia),
  ];

  static const _tabLabels = ['POSTS', 'REPLIES', 'MEDIA', 'LISTS', 'PACKS'];

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
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
    if (actor == null) return;
    context.read<ProfileBloc>().add(ProfileLoadRequested(actor: actor));
    context.read<FeedBloc>().add(FeedLoadRequested(actor: actor, filter: filter ?? _currentFilter));
  }

  String? get _resolvedActor {
    final authState = context.read<AuthBloc>().state;
    if (!authState.isAuthenticated) return null;
    return widget.actor ?? authState.tokens?.did;
  }

  FeedFilter get _currentFilter => _feedTabs[_tabController.index < _feedTabs.length ? _tabController.index : 0].filter;

  String _appBarTitle(ProfileViewDetailed? profile) {
    final authState = context.read<AuthBloc>().state;
    return profile?.displayName ?? profile?.handle ?? widget.actor ?? authState.tokens?.handle ?? 'Profile';
  }

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
                      floating: true,
                      pinned: true,
                      snap: true,
                      title: Text(_appBarTitle(profile)),
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
                    SliverToBoxAdapter(child: _buildCoverSection(context, profile)),
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
                      delegate: SliverTabBarDelegate(
                        TabBar(
                          controller: _tabController,
                          tabs: [for (final label in _tabLabels) Tab(text: label)],
                          onTap: (index) {
                            if (index < _feedTabs.length) {
                              _loadProfileAndFeed(filter: _feedTabs[index].filter);
                            }
                          },
                          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2.2),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.2,
                          ),
                          indicatorWeight: 2,
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    for (var i = 0; i < _feedTabs.length; i++) _buildFeedList(feedState, _feedTabs[i].filter, profile),
                    _buildListsTab(context, profile),
                    _buildStarterPacksTab(context, profile),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _buildComposeFab(context),
    );
  }

  Widget _buildCoverSection(BuildContext context, ProfileViewDetailed? profile) {
    final width = MediaQuery.of(context).size.width;
    final coverHeight = width >= 600 ? 256.0 : 192.0;
    final avatarSize = width >= 600 ? 128.0 : 96.0;
    final colorScheme = Theme.of(context).colorScheme;

    Widget coverContent;
    if (profile?.banner != null) {
      coverContent = ColorFiltered(
        colorFilter: _greyscale,
        child: Image.network(
          profile!.banner!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: coverHeight,
          errorBuilder: (_, _, _) =>
              ColoredBox(color: colorScheme.surfaceContainerHigh, child: const SizedBox.expand()),
        ),
      );
    } else {
      coverContent = ColoredBox(color: colorScheme.surfaceContainerHigh, child: const SizedBox.expand());
    }

    return SizedBox(
      height: coverHeight + avatarSize / 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: coverHeight,
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
              ),
              child: Opacity(opacity: 0.5, child: coverContent),
            ),
          ),
          Positioned(
            top: coverHeight - avatarSize / 2,
            left: 16,
            child: _buildSquareAvatar(context, profile, avatarSize),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareAvatar(BuildContext context, ProfileViewDetailed? profile, double size) {
    final colorScheme = Theme.of(context).colorScheme;
    final moderationService = maybeModerationService(context);
    final avatarUi = profile == null
        ? const bsky_moderation.ModerationUI()
        : moderationService?.profileDetailedUi(profile, bsky_moderation.ModerationBehaviorContext.avatar) ??
              const bsky_moderation.ModerationUI();

    return SizedBox(
      key: const ValueKey('profile_square_avatar'),
      width: size,
      height: size,
      child: ModeratedAvatar(
        size: size,
        ui: avatarUi,
        imageUrl: profile?.avatar,
        initials: _initials(profile?.displayName ?? profile?.handle ?? '?'),
        shape: BoxShape.rectangle,
        border: Border.all(color: colorScheme.surfaceContainerLowest, width: 4),
        placeholderTextStyle: Theme.of(context).textTheme.headlineSmall,
      ),
    );
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
    if (profile == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final moderationService = maybeModerationService(context);
    final profileUi =
        moderationService?.profileDetailedUi(profile, bsky_moderation.ModerationBehaviorContext.profileView) ??
        const bsky_moderation.ModerationUI();

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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (profile.displayName ?? profile.handle).toUpperCase(),
            style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),

          Text('@${profile.handle}', style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
          if (profileUi.alert || profileUi.inform) ...[const SizedBox(height: 10), ModerationBadgeRow(ui: profileUi)],
          if (profile.description?.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),

            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Text(profile.description!, style: textTheme.bodyMedium),
            ),
          ],
          if (metaChildren.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: metaChildren),
          ],
          const SizedBox(height: 16),
          Container(
            key: const ValueKey('profile_stats_row'),
            decoration: BoxDecoration(
              border: Border.symmetric(horizontal: BorderSide(color: colorScheme.outlineVariant)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                _buildStat(context, profile.followsCount ?? 0, 'Following'),
                const SizedBox(width: 24),
                _buildStat(context, profile.followersCount ?? 0, 'Followers'),
                const SizedBox(width: 24),
                _buildStat(context, profile.postsCount ?? 0, 'Posts'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (isOwnProfile)
            OutlinedButton.icon(
              onPressed: () => context.push('/saved'),
              icon: const Icon(Icons.bookmark_outline),
              label: const Text('Saved Posts'),
            ),
          if (!isOwnProfile) _buildProfileActions(context, profile),
          const SizedBox(height: 16),
        ],
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

    if (onTap == null) return chip;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(999), child: chip);
  }

  Widget _buildStat(BuildContext context, int count, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatCount(count),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 11, letterSpacing: 1.1, color: colorScheme.onSurfaceVariant),
        ),
      ],
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
          onAddToList: () => _showAddToList(context, profile),
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
            ListTile(
              leading: const Icon(Icons.playlist_add_outlined),
              title: const Text('Add to list'),
              onTap: () {
                Navigator.pop(sheetContext);
                _showAddToList(context, profile);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToList(BuildContext context, ProfileViewDetailed profile) {
    ListRepository? listRepository;
    try {
      listRepository = context.read<ListRepository>();
    } catch (_) {
      return;
    }

    final currentUserDid = context.read<AuthBloc>().state.tokens?.did ?? '';
    final cubit = AddToListCubit(listRepository: listRepository, currentUserDid: currentUserDid)
      ..load(targetDid: profile.did);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (_, scrollController) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Add to list',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: BlocBuilder<AddToListCubit, AddToListState>(
                  builder: (context, state) {
                    if (state.status == AddToListStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == AddToListStatus.error) {
                      return Center(child: Text(state.errorMessage ?? 'Failed to load lists'));
                    }

                    if (state.lists.isEmpty) {
                      return const Center(child: Text('No lists yet'));
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: state.lists.length,
                      itemBuilder: (context, index) {
                        final entry = state.lists[index];
                        final isMember = entry.listItem != null;
                        final isToggling = state.togglingUris.contains(entry.list.uri.toString());

                        return ListRowTile(
                          list: entry.list,
                          trailing: isToggling
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                              : Icon(
                                  isMember ? Icons.check_circle : Icons.add_circle_outline,
                                  color: isMember
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          onTap: isToggling ? null : () => context.read<AddToListCubit>().toggleMembership(entry),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(cubit.close);
  }

  Widget? _buildComposeFab(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        if (profile == null) return const SizedBox.shrink();

        final currentUserDid = context.read<AuthBloc>().state.tokens?.did;
        final isOwnProfile = profile.did == currentUserDid;
        final initialText = isOwnProfile ? null : '@${profile.handle} ';

        return FloatingActionButton(
          heroTag: 'profile-compose-fab',
          onPressed: () => context.push('/compose', extra: ComposeRouteArgs(initialText: initialText)),
          child: const Icon(Icons.add),
        );
      },
    );
  }

  Widget _buildFeedList(FeedState feedState, FeedFilter tabFilter, ProfileViewDetailed? profile) {
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

    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.feedArchitecture != curr.feedArchitecture,
      builder: (context, settingsState) {
        if (settingsState.feedArchitecture == FeedArchitecture.grid) {
          return _buildGridFeed(context, feedState);
        }
        return _buildLinearFeed(context, feedState);
      },
    );
  }

  Widget _buildGridFeed(BuildContext context, FeedState feedState) {
    final accountDid = _resolvedActor ?? '';

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
          key: const ValueKey('profile_grid_feed'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: feedState.posts.length + (feedState.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= feedState.posts.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return Padding(
              padding: EdgeInsets.only(bottom: index == feedState.posts.length - 1 ? 0 : 16),
              child: Center(
                child: ConstrainedBox(
                  key: ValueKey('profile_large_card_$index'),
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: PostCardWithActions(
                    feedViewPost: feedState.posts[index],
                    accountDid: accountDid,
                    variant: PostCardVariant.grid,
                    moderationContext: bsky_moderation.ModerationBehaviorContext.contentList,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLinearFeed(BuildContext context, FeedState feedState) {
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
            return PostCardWithActions(
              feedViewPost: feedState.posts[index],
              accountDid: _resolvedActor ?? '',
              moderationContext: bsky_moderation.ModerationBehaviorContext.contentList,
            );
          },
        ),
      ),
    );
  }

  Widget _buildListsTab(BuildContext context, ProfileViewDetailed? profile) {
    final actor = profile?.did ?? _resolvedActor;
    if (actor == null) return const SizedBox.shrink();

    ListRepository? listRepository;
    try {
      listRepository = context.read<ListRepository>();
    } catch (_) {
      return const SizedBox.shrink();
    }

    return _ProfileListsPane(actor: actor, listRepository: listRepository);
  }

  Widget _buildStarterPacksTab(BuildContext context, ProfileViewDetailed? profile) {
    final actor = profile?.did ?? _resolvedActor;
    if (actor == null) return const SizedBox.shrink();

    StarterPackRepository? starterPackRepository;
    try {
      starterPackRepository = context.read<StarterPackRepository>();
    } catch (_) {
      return const SizedBox.shrink();
    }

    return _ProfileStarterPacksPane(actor: actor, starterPackRepository: starterPackRepository);
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
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  Future<void> _launchWebsite(String website) async {
    final uri = Uri.tryParse(website.startsWith('http') ? website : 'https://$website');
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Pane that loads and displays starter packs for a given [actor] within the profile screen.
class _ProfileStarterPacksPane extends StatefulWidget {
  const _ProfileStarterPacksPane({required this.actor, required this.starterPackRepository});

  final String actor;
  final StarterPackRepository starterPackRepository;

  @override
  State<_ProfileStarterPacksPane> createState() => _ProfileStarterPacksPaneState();
}

class _ProfileStarterPacksPaneState extends State<_ProfileStarterPacksPane> {
  late final ActorStarterPacksCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ActorStarterPacksCubit(starterPackRepository: widget.starterPackRepository)..load(actor: widget.actor);
  }

  @override
  void didUpdateWidget(_ProfileStarterPacksPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actor != widget.actor) {
      _cubit.load(actor: widget.actor);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActorStarterPacksCubit, ActorStarterPacksState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state.status == ActorStarterPacksStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == ActorStarterPacksStatus.error) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.errorMessage ?? 'Failed to load starter packs'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => _cubit.load(actor: widget.actor),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.starterPacks.isEmpty) {
          return const Center(child: Text('No starter packs yet'));
        }

        return RefreshIndicator(
          onRefresh: _cubit.refresh,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.starterPacks.length,
            itemBuilder: (context, index) => StarterPackCard(
              key: ValueKey(state.starterPacks[index].uri),
              pack: state.starterPacks[index],
              onTap: () =>
                  context.push('/starter-pack?uri=${Uri.encodeComponent(state.starterPacks[index].uri.toString())}'),
            ),
          ),
        );
      },
    );
  }
}

/// Pane that loads and displays lists for a given [actor] within the profile screen.
class _ProfileListsPane extends StatefulWidget {
  const _ProfileListsPane({required this.actor, required this.listRepository});

  final String actor;
  final ListRepository listRepository;

  @override
  State<_ProfileListsPane> createState() => _ProfileListsPaneState();
}

class _ProfileListsPaneState extends State<_ProfileListsPane> {
  late final MyListsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = MyListsCubit(listRepository: widget.listRepository)..load(actor: widget.actor);
  }

  @override
  void didUpdateWidget(_ProfileListsPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actor != widget.actor) {
      _cubit.load(actor: widget.actor);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyListsCubit, MyListsState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state.status == MyListsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == MyListsStatus.error) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.errorMessage ?? 'Failed to load lists'),
                const SizedBox(height: 12),
                FilledButton(onPressed: () => _cubit.refresh(), child: const Text('Retry')),
              ],
            ),
          );
        }

        final lists = state.lists
            .where((l) {
              final purpose = l.purpose.knownValue;
              return purpose == bsky_graph.KnownListPurpose.appBskyGraphDefsCuratelist ||
                  purpose == bsky_graph.KnownListPurpose.appBskyGraphDefsModlist;
            })
            .toList(growable: false);

        if (lists.isEmpty) {
          return const Center(child: Text('No lists yet'));
        }

        return RefreshIndicator(
          onRefresh: _cubit.refresh,
          child: ListView.builder(
            itemCount: lists.length,
            itemBuilder: (context, index) => ListRowTile(
              key: ValueKey(lists[index].uri),
              list: lists[index],
              onTap: () => context.push('/list?uri=${Uri.encodeComponent(lists[index].uri.toString())}'),
            ),
          ),
        );
      },
    );
  }
}
