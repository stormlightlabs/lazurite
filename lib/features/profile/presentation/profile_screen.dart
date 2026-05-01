import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart' as bsky_graph;
import 'package:bluesky/moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/app_view_web_links.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/core/theme/animation_tokens.dart';
import 'package:lazurite/core/theme/animation_utils.dart';
import 'package:lazurite/core/theme/color_filters.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/core/theme/spacing.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/core/widgets/sliver_tab_bar_delegate.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/compose/presentation/compose_route_args.dart';
import 'package:lazurite/features/connectivity/connectivity_helpers.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/feed/bloc/feed_bloc.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/features/feed/presentation/widgets/facet_text.dart';
import 'package:lazurite/features/lists/cubit/add_to_list_cubit.dart';
import 'package:lazurite/features/lists/cubit/my_lists_cubit.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:lazurite/features/lists/presentation/widgets/list_row_tile.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_avatar.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderation_badge_row.dart';
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/profile/cubit/profile_action_cubit.dart';
import 'package:lazurite/features/profile/cubit/suggested_follows_cubit.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:lazurite/features/profile/presentation/widgets/profile_action_buttons.dart';
import 'package:lazurite/features/profile/presentation/widgets/suggested_follows_list.dart';
import 'package:lazurite/features/profile/presentation/widgets/suggested_follows_sheet.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:lazurite/features/starter_packs/cubit/actor_starter_packs_cubit.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';
import 'package:lazurite/features/starter_packs/presentation/widgets/starter_pack_card.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';
import 'package:lazurite/shared/presentation/helpers/share_helper.dart';
import 'package:lazurite/shared/presentation/helpers/snackbar_helper.dart';
import 'package:lazurite/shared/presentation/widgets/app_screen_entrance.dart';
import 'package:lazurite/shared/presentation/widgets/options_sheet.dart';
import 'package:lazurite/shared/utils/format_utils.dart';
import 'package:url_launcher/url_launcher.dart';

enum _ProfileFeedSlice { posts, replies, quotes, reposts, media }

class _ProfileFeedTabConfig {
  const _ProfileFeedTabConfig({
    required this.label,
    required this.requestFilter,
    required this.slice,
    required this.emptyLabel,
  });

  final String label;
  final FeedFilter requestFilter;
  final _ProfileFeedSlice slice;
  final String emptyLabel;
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.actor, this.showBackButton = false});

  final String? actor;
  final bool showBackButton;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  static const _feedTabs = [
    _ProfileFeedTabConfig(
      label: 'Posts',
      requestFilter: FeedFilter.postsNoReplies,
      slice: _ProfileFeedSlice.posts,
      emptyLabel: 'No posts yet',
    ),
    _ProfileFeedTabConfig(
      label: 'Replies',
      requestFilter: FeedFilter.postsWithReplies,
      slice: _ProfileFeedSlice.replies,
      emptyLabel: 'No replies yet',
    ),
    _ProfileFeedTabConfig(
      label: 'Quotes',
      requestFilter: FeedFilter.postsWithReplies,
      slice: _ProfileFeedSlice.quotes,
      emptyLabel: 'No quotes yet',
    ),
    _ProfileFeedTabConfig(
      label: 'Reposts',
      requestFilter: FeedFilter.postsWithReplies,
      slice: _ProfileFeedSlice.reposts,
      emptyLabel: 'No reposts yet',
    ),
    _ProfileFeedTabConfig(
      label: 'Media',
      requestFilter: FeedFilter.postsWithMedia,
      slice: _ProfileFeedSlice.media,
      emptyLabel: 'No media posts yet',
    ),
  ];

  static const _baseTabLabelsOwn = ['POSTS', 'REPLIES', 'QUOTES', 'REPOSTS', 'MEDIA', 'LISTS', 'STARTER PACKS'];
  static const _baseTabLabelsOther = [
    'POSTS',
    'REPLIES',
    'QUOTES',
    'REPOSTS',
    'MEDIA',
    'LIKED',
    'LISTS',
    'STARTER PACKS',
  ];
  static const _suggestedTabLabel = 'SUGGESTED';
  static const _coverRefreshTriggerDistance = 72.0;

  late TabController _tabController;
  final ScrollController _profileScrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _profileRefreshKey = GlobalKey<RefreshIndicatorState>();
  late bool _showSuggestedTab;
  double _coverScrollOffset = 0;
  int? _headerTrackingPointer;
  double _headerPullDistance = 0;
  bool _headerRefreshInFlight = false;
  String? _lastScheduledProfileActorLoad;
  String? _lastScheduledFeedLoadKey;
  String? _cachedFeedActor;
  final Map<FeedFilter, FeedState> _cachedFeedStates = {};

  bool get _isCurrentRoute => ModalRoute.of(context)?.isCurrent ?? true;

  @override
  void initState() {
    super.initState();
    _showSuggestedTab = _shouldShowSuggestedTab(context.read<ProfileBloc>().state.profile);
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _loadProfileAndFeed();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actor != widget.actor) {
      _tabController.index = 0;
      _cachedFeedActor = null;
      _cachedFeedStates.clear();
      _setSuggestedTabVisibility(false);
      _loadProfileAndFeed();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _profileScrollController.dispose();
    super.dispose();
  }

  void _loadProfileAndFeed({FeedFilter? filter}) {
    final actor = _resolvedActor;
    if (actor == null) return;
    _resetFeedCacheIfActorChanged(actor);
    context.read<ProfileBloc>().add(ProfileLoadRequested(actor: actor));
    context.read<FeedBloc>().add(FeedLoadRequested(actor: actor, filter: filter ?? _currentRequestFilter));
  }

  void _loadFeedOnly({required FeedFilter filter}) {
    final actor = _resolvedActor;
    if (actor == null) return;
    _resetFeedCacheIfActorChanged(actor);
    final cached = _cachedFeedStates[filter];
    if (cached != null && _feedMatchesExpectedActor(cached, actor, context.read<ProfileBloc>().state.profile)) {
      if (cached.status == FeedStatus.loading || cached.status == FeedStatus.loaded) {
        return;
      }
    }
    context.read<FeedBloc>().add(FeedLoadRequested(actor: actor, filter: filter));
  }

  String? get _resolvedActor {
    final authState = context.read<AuthBloc>().state;
    if (!authState.isAuthenticated) return null;
    final authDid = authState.tokens?.did;
    final rawActor = widget.actor ?? authState.tokens?.did;
    if (rawActor == null) {
      return null;
    }

    final normalizedActor = _normalizeActor(rawActor);
    if (normalizedActor.toLowerCase() == 'me') {
      return authDid;
    }
    return normalizedActor.isEmpty ? null : normalizedActor;
  }

  String _normalizeActor(String actor) {
    final trimmed = actor.trim();
    if (trimmed.startsWith('@')) {
      return trimmed.substring(1);
    }
    return trimmed;
  }

  String _canonicalActorForCompare(String actor) => _normalizeActor(actor).toLowerCase();

  bool _profileMatchesExpectedActor(ProfileViewDetailed? profile, String expectedActor) {
    if (profile == null) {
      return false;
    }

    final expected = _canonicalActorForCompare(expectedActor);
    return _canonicalActorForCompare(profile.did) == expected || _canonicalActorForCompare(profile.handle) == expected;
  }

  bool _feedMatchesExpectedActor(FeedState feedState, String expectedActor, ProfileViewDetailed? profile) {
    final stateActor = feedState.actor;
    if (stateActor == null) {
      return false;
    }

    final normalizedStateActor = _canonicalActorForCompare(stateActor);
    final normalizedExpectedActor = _canonicalActorForCompare(expectedActor);
    if (normalizedStateActor == normalizedExpectedActor) {
      return true;
    }

    if (profile != null) {
      return normalizedStateActor == _canonicalActorForCompare(profile.did) ||
          normalizedStateActor == _canonicalActorForCompare(profile.handle);
    }

    return false;
  }

  void _scheduleProfileLoadIfNeeded(String actor, ProfileState profileState) {
    if (_profileMatchesExpectedActor(profileState.profile, actor)) {
      _lastScheduledProfileActorLoad = null;
      return;
    }

    if (profileState.status == ProfileStatus.loading) {
      return;
    }

    if (_lastScheduledProfileActorLoad == actor) {
      return;
    }

    _lastScheduledProfileActorLoad = actor;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<ProfileBloc>().add(ProfileLoadRequested(actor: actor));
    });
  }

  void _scheduleFeedLoadIfNeeded(String actor, FeedFilter filter, FeedState feedState, ProfileViewDetailed? profile) {
    final cachedState = _cachedFeedStates[filter];
    if (cachedState != null && _feedMatchesExpectedActor(cachedState, actor, profile)) {
      if (cachedState.status == FeedStatus.loading || cachedState.status == FeedStatus.loaded) {
        _lastScheduledFeedLoadKey = null;
        return;
      }
    }

    if (feedState.status == FeedStatus.loading &&
        feedState.filter == filter &&
        _feedMatchesExpectedActor(feedState, actor, profile)) {
      return;
    }

    if (feedState.status == FeedStatus.loaded &&
        feedState.filter == filter &&
        _feedMatchesExpectedActor(feedState, actor, profile)) {
      _lastScheduledFeedLoadKey = null;
      return;
    }

    final requestKey = '$actor|${filter.name}';
    if (_lastScheduledFeedLoadKey == requestKey) {
      return;
    }

    _lastScheduledFeedLoadKey = requestKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<FeedBloc>().add(FeedLoadRequested(actor: actor, filter: filter));
    });
  }

  List<String> get _baseTabLabels => _showSuggestedTab ? _baseTabLabelsOther : _baseTabLabelsOwn;

  List<String> get _tabLabels =>
      _showSuggestedTab ? [..._baseTabLabels, _suggestedTabLabel] : List<String>.of(_baseTabLabels);

  _ProfileFeedTabConfig get _currentFeedTab =>
      _feedTabs[_tabController.index < _feedTabs.length ? _tabController.index : 0];

  FeedFilter get _currentRequestFilter => _currentFeedTab.requestFilter;

  _ProfileFeedSlice get _currentFeedSlice => _currentFeedTab.slice;

  void _resetFeedCacheIfActorChanged(String actor) {
    if (_cachedFeedActor == actor) {
      return;
    }
    _cachedFeedActor = actor;
    _cachedFeedStates.clear();
  }

  FeedState _cachedStateForFilter(
    FeedFilter filter, {
    required String? expectedActor,
    required ProfileViewDetailed? profile,
  }) {
    final cached = _cachedFeedStates[filter];
    if (cached == null) {
      return const FeedState.initial();
    }

    if (expectedActor == null || _feedMatchesExpectedActor(cached, expectedActor, profile)) {
      return cached;
    }
    return const FeedState.initial();
  }

  bool _shouldShowSuggestedTab(ProfileViewDetailed? profile) {
    if (profile == null) return false;
    return profile.did != context.read<AuthBloc>().state.tokens?.did;
  }

  /// Updates tab controller and visibility state to show or hide the Suggested tab based on the current profile.
  ///
  /// We dispose after rebuild so widgets still referencing the previous
  /// controller do not observe a torn-down animation during this frame.
  void _setSuggestedTabVisibility(bool show) {
    if (_showSuggestedTab == show) {
      return;
    }

    final maxIndex = show ? _baseTabLabelsOther.length : _baseTabLabelsOwn.length - 1;
    final nextIndex = _tabController.index.clamp(0, maxIndex);
    final previousController = _tabController;
    _showSuggestedTab = show;
    _tabController = TabController(length: _tabLabels.length, vsync: this, initialIndex: nextIndex);
    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      previousController.dispose();
    });
  }

  String _appBarTitle(ProfileViewDetailed? profile) {
    final authState = context.read<AuthBloc>().state;
    return profile?.displayName ?? profile?.handle ?? widget.actor ?? authState.tokens?.handle ?? 'Profile';
  }

  Future<void> _refresh() async {
    context.read<ProfileBloc>().add(const ProfileRefreshRequested());
    context.read<FeedBloc>().add(const FeedRefreshRequested());
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  bool get _isAtTop => !_profileScrollController.hasClients || _profileScrollController.position.pixels <= 0.5;

  void _onHeaderPointerDown(PointerDownEvent event) {
    _headerTrackingPointer = event.pointer;
    _headerPullDistance = 0;
  }

  Future<void> _onHeaderPointerMove(PointerMoveEvent event) async {
    if (_headerTrackingPointer != event.pointer || _headerRefreshInFlight) {
      return;
    }

    if (!_isAtTop) {
      _headerPullDistance = 0;
      return;
    }

    if (event.delta.dy <= 0) {
      return;
    }

    _headerPullDistance += event.delta.dy;
    if (_headerPullDistance < _coverRefreshTriggerDistance) {
      return;
    }

    _headerPullDistance = 0;
    _headerRefreshInFlight = true;
    await (_profileRefreshKey.currentState?.show() ?? _refresh());
    _headerRefreshInFlight = false;
  }

  void _onHeaderPointerUp(PointerUpEvent event) {
    if (_headerTrackingPointer != event.pointer) {
      return;
    }
    _headerTrackingPointer = null;
    _headerPullDistance = 0;
  }

  void _onHeaderPointerCancel(PointerCancelEvent event) {
    if (_headerTrackingPointer != event.pointer) {
      return;
    }
    _headerTrackingPointer = null;
    _headerPullDistance = 0;
  }

  Widget _buildProfileHeaderRefreshZone({required Widget child, Key? key}) {
    return Listener(
      key: key,
      onPointerDown: _onHeaderPointerDown,
      onPointerMove: _onHeaderPointerMove,
      onPointerUp: _onHeaderPointerUp,
      onPointerCancel: _onHeaderPointerCancel,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScreenEntrance(
      child: BlocListener<ProfileBloc, ProfileState>(
        listenWhen: (previous, current) {
          return _shouldShowSuggestedTab(previous.profile) != _shouldShowSuggestedTab(current.profile);
        },
        listener: (context, state) => _setSuggestedTabVisibility(_shouldShowSuggestedTab(state.profile)),
        child: Scaffold(
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              return BlocBuilder<FeedBloc, FeedState>(
                builder: (context, feedState) {
                  final expectedActor = _resolvedActor;
                  final profile = profileState.profile;
                  final profileMatchesExpectedActor = expectedActor == null
                      ? true
                      : _profileMatchesExpectedActor(profile, expectedActor);
                  final actorScopedProfile = profileMatchesExpectedActor ? profile : null;
                  if (expectedActor != null) {
                    _resetFeedCacheIfActorChanged(expectedActor);
                  }
                  if (expectedActor == null ||
                      _feedMatchesExpectedActor(feedState, expectedActor, actorScopedProfile)) {
                    _cachedFeedStates[feedState.filter] = feedState;
                  }
                  if (expectedActor != null && _isCurrentRoute) {
                    _scheduleProfileLoadIfNeeded(expectedActor, profileState);
                    if (_tabController.index < _feedTabs.length) {
                      _scheduleFeedLoadIfNeeded(expectedActor, _currentRequestFilter, feedState, actorScopedProfile);
                    }
                  }

                  final currentUserDid = context.read<AuthBloc>().state.tokens?.did;
                  final isOwnProfile = actorScopedProfile?.did == currentUserDid;
                  final feedTabChildren = _feedTabs.map((tab) {
                    final stateForTab = _cachedStateForFilter(
                      tab.requestFilter,
                      expectedActor: expectedActor,
                      profile: actorScopedProfile,
                    );
                    return KeyedSubtree(
                      key: PageStorageKey<String>('profile-feed-tab-${tab.slice.name}'),
                      child: _buildFeedList(
                        sourceState: stateForTab,
                        requestFilter: tab.requestFilter,
                        slice: tab.slice,
                        emptyLabel: tab.emptyLabel,
                        profile: actorScopedProfile,
                        expectedActor: expectedActor,
                      ),
                    );
                  });
                  final tabChildren = <Widget>[
                    ...feedTabChildren,
                    if (_showSuggestedTab)
                      KeyedSubtree(
                        key: const PageStorageKey<String>('profile-liked-tab'),
                        child: _buildLikedPostsTab(context, actorScopedProfile),
                      ),
                    KeyedSubtree(
                      key: const PageStorageKey<String>('profile-lists-tab'),
                      child: _buildListsTab(context, actorScopedProfile),
                    ),
                    KeyedSubtree(
                      key: const PageStorageKey<String>('profile-starter-packs-tab'),
                      child: _buildStarterPacksTab(context, actorScopedProfile),
                    ),
                    if (_showSuggestedTab)
                      KeyedSubtree(
                        key: const PageStorageKey<String>('profile-suggested-tab'),
                        child: _buildSuggestedFollowsTab(actorScopedProfile),
                      ),
                  ];

                  return NotificationListener<ScrollUpdateNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.axis != Axis.vertical) {
                        return false;
                      }
                      final offset = notification.metrics.pixels;
                      if ((offset - _coverScrollOffset).abs() >= 1) {
                        setState(() => _coverScrollOffset = offset);
                      }
                      return false;
                    },
                    child: RefreshIndicator(
                      key: _profileRefreshKey,
                      onRefresh: _refresh,
                      notificationPredicate: (notification) =>
                          notification.depth == 0 && notification.metrics.axis == Axis.vertical,
                      child: NestedScrollView(
                        controller: _profileScrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            SliverAppBar(
                              floating: true,
                              pinned: true,
                              snap: true,
                              title: Text(_appBarTitle(actorScopedProfile)),
                              leading: widget.showBackButton
                                  ? IconButton(
                                      icon: const Icon(Icons.arrow_back),
                                      onPressed: () => context.canPop() ? context.pop() : context.go('/profile/me'),
                                    )
                                  : const AppShellMenuButton(),
                              actions: [
                                if (actorScopedProfile != null && isOwnProfile)
                                  IconButton(
                                    key: const Key('profile_more_button'),
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () => _showOwnProfileMoreOptions(context, actorScopedProfile),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.settings_outlined),
                                  onPressed: () => context.go('/settings'),
                                ),
                              ],
                            ),
                            SliverToBoxAdapter(child: _buildCoverSection(context, actorScopedProfile)),
                            SliverToBoxAdapter(
                              child: _buildProfileHeaderRefreshZone(
                                key: const ValueKey('profile_header_details_refresh_zone'),
                                child: switch (profileState.status) {
                                  ProfileStatus.loading => const Padding(
                                    padding: AppInsets.allLg,
                                    child: Center(child: CircularProgressIndicator()),
                                  ),
                                  ProfileStatus.error => _buildProfileError(context, profileState.errorMessage),
                                  _ when !profileMatchesExpectedActor => const Padding(
                                    padding: AppInsets.allLg,
                                    child: Center(child: CircularProgressIndicator()),
                                  ),
                                  _ => _buildProfileSummary(context, actorScopedProfile, isOwnProfile),
                                },
                              ),
                            ),
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: SliverTabBarDelegate(
                                TabBar(
                                  controller: _tabController,
                                  tabs: [for (final label in _tabLabels) Tab(text: label)],
                                  onTap: (index) {
                                    if (index < _feedTabs.length) {
                                      _loadFeedOnly(filter: _feedTabs[index].requestFilter);
                                    }
                                  },
                                  isScrollable: true,
                                  tabAlignment: TabAlignment.start,
                                  labelStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.2,
                                  ),
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
                        body: TabBarView(controller: _tabController, children: tabChildren),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: AnimatedSwitcher(
            duration: Anim.feedItem,
            switchInCurve: Anim.enter,
            switchOutCurve: Anim.exit,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: _buildComposeFab(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverSection(BuildContext context, ProfileViewDetailed? profile) {
    final width = MediaQuery.of(context).size.width;
    final coverHeight = width >= 600 ? 256.0 : 192.0;
    final avatarSize = width >= 600 ? 128.0 : 96.0;
    final colorScheme = context.colorScheme;

    Widget coverContent;
    if (profile?.banner != null) {
      coverContent = ColorFiltered(
        colorFilter: AppColorFilters.greyscale,
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

    return _buildProfileHeaderRefreshZone(
      key: const ValueKey('profile_cover_refresh_zone'),
      child: SizedBox(
        height: coverHeight + avatarSize / 2,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: coverHeight,
              child: Transform.translate(
                offset: Offset(0, -1.0 * (_coverScrollOffset * 0.5).clamp(0, coverHeight * 0.3).toDouble()),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
                  ),
                  child: Opacity(opacity: 0.5, child: coverContent),
                ),
              ),
            ),
            Positioned(
              top: coverHeight - avatarSize / 2,
              left: 16,
              child: _buildSquareAvatar(context, profile, avatarSize),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareAvatar(BuildContext context, ProfileViewDetailed? profile, double size) {
    final colorScheme = context.colorScheme;
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
        initials: formatInitials(profile?.displayName ?? profile?.handle ?? '?'),
        shape: BoxShape.rectangle,
        border: Border.all(color: colorScheme.surfaceContainerLowest, width: 4),
        placeholderTextStyle: context.textTheme.headlineSmall,
      ),
    );
  }

  Widget _buildProfileError(BuildContext context, String? errorMessage) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Unable to load profile', style: context.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(errorMessage ?? 'Unknown error', style: context.textTheme.bodyMedium),
          const SizedBox(height: 12),
          FilledButton(onPressed: _loadProfileAndFeed, child: const Text('Try again')),
        ],
      ),
    );
  }

  Widget _buildProfileSummary(BuildContext context, ProfileViewDetailed? profile, bool isOwnProfile) {
    if (profile == null) return const SizedBox.shrink();

    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
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
              child: FacetText(text: profile.description!, style: textTheme.bodyMedium),
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.push('/bookmarks'),
                  icon: const Icon(Icons.bookmark_outline),
                  label: const Text('Bookmarks'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/liked'),
                  icon: const Icon(Icons.favorite_outline),
                  label: const Text('Liked'),
                ),
              ],
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
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return chip;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(999), child: chip);
  }

  Widget _buildStat(BuildContext context, int count, String label) {
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formatCount(count), style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 11, letterSpacing: 1.1, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildProfileActions(BuildContext context, ProfileViewDetailed profile) {
    final viewer = profile.viewer;
    final isOffline = context.select<ConnectivityCubit, bool>((cubit) => cubit.state.isOffline);

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
            showAppSnackBar(context, state.error!, behavior: SnackBarBehavior.floating);
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
          isOffline: isOffline,
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

  void _showOwnProfileMoreOptions(BuildContext context, ProfileViewDetailed profile) {
    showOptionsSheet<void>(
      context: context,
      items: [
        OptionsSheetItem(
          leading: const Icon(Icons.hub_outlined),
          title: 'Profile Context',
          onTap: () => context.push(
            '/profile-context?did=${Uri.encodeComponent(profile.did)}&handle=${Uri.encodeComponent(profile.handle)}',
          ),
        ),
        OptionsSheetItem(
          leading: const Icon(Icons.cleaning_services_outlined),
          title: 'Clean Follows',
          onTap: () => context.push('/settings/clean-follows'),
        ),
      ],
    );
  }

  void _showProfileMoreOptions(BuildContext context, ProfileViewDetailed profile) {
    showOptionsSheet<void>(
      context: context,
      items: [
        OptionsSheetItem(
          leading: const Icon(Icons.copy),
          title: 'Copy DID',
          onTap: () {
            Clipboard.setData(ClipboardData(text: profile.did));
            showAppSnackBar(context, 'DID copied to clipboard', behavior: SnackBarBehavior.floating);
          },
        ),
        OptionsSheetItem(
          leading: const Icon(Icons.share_outlined),
          title: 'Share Profile',
          onTap: () => ShareHelper.shareText(
            context,
            AppViewWebLinks.profile(profile.handle, appViewProvider: _resolveAppViewProvider(context)),
          ),
        ),
        OptionsSheetItem(
          leading: const Icon(Icons.playlist_add_outlined),
          title: 'Add to list',
          onTap: () => _showAddToList(context, profile),
        ),
        OptionsSheetItem(
          leading: const Icon(Icons.people_outline),
          title: 'Suggested Follows',
          onTap: () => _showSuggestedFollows(context, profile),
        ),
        OptionsSheetItem(
          leading: const Icon(Icons.hub_outlined),
          title: 'Profile Context',
          onTap: () => context.push(
            '/profile-context?did=${Uri.encodeComponent(profile.did)}&handle=${Uri.encodeComponent(profile.handle)}',
          ),
        ),
      ],
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

    showAppBottomSheet<void>(
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
                child: Text('Add to list', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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
                                  color: isMember ? context.colorScheme.primary : context.colorScheme.onSurfaceVariant,
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

  String _resolveAppViewProvider(BuildContext context) {
    try {
      return context.read<SettingsCubit>().state.appViewProvider;
    } catch (_) {
      return AppViewProviders.defaultKey;
    }
  }

  void _showSuggestedFollows(BuildContext context, ProfileViewDetailed profile) {
    ProfileRepository? profileRepository;
    try {
      profileRepository = context.read<ProfileRepository>();
    } catch (_) {
      return;
    }

    final cubit = SuggestedFollowsCubit(repository: profileRepository)..load(profile.did);

    showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: SuggestedFollowsSheet(actor: profile.did),
      ),
    ).whenComplete(cubit.close);
  }

  Widget _buildSuggestedFollowsTab(ProfileViewDetailed? profile) {
    final actor = profile?.did;
    if (actor == null) {
      return const SizedBox.shrink();
    }

    return _SuggestedFollowsTab(actor: actor, onProfileTap: (target) => navigateToProfile(context, target.did));
  }

  Widget _buildComposeFab(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        if (profile == null) return const SizedBox.shrink(key: ValueKey('profile-compose-fab-empty'));

        final currentUserDid = context.read<AuthBloc>().state.tokens?.did;
        final isOwnProfile = profile.did == currentUserDid;
        final initialText = isOwnProfile ? null : '@${profile.handle} ';
        final isOffline = context.select<ConnectivityCubit, bool>((cubit) => cubit.state.isOffline);

        return FloatingActionButton(
          key: const ValueKey('profile-compose-fab'),
          heroTag: 'profile-compose-fab',
          tooltip: isOffline ? offlineActionMessage('compose a post') : 'Compose',
          onPressed: isOffline
              ? null
              : () => context.push('/compose', extra: ComposeRouteArgs(initialText: initialText)),
          child: const Icon(Icons.add),
        ).animateIfAllowed(
          context,
          effects: const [
            FadeEffect(duration: Anim.feedItem, curve: Anim.enter),
            ScaleEffect(begin: Offset(0, 0), end: Offset(1, 1), duration: Anim.feedItem, curve: Anim.emphasis),
          ],
        );
      },
    );
  }

  Widget _buildFeedList({
    required FeedState sourceState,
    required FeedFilter requestFilter,
    required _ProfileFeedSlice slice,
    required String emptyLabel,
    required ProfileViewDetailed? profile,
    required String? expectedActor,
  }) {
    final isActiveTab = _currentFeedSlice == slice;
    final feedMatchesExpectedActor = expectedActor == null
        ? true
        : _feedMatchesExpectedActor(sourceState, expectedActor, profile);
    final visiblePosts = _filterPostsForSlice(sourceState.posts, slice);
    final visibleFeedState = sourceState.copyWith(posts: visiblePosts);

    if (expectedActor != null && isActiveTab && !feedMatchesExpectedActor) {
      return const Center(child: CircularProgressIndicator());
    }

    if (isActiveTab && sourceState.status == FeedStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sourceState.isLoading && visiblePosts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sourceState.hasError && feedMatchesExpectedActor) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(sourceState.errorMessage ?? 'Failed to load posts'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _loadFeedOnly(filter: requestFilter),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (visiblePosts.isEmpty) {
      return Center(child: Text(emptyLabel));
    }

    if (slice == _ProfileFeedSlice.replies) {
      return _buildRepliesFeed(context, visibleFeedState, requestFilter: requestFilter);
    }

    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.feedLayout != curr.feedLayout,
      builder: (context, settingsState) {
        if (settingsState.feedLayout == FeedLayout.card) {
          return _buildGridFeed(context, visibleFeedState, requestFilter: requestFilter, slice: slice);
        }
        return _buildLinearFeed(context, visibleFeedState, requestFilter: requestFilter, slice: slice);
      },
    );
  }

  Widget _buildRepliesFeed(BuildContext context, FeedState feedState, {required FeedFilter requestFilter}) {
    final accountDid = context.read<AuthBloc>().state.tokens?.did ?? '';
    return RefreshIndicator(
      onRefresh: _refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels > notification.metrics.maxScrollExtent - 300 &&
              feedState.hasMore &&
              !feedState.isLoadingMore &&
              _currentRequestFilter == requestFilter) {
            context.read<FeedBloc>().add(const FeedLoadMoreRequested());
          }
          return false;
        },
        child: ListView.builder(
          key: const PageStorageKey<String>('profile_replies_thread_list'),
          padding: EdgeInsets.zero,
          itemCount: feedState.posts.length + (feedState.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= feedState.posts.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _ProfileReplyThreadItem(feedViewPost: feedState.posts[index], accountDid: accountDid);
          },
        ),
      ),
    );
  }

  List<FeedViewPost> _filterPostsForSlice(List<FeedViewPost> posts, _ProfileFeedSlice slice) {
    switch (slice) {
      case _ProfileFeedSlice.posts:
      case _ProfileFeedSlice.media:
        return posts;
      case _ProfileFeedSlice.replies:
        return posts.where((post) => !_isRepost(post) && post.reply != null).toList(growable: false);
      case _ProfileFeedSlice.quotes:
        return posts.where((post) => !_isRepost(post) && _isQuote(post)).toList(growable: false);
      case _ProfileFeedSlice.reposts:
        return posts.where(_isRepost).toList(growable: false);
    }
  }

  bool _isRepost(FeedViewPost post) => post.reason?.isReasonRepost ?? false;

  bool _isQuote(FeedViewPost post) {
    final embed = post.post.embed;
    if (embed == null) {
      return false;
    }
    return embed.isEmbedRecordView || embed.isEmbedRecordWithMediaView;
  }

  Widget _buildGridFeed(
    BuildContext context,
    FeedState feedState, {
    required FeedFilter requestFilter,
    required _ProfileFeedSlice slice,
  }) {
    final accountDid = context.read<AuthBloc>().state.tokens?.did ?? '';
    final scrollKey = slice == _ProfileFeedSlice.posts
        ? const ValueKey('profile_grid_feed')
        : PageStorageKey<String>('profile_grid_feed_${slice.name}');

    return RefreshIndicator(
      onRefresh: _refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels > notification.metrics.maxScrollExtent - 300 &&
              feedState.hasMore &&
              !feedState.isLoadingMore &&
              _currentRequestFilter == requestFilter) {
            context.read<FeedBloc>().add(const FeedLoadMoreRequested());
          }
          return false;
        },
        child: ListView.builder(
          key: scrollKey,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: feedState.posts.length + (feedState.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= feedState.posts.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final post = feedState.posts[index];

            return Padding(
              padding: EdgeInsets.only(bottom: index == feedState.posts.length - 1 ? 0 : 16),
              child: Center(
                child: ConstrainedBox(
                  key: ValueKey('profile_large_card_$index'),
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: PostCardWithActions(
                    feedViewPost: post,
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

  Widget _buildLinearFeed(
    BuildContext context,
    FeedState feedState, {
    required FeedFilter requestFilter,
    required _ProfileFeedSlice slice,
  }) {
    final accountDid = context.read<AuthBloc>().state.tokens?.did ?? '';
    return RefreshIndicator(
      onRefresh: _refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels > notification.metrics.maxScrollExtent - 300 &&
              feedState.hasMore &&
              !feedState.isLoadingMore &&
              _currentRequestFilter == requestFilter) {
            context.read<FeedBloc>().add(const FeedLoadMoreRequested());
          }
          return false;
        },
        child: ListView.builder(
          key: PageStorageKey<String>('profile_linear_feed_${slice.name}'),
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
              accountDid: accountDid,
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

  Widget _buildLikedPostsTab(BuildContext context, ProfileViewDetailed? profile) {
    final actor = profile?.did ?? _resolvedActor;
    if (actor == null) return const SizedBox.shrink();

    ProfileRepository? profileRepository;
    try {
      profileRepository = context.read<ProfileRepository>();
    } catch (_) {
      return const SizedBox.shrink();
    }

    return _ProfileLikedPostsPane(actor: actor, profileRepository: profileRepository);
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

  Future<void> _launchWebsite(String website) async {
    final uri = Uri.tryParse(website.startsWith('http') ? website : 'https://$website');
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _ProfileReplyThreadItem extends StatelessWidget {
  const _ProfileReplyThreadItem({required this.feedViewPost, required this.accountDid});

  final FeedViewPost feedViewPost;
  final String accountDid;

  @override
  Widget build(BuildContext context) {
    final parent = feedViewPost.reply?.parent;
    final hasParentPost = parent?.isPostView == true;

    if (!hasParentPost) {
      return PostCardWithActions(
        feedViewPost: feedViewPost,
        accountDid: accountDid,
        moderationContext: bsky_moderation.ModerationBehaviorContext.contentList,
      );
    }

    final parentFeedViewPost = FeedViewPost(post: parent!.postView!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostCardWithActions(
          key: ValueKey('profile_reply_parent_${parentFeedViewPost.post.uri}'),
          feedViewPost: parentFeedViewPost,
          accountDid: accountDid,
          moderationContext: bsky_moderation.ModerationBehaviorContext.contentView,
        ),
        _buildThreadConnector(context),
        PostCardWithActions(
          key: ValueKey('profile_reply_child_${feedViewPost.post.uri}'),
          feedViewPost: feedViewPost,
          accountDid: accountDid,
          moderationContext: bsky_moderation.ModerationBehaviorContext.contentView,
        ),
      ],
    );
  }

  Widget _buildThreadConnector(BuildContext context) {
    return SizedBox(
      height: 16,
      child: Row(
        children: [
          const SizedBox(width: 37),
          Container(width: 2, color: Theme.of(context).dividerColor),
        ],
      ),
    );
  }
}

class _SuggestedFollowsTab extends StatefulWidget {
  const _SuggestedFollowsTab({required this.actor, required this.onProfileTap});

  final String actor;
  final ValueChanged<ProfileView> onProfileTap;

  @override
  State<_SuggestedFollowsTab> createState() => _SuggestedFollowsTabState();
}

class _SuggestedFollowsTabState extends State<_SuggestedFollowsTab> {
  SuggestedFollowsCubit? _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = _createCubit(widget.actor);
  }

  @override
  void didUpdateWidget(covariant _SuggestedFollowsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actor == widget.actor) {
      return;
    }

    _cubit?.close();
    _cubit = _createCubit(widget.actor);
  }

  @override
  void dispose() {
    _cubit?.close();
    super.dispose();
  }

  SuggestedFollowsCubit? _createCubit(String actor) {
    try {
      final repository = context.read<ProfileRepository>();
      return SuggestedFollowsCubit(repository: repository)..load(actor);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _cubit;
    if (cubit == null) {
      return const Center(child: Text('Suggested follows are unavailable right now.'));
    }

    return BlocProvider.value(
      value: cubit,
      child: SuggestedFollowsList(
        actor: widget.actor,
        padding: const EdgeInsets.symmetric(vertical: 8),
        onProfileTap: widget.onProfileTap,
      ),
    );
  }
}

class _ProfileLikedPostsPane extends StatefulWidget {
  const _ProfileLikedPostsPane({required this.actor, required this.profileRepository});

  final String actor;
  final ProfileRepository profileRepository;

  @override
  State<_ProfileLikedPostsPane> createState() => _ProfileLikedPostsPaneState();
}

class _ProfileLikedPostsPaneState extends State<_ProfileLikedPostsPane> {
  List<FeedViewPost> _posts = const [];
  String? _cursor;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void didUpdateWidget(covariant _ProfileLikedPostsPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actor != widget.actor) {
      _loadInitial();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _posts = const [];
      _cursor = null;
      _hasMore = true;
    });

    try {
      final page = await widget.profileRepository.getActorLikes(actor: widget.actor, limit: 50);
      if (!mounted) return;
      setState(() {
        _posts = page.posts;
        _cursor = page.cursor;
        _hasMore = page.cursor != null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load liked posts: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadInitial();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _cursor == null) {
      return;
    }
    setState(() => _isLoadingMore = true);

    try {
      final page = await widget.profileRepository.getActorLikes(actor: widget.actor, cursor: _cursor, limit: 50);
      if (!mounted) return;
      setState(() {
        _posts = [..._posts, ...page.posts];
        _cursor = page.cursor;
        _hasMore = page.cursor != null;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            FilledButton(onPressed: _loadInitial, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return const Center(child: Text('No liked posts yet'));
    }

    final accountDid = context.read<AuthBloc>().state.tokens?.did ?? '';
    return RefreshIndicator(
      onRefresh: _refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels > notification.metrics.maxScrollExtent - 300) {
            _loadMore();
          }
          return false;
        },
        child: ListView.builder(
          key: const PageStorageKey<String>('profile-liked-posts-list'),
          itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _posts.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return PostCardWithActions(
              feedViewPost: _posts[index],
              accountDid: accountDid,
              moderationContext: bsky_moderation.ModerationBehaviorContext.contentList,
            );
          },
        ),
      ),
    );
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
              onTap: () {
                final component = Uri.encodeComponent(state.starterPacks[index].uri.toString());
                final uri = '/starter-pack?uri=$component';
                context.push(uri);
              },
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
        switch (state.status) {
          case MyListsStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case MyListsStatus.error:
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
          default:
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
                  onTap: () {
                    final component = Uri.encodeComponent(lists[index].uri.toString());
                    final uri = '/list?uri=$component';
                    context.push(uri);
                  },
                ),
              ),
            );
        }
      },
    );
  }
}
