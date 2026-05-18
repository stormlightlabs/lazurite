import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/graph/defs.dart' as bsky_graph;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/app_view_web_links.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/core/theme/color_filters.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/core/theme/spacing.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/core/widgets/sliver_tab_bar_delegate.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/compose/presentation/compose_route_args.dart';
import 'package:lazurite/features/compose/presentation/widgets/compose_fab.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/feed/bloc/feed_bloc.dart';
import 'package:lazurite/features/feed/presentation/widgets/facet_text.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/features/lists/cubit/add_to_list_cubit.dart';
import 'package:lazurite/features/lists/cubit/my_lists_cubit.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:lazurite/features/lists/presentation/widgets/list_row_tile.dart';
import 'package:lazurite/features/moderation/domain/moderation_models.dart' as bsky_moderation;
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_avatar.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderation_badge_row.dart';
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/profile/cubit/profile_action_cubit.dart';
import 'package:lazurite/features/profile/cubit/profile_connections_cubit.dart';
import 'package:lazurite/features/profile/cubit/suggested_follows_cubit.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:lazurite/features/profile/presentation/widgets/profile_action_buttons.dart';
import 'package:lazurite/features/profile/presentation/widgets/profile_liked_posts_pane.dart';
import 'package:lazurite/features/profile/presentation/widgets/profile_starter_packs_pane.dart';
import 'package:lazurite/features/profile/presentation/widgets/suggested_follows_list.dart';
import 'package:lazurite/features/profile/presentation/widgets/suggested_follows_sheet.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';
import 'package:lazurite/shared/presentation/helpers/share_helper.dart';
import 'package:lazurite/shared/presentation/helpers/snackbar_helper.dart';
import 'package:lazurite/shared/presentation/widgets/app_screen_entrance.dart';
import 'package:lazurite/shared/presentation/widgets/options_sheet.dart';
import 'package:lazurite/shared/utils/format_utils.dart';
import 'package:lazurite/shared/utils/url_utils.dart';

enum _ProfileFeedSlice { posts, replies, quotes, reposts, media }

class _ProfileFeedTabConfig {
  const _ProfileFeedTabConfig({required this.requestFilter, required this.slice});

  final FeedFilter requestFilter;
  final _ProfileFeedSlice slice;
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
    _ProfileFeedTabConfig(requestFilter: FeedFilter.postsNoReplies, slice: _ProfileFeedSlice.posts),
    _ProfileFeedTabConfig(requestFilter: FeedFilter.postsWithReplies, slice: _ProfileFeedSlice.replies),
    _ProfileFeedTabConfig(requestFilter: FeedFilter.postsWithReplies, slice: _ProfileFeedSlice.quotes),
    _ProfileFeedTabConfig(requestFilter: FeedFilter.postsWithReplies, slice: _ProfileFeedSlice.reposts),
    _ProfileFeedTabConfig(requestFilter: FeedFilter.postsWithMedia, slice: _ProfileFeedSlice.media),
  ];

  static const _baseTabCountOwn = 7;
  static const _baseTabCountOther = 8;
  static const _coverRefreshTriggerDistance = 72.0;

  late TabController _tabController;
  final GlobalKey<NestedScrollViewState> _nestedScrollKey = GlobalKey<NestedScrollViewState>();
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
    _tabController = TabController(length: _tabCount, vsync: this);
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

  int get _baseTabCount => _showSuggestedTab ? _baseTabCountOther : _baseTabCountOwn;

  int get _tabCount => _baseTabCount + (_showSuggestedTab ? 1 : 0);

  List<String> _localizedTabLabels(BuildContext context) {
    final l10n = context.l10n;
    final labels = [
      l10n.labelPosts.toUpperCase(),
      l10n.labelReplies.toUpperCase(),
      l10n.labelQuotes.toUpperCase(),
      l10n.labelReposts.toUpperCase(),
      l10n.labelMedia.toUpperCase(),
      if (_showSuggestedTab) l10n.labelLiked.toUpperCase(),
      l10n.labelLists.toUpperCase(),
      l10n.labelStarterPacks.toUpperCase(),
      if (_showSuggestedTab) l10n.labelSuggested.toUpperCase(),
    ];
    return labels;
  }

  String _emptyLabelForSlice(BuildContext context, _ProfileFeedSlice slice) {
    final l10n = context.l10n;
    return switch (slice) {
      _ProfileFeedSlice.posts => l10n.messageNoPostsYet,
      _ProfileFeedSlice.replies => l10n.messageNoRepliesYet,
      _ProfileFeedSlice.quotes => l10n.messageNoQuotesYet,
      _ProfileFeedSlice.reposts => l10n.messageNoRepostsYet,
      _ProfileFeedSlice.media => l10n.messageNoMediaPostsYet,
    };
  }

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

    final maxIndex = show ? _baseTabCountOther : _baseTabCountOwn - 1;
    final nextIndex = _tabController.index.clamp(0, maxIndex);
    final previousController = _tabController;
    _showSuggestedTab = show;
    _tabController = TabController(length: _tabCount, vsync: this, initialIndex: nextIndex);
    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      previousController.dispose();
    });
  }

  String _appBarTitle(ProfileViewDetailed? profile) {
    final authState = context.read<AuthBloc>().state;
    return profile?.displayName ??
        profile?.handle ??
        widget.actor ??
        authState.tokens?.handle ??
        context.l10n.labelProfileTitle;
  }

  void _openProfilePostSearch(BuildContext context, ProfileViewDetailed profile) {
    final actor = profile.handle.trim().isNotEmpty ? profile.handle.trim() : profile.did;
    final location = '/profile/${Uri.encodeComponent(actor)}/search-posts';
    context.push(location);
  }

  Future<void> _refresh() async {
    context.read<ProfileBloc>().add(const ProfileRefreshRequested());
    context.read<FeedBloc>().add(const FeedRefreshRequested());
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  Future<void> _jumpToTop() async {
    final futures = <Future<void>>[];
    final innerController = _nestedScrollKey.currentState?.innerController;
    if (innerController != null && innerController.hasClients && innerController.offset > 0) {
      futures.add(
        innerController.animateTo(0, duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic),
      );
    }

    if (_profileScrollController.hasClients && _profileScrollController.offset > 0) {
      futures.add(
        _profileScrollController.animateTo(0, duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic),
      );
    }

    if (futures.isEmpty) {
      return;
    }

    try {
      await Future.wait(futures);
    } catch (error, stackTrace) {
      log.d('ProfileScreen: ignored jump-to-top scroll animation error', error: error, stackTrace: stackTrace);
    }
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
                        emptyLabel: _emptyLabelForSlice(context, tab.slice),
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
                        key: _nestedScrollKey,
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
                                    key: const Key('profile_edit_header_button'),
                                    icon: const Icon(Icons.edit_outlined),
                                    tooltip: context.l10n.labelEditProfile,
                                    onPressed: () => context.push('/profile/me/edit'),
                                  ),
                                if (actorScopedProfile != null && isOwnProfile)
                                  IconButton(
                                    key: const Key('profile_more_button'),
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () => _showOwnProfileMoreOptions(context, actorScopedProfile),
                                  ),
                                if (actorScopedProfile != null)
                                  IconButton(
                                    key: const Key('profile_search_posts_button'),
                                    icon: const Icon(Icons.search),
                                    tooltip: context.l10n.messageSearchThisProfilesPostsPlaceholder,
                                    onPressed: () => _openProfilePostSearch(context, actorScopedProfile),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.settings_outlined),
                                  onPressed: () => navigateToSettings(context),
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
                                  tabs: [for (final label in _localizedTabLabels(context)) Tab(text: label)],
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
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _buildProfileFabs(context),
        ),
      ),
    );
  }

  Widget _buildProfileFabs(BuildContext context) {
    final jumpToTopButton = FloatingActionButton.small(
      key: const ValueKey('profile-jump-top-fab'),
      heroTag: 'profile-jump-top-fab',
      tooltip: context.l10n.tooltipJumpToTop,
      onPressed: _jumpToTop,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      elevation: 1.5,
      child: const Icon(Icons.arrow_upward, size: 18),
    );

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        const SizedBox(width: 24),
        jumpToTopButton,
        const Spacer(),
        _buildComposeFab(context),
        const SizedBox(width: 24),
      ],
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
          Text(context.l10n.errorFailedToLoadProfile, style: context.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(errorMessage ?? context.l10n.errorUnknown, style: context.textTheme.bodyMedium),
          const SizedBox(height: 12),
          FilledButton(onPressed: _loadProfileAndFeed, child: Text(context.l10n.buttonTryAgain)),
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
    final pronouns = profile.pronouns?.trim();

    final metaChildren = <Widget>[
      if (profile.website?.isNotEmpty ?? false)
        _buildMetaChip(
          context,
          Icons.link_outlined,
          profile.website!,
          trailingIcon: Icons.open_in_new,
          onTap: () => openExternalUrl(profile.website!, addHttpsSchemeWhenMissing: true),
        ),
      if (profile.createdAt != null)
        _buildMetaChip(
          context,
          Icons.calendar_today_outlined,
          context.l10n.formatJoinedDate(DateFormat.yMMMM().format(profile.createdAt!)),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            key: const ValueKey('profile_name_pronouns_wrap'),
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 4,
            children: [
              Text(
                (profile.displayName ?? profile.handle).toUpperCase(),
                style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0),
              ),
              if (pronouns != null && pronouns.isNotEmpty)
                Text(
                  pronouns,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
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
          if (!isOwnProfile && (profile.viewer?.knownFollowers?.count ?? 0) > 0) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              key: const ValueKey('profile_known_followers_link'),
              onPressed: () => _openConnections(context, profile, ProfileConnectionsTab.knownFollowers),
              icon: const Icon(Icons.group_outlined, size: 18),
              label: Text(context.l10n.formatKnownFollowersLink(profile.viewer!.knownFollowers!.count)),
            ),
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
                _buildStat(
                  context,
                  profile.followsCount ?? 0,
                  context.l10n.labelFollowing,
                  key: const ValueKey('profile_following_stat'),
                  onTap: () => _openConnections(context, profile, ProfileConnectionsTab.following),
                ),
                const SizedBox(width: 24),
                _buildStat(
                  context,
                  profile.followersCount ?? 0,
                  context.l10n.labelFollowers,
                  key: const ValueKey('profile_followers_stat'),
                  onTap: () => _openConnections(context, profile, ProfileConnectionsTab.followers),
                ),
                const SizedBox(width: 24),
                _buildStat(context, profile.postsCount ?? 0, context.l10n.labelPosts),
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
                  label: Text(context.l10n.labelBookmarks),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/liked'),
                  icon: const Icon(Icons.favorite_outline),
                  label: Text(context.l10n.labelLiked),
                ),
              ],
            ),
          if (!isOwnProfile) _buildProfileActions(context, profile),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMetaChip(
    BuildContext context,
    IconData icon,
    String label, {
    IconData? trailingIcon,
    VoidCallback? onTap,
  }) {
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
          if (trailingIcon != null) ...[
            const SizedBox(width: 6),
            Icon(trailingIcon, size: 14, color: context.colorScheme.onSurfaceVariant),
          ],
        ],
      ),
    );

    if (onTap == null) return chip;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(999), child: chip);
  }

  Widget _buildStat(BuildContext context, int count, String label, {Key? key, VoidCallback? onTap}) {
    final colorScheme = context.colorScheme;
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formatCount(count), style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 11, letterSpacing: 1.1, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );

    if (onTap == null) {
      return KeyedSubtree(key: key, child: child);
    }
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(padding: AppInsets.allXs, child: child),
    );
  }

  void _openConnections(BuildContext context, ProfileViewDetailed profile, ProfileConnectionsTab tab) {
    final routeActor = profile.handle.trim().isNotEmpty ? profile.handle.trim() : profile.did;
    final encodedActor = Uri.encodeComponent(routeActor);
    context.push('/profile/$encodedActor/connections?tab=${tab.routeValue}');
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
          title: context.l10n.labelProfileContext,
          onTap: () => context.push(
            '/profile-context?did=${Uri.encodeComponent(profile.did)}&handle=${Uri.encodeComponent(profile.handle)}',
          ),
        ),
        OptionsSheetItem(
          leading: const Icon(Icons.cleaning_services_outlined),
          title: context.l10n.labelCleanFollows,
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
          title: context.l10n.labelCopyDid,
          onTap: () {
            Clipboard.setData(ClipboardData(text: profile.did));
            showAppSnackBar(context, context.l10n.formatDidCopied, behavior: SnackBarBehavior.floating);
          },
        ),
        OptionsSheetItem(
          leading: const Icon(Icons.share_outlined),
          title: context.l10n.labelShareProfile,
          onTap: () => ShareHelper.shareText(
            context,
            AppViewWebLinks.profile(profile.handle, appViewProvider: _resolveAppViewProvider(context)),
          ),
        ),
        OptionsSheetItem(
          leading: const Icon(Icons.playlist_add_outlined),
          title: context.l10n.labelAddToList,
          onTap: () => _showAddToList(context, profile),
        ),
        OptionsSheetItem(
          leading: const Icon(Icons.people_outline),
          title: context.l10n.labelSuggestedFollows,
          onTap: () => _showSuggestedFollows(context, profile),
        ),
        OptionsSheetItem(
          leading: const Icon(Icons.hub_outlined),
          title: context.l10n.labelProfileContext,
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
    } catch (error, stackTrace) {
      log.d('ProfileScreen: ListRepository unavailable for add-to-list sheet', error: error, stackTrace: stackTrace);
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
                child: Text(
                  context.l10n.labelAddToList,
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
                      return Center(child: Text(state.errorMessage ?? context.l10n.errorFailedToLoadLists));
                    }

                    if (state.lists.isEmpty) {
                      return Center(child: Text(context.l10n.messageNoListsYet));
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
    } catch (error, stackTrace) {
      log.d(
        'ProfileScreen: SettingsCubit unavailable; using default AppView provider',
        error: error,
        stackTrace: stackTrace,
      );
      return AppViewProviders.defaultKey;
    }
  }

  void _showSuggestedFollows(BuildContext context, ProfileViewDetailed profile) {
    ProfileRepository? profileRepository;
    try {
      profileRepository = context.read<ProfileRepository>();
    } catch (error, stackTrace) {
      log.d(
        'ProfileScreen: ProfileRepository unavailable for suggested follows sheet',
        error: error,
        stackTrace: stackTrace,
      );
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

        return ComposeFab(
          key: const ValueKey('profile-compose-fab'),
          heroTag: 'profile-compose-fab',
          tooltip: isOffline ? context.l10n.formatOfflineReconnectAction('compose a post') : context.l10n.buttonCompose,
          onPressed: isOffline
              ? null
              : () => context.push('/compose', extra: ComposeRouteArgs(initialText: initialText)),
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
      return _buildScrollableTabStatus(
        storageKey: 'profile-feed-loading-${slice.name}',
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (isActiveTab && sourceState.status == FeedStatus.initial) {
      return _buildScrollableTabStatus(
        storageKey: 'profile-feed-initial-${slice.name}',
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (sourceState.isLoading && visiblePosts.isEmpty) {
      return _buildScrollableTabStatus(
        storageKey: 'profile-feed-refreshing-${slice.name}',
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (sourceState.hasError && feedMatchesExpectedActor) {
      return _buildScrollableTabStatus(
        storageKey: 'profile-feed-error-${slice.name}',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(sourceState.errorMessage ?? context.l10n.errorFailedToLoadPosts),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _loadFeedOnly(filter: requestFilter),
              child: Text(context.l10n.buttonRetry),
            ),
          ],
        ),
      );
    }

    if (visiblePosts.isEmpty) {
      return _buildScrollableTabStatus(
        storageKey: 'profile-feed-empty-${slice.name}',
        child: Center(child: Text(emptyLabel)),
      );
    }

    if (slice == _ProfileFeedSlice.replies) {
      return _buildRepliesFeed(context, visibleFeedState, requestFilter: requestFilter);
    }

    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.feedLayout != curr.feedLayout,
      builder: (context, settingsState) {
        if (settingsState.feedLayout == FeedLayout.compact) {
          return _buildCompactFeed(context, visibleFeedState, requestFilter: requestFilter, slice: slice);
        }
        return _buildCardFeed(context, visibleFeedState, requestFilter: requestFilter, slice: slice);
      },
    );
  }

  Widget _buildScrollableTabStatus({required String storageKey, required Widget child}) {
    return CustomScrollView(
      key: PageStorageKey<String>(storageKey),
      slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
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

  Widget _buildCompactFeed(
    BuildContext context,
    FeedState feedState, {
    required FeedFilter requestFilter,
    required _ProfileFeedSlice slice,
  }) {
    final accountDid = context.read<AuthBloc>().state.tokens?.did ?? '';
    final scrollKey = slice == _ProfileFeedSlice.posts
        ? const ValueKey('profile_compact_feed')
        : PageStorageKey<String>('profile_compact_feed_${slice.name}');

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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              key: ValueKey('profile_compact_card_$index'),
              padding: EdgeInsets.only(bottom: index == feedState.posts.length - 1 ? 0 : 2),
              child: PostCardWithActions(
                feedViewPost: post,
                accountDid: accountDid,
                variant: PostCardVariant.compact,
                moderationContext: bsky_moderation.ModerationBehaviorContext.contentList,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardFeed(
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
              variant: PostCardVariant.card,
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
    } catch (error, stackTrace) {
      log.d('ProfileScreen: ListRepository unavailable for lists tab', error: error, stackTrace: stackTrace);
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
    } catch (error, stackTrace) {
      log.d('ProfileScreen: ProfileRepository unavailable for liked posts tab', error: error, stackTrace: stackTrace);
      return const SizedBox.shrink();
    }

    return ProfileLikedPostsPane(actor: actor, profileRepository: profileRepository);
  }

  Widget _buildStarterPacksTab(BuildContext context, ProfileViewDetailed? profile) {
    final actor = profile?.did ?? _resolvedActor;
    if (actor == null) return const SizedBox.shrink();

    StarterPackRepository? starterPackRepository;
    try {
      starterPackRepository = context.read<StarterPackRepository>();
    } catch (error, stackTrace) {
      log.d(
        'ProfileScreen: StarterPackRepository unavailable for starter packs tab',
        error: error,
        stackTrace: stackTrace,
      );
      return const SizedBox.shrink();
    }

    return ProfileStarterPacksPane(actor: actor, starterPackRepository: starterPackRepository);
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
    } catch (error, stackTrace) {
      log.d('ProfileScreen: ProfileRepository unavailable for suggested tab', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _cubit;
    if (cubit == null) {
      return CustomScrollView(
        key: const PageStorageKey<String>('profile-suggested-unavailable'),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text(context.l10n.messageSuggestedFollowsUnavailable)),
          ),
        ],
      );
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
            return const CustomScrollView(
              key: PageStorageKey<String>('profile-lists-loading'),
              slivers: [SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator()))],
            );
          case MyListsStatus.error:
            return CustomScrollView(
              key: const PageStorageKey<String>('profile-lists-error'),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.errorMessage ?? context.l10n.errorFailedToLoadLists),
                        const SizedBox(height: 12),
                        FilledButton(onPressed: () => _cubit.refresh(), child: Text(context.l10n.buttonRetry)),
                      ],
                    ),
                  ),
                ),
              ],
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
              return CustomScrollView(
                key: const PageStorageKey<String>('profile-lists-empty'),
                slivers: [
                  SliverFillRemaining(hasScrollBody: false, child: Center(child: Text(context.l10n.messageNoListsYet))),
                ],
              );
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
