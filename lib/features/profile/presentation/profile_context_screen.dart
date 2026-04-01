import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/lists/presentation/widgets/list_row_tile.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_avatar.dart';
import 'package:lazurite/features/profile/cubit/profile_context_cubit.dart';

class ProfileContextScreen extends StatefulWidget {
  const ProfileContextScreen({super.key, required this.handle});

  /// The handle of the profile being viewed, shown as a subtitle in the AppBar.
  final String handle;

  @override
  State<ProfileContextScreen> createState() => _ProfileContextScreenState();
}

class _ProfileContextScreenState extends State<ProfileContextScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Track whether each tab has had its initial load triggered.
  bool _blockingLoaded = false;
  bool _listsOnLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    // Kick off the counts fetch immediately.
    context.read<ProfileContextCubit>().init();
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final cubit = context.read<ProfileContextCubit>();
    final index = _tabController.index;
    if (index == 1 && !_blockingLoaded) {
      _blockingLoaded = true;
      if (cubit.state.blockingStatus == ProfileContextTabStatus.initial) {
        cubit.loadBlocking();
      }
    } else if (index == 2 && !_listsOnLoaded) {
      _listsOnLoaded = true;
      if (cubit.state.listsOnStatus == ProfileContextTabStatus.initial) {
        cubit.loadListsOn();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileContextCubit, ProfileContextState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Profile Context'),
                Text(
                  '@${widget.handle}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Blocked By${state.blockedByCount > 0 ? ' (${state.blockedByCount})' : ''}'),
                Tab(text: 'Blocking${state.blockingCount > 0 ? ' (${state.blockingCount})' : ''}'),
                Tab(text: 'Lists${state.listsOnCount > 0 ? ' (${state.listsOnCount})' : ''}'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _BlockedByTab(state: state),
              _BlockingTab(state: state),
              _ListsOnTab(state: state),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Blocked By tab
// ---------------------------------------------------------------------------

class _BlockedByTab extends StatelessWidget {
  const _BlockedByTab({required this.state});

  final ProfileContextState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileContextCubit>();

    return RefreshIndicator(
      onRefresh: cubit.refreshBlockedBy,
      child: CustomScrollView(
        slivers: [
          // Contextualizing note at the top.
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Blocks are a normal part of social media. '
                'This data is public on the AT Protocol.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Count header + expand button.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${state.blockedByCount} account${state.blockedByCount == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  if (state.blockedByStatus == ProfileContextTabStatus.initial)
                    TextButton.icon(
                      key: const Key('blocked_by_show_accounts'),
                      onPressed: () => cubit.loadBlockedBy(),
                      icon: const Icon(Icons.expand_more),
                      label: const Text('Show accounts'),
                    ),
                ],
              ),
            ),
          ),
          // Content based on status.
          if (state.blockedByStatus == ProfileContextTabStatus.loading && state.blockedByProfiles.isEmpty)
            const SliverFillRemaining(hasScrollBody: false, child: Center(child: _ShimmerList()))
          else if (state.blockedByStatus == ProfileContextTabStatus.error && state.blockedByProfiles.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: _ErrorRetry(
                  message: state.blockedByError ?? 'Failed to load accounts',
                  onRetry: () => cubit.loadBlockedBy(),
                ),
              ),
            )
          else if (state.blockedByStatus == ProfileContextTabStatus.loaded && state.blockedByProfiles.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('No accounts have blocked this user')),
            )
          else ...[
            SliverList.builder(
              itemCount: state.blockedByProfiles.length,
              itemBuilder: (context, index) {
                final profile = state.blockedByProfiles[index];
                return _ProfileTile(
                  key: ValueKey('blocked_by_${profile.did}'),
                  profile: profile,
                  onTap: () => context.push('/profile/view?actor=${profile.did}'),
                );
              },
            ),
            if (state.blockedByStatus == ProfileContextTabStatus.loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (state.blockedByStatus == ProfileContextTabStatus.error)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _ErrorRetry(
                    message: state.blockedByError ?? 'Failed to load more',
                    onRetry: () => cubit.loadBlockedBy(cursor: state.blockedByCursor),
                  ),
                ),
              )
            else if (state.blockedByHasMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: TextButton(
                      onPressed: () => cubit.loadBlockedBy(cursor: state.blockedByCursor),
                      child: const Text('Load more'),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Blocking tab
// ---------------------------------------------------------------------------

class _BlockingTab extends StatelessWidget {
  const _BlockingTab({required this.state});

  final ProfileContextState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileContextCubit>();

    if (!state.isOwnProfile) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Blocking information is only available when viewing your own profile.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: cubit.refreshBlocking,
      child: CustomScrollView(
        slivers: [
          if (state.blockingStatus == ProfileContextTabStatus.initial ||
              (state.blockingStatus == ProfileContextTabStatus.loading && state.blockingProfiles.isEmpty))
            const SliverFillRemaining(hasScrollBody: false, child: Center(child: _ShimmerList()))
          else if (state.blockingStatus == ProfileContextTabStatus.error && state.blockingProfiles.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: _ErrorRetry(
                  message: state.blockingError ?? 'Failed to load accounts',
                  onRetry: () => cubit.loadBlocking(),
                ),
              ),
            )
          else if (state.blockingStatus == ProfileContextTabStatus.loaded && state.blockingProfiles.isEmpty)
            const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('Not blocking anyone')))
          else ...[
            SliverList.builder(
              itemCount: state.blockingProfiles.length,
              itemBuilder: (context, index) {
                final profile = state.blockingProfiles[index];
                return _ProfileTile(
                  key: ValueKey('blocking_${profile.did}'),
                  profile: profile,
                  onTap: () => context.push('/profile/view?actor=${profile.did}'),
                );
              },
            ),
            if (state.blockingStatus == ProfileContextTabStatus.loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (state.blockingStatus == ProfileContextTabStatus.error)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _ErrorRetry(
                    message: state.blockingError ?? 'Failed to load more',
                    onRetry: () => cubit.loadBlocking(cursor: state.blockingCursor),
                  ),
                ),
              )
            else if (state.blockingHasMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: TextButton(
                      onPressed: () => cubit.loadBlocking(cursor: state.blockingCursor),
                      child: const Text('Load more'),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lists On tab
// ---------------------------------------------------------------------------

class _ListsOnTab extends StatelessWidget {
  const _ListsOnTab({required this.state});

  final ProfileContextState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileContextCubit>();

    return RefreshIndicator(
      onRefresh: cubit.refreshListsOn,
      child: CustomScrollView(
        slivers: [
          if (state.listsOnStatus == ProfileContextTabStatus.initial ||
              (state.listsOnStatus == ProfileContextTabStatus.loading && state.listsOn.isEmpty))
            const SliverFillRemaining(hasScrollBody: false, child: Center(child: _ShimmerList()))
          else if (state.listsOnStatus == ProfileContextTabStatus.error && state.listsOn.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: _ErrorRetry(
                  message: state.listsOnError ?? 'Failed to load lists',
                  onRetry: () => cubit.loadListsOn(),
                ),
              ),
            )
          else if (state.listsOnStatus == ProfileContextTabStatus.loaded && state.listsOn.isEmpty)
            const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('Not on any lists')))
          else ...[
            SliverList.builder(
              itemCount: state.listsOn.length,
              itemBuilder: (context, index) {
                final list = state.listsOn[index];
                return ListRowTile(
                  key: ValueKey('list_on_${list.uri}'),
                  list: list,
                  onTap: () => context.push('/list?uri=${Uri.encodeComponent(list.uri.toString())}'),
                );
              },
            ),
            if (state.listsOnStatus == ProfileContextTabStatus.loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (state.listsOnStatus == ProfileContextTabStatus.error)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _ErrorRetry(
                    message: state.listsOnError ?? 'Failed to load more',
                    onRetry: () => cubit.loadListsOn(cursor: state.listsOnCursor),
                  ),
                ),
              )
            else if (state.listsOnHasMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: TextButton(
                      onPressed: () => cubit.loadListsOn(cursor: state.listsOnCursor),
                      child: const Text('Load more'),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable profile tile
// ---------------------------------------------------------------------------

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({super.key, required this.profile, this.onTap});

  final ProfileView profile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = profile.displayName?.isNotEmpty == true ? profile.displayName! : profile.handle;
    final initials = _initials(displayName);

    return ListTile(
      leading: ModeratedAvatar(size: 40, imageUrl: profile.avatar, initials: initials),
      title: Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('@${profile.handle}', style: TextStyle(color: colorScheme.onSurfaceVariant)),
      onTap: onTap,
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }
}

// ---------------------------------------------------------------------------
// Shimmer skeleton
// ---------------------------------------------------------------------------

class _ShimmerList extends StatefulWidget {
  const _ShimmerList();

  @override
  State<_ShimmerList> createState() => _ShimmerListState();
}

class _ShimmerListState extends State<_ShimmerList> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final opacity = 0.3 + 0.4 * _animation.value;
        return Column(
          children: List.generate(
            6,
            (_) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Opacity(
                    opacity: opacity,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, shape: BoxShape.circle),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Opacity(
                          opacity: opacity,
                          child: Container(
                            height: 14,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Opacity(
                          opacity: opacity,
                          child: Container(
                            height: 12,
                            width: 120,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Error + retry widget
// ---------------------------------------------------------------------------

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
