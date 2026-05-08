import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart' as bsky_graph;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_avatar.dart';
import 'package:lazurite/features/profile/cubit/profile_context_cubit.dart';
import 'package:lazurite/features/profile/data/profile_context_repository.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';

class ProfileContextScreen extends StatefulWidget {
  const ProfileContextScreen({super.key, required this.handle});

  /// The handle of the profile being viewed, shown as a subtitle in the AppBar.
  final String handle;

  @override
  State<ProfileContextScreen> createState() => _ProfileContextScreenState();
}

class _ProfileContextScreenState extends State<ProfileContextScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  bool _blockingLoaded = false;
  bool _listsOnLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
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
                Text(context.l10n.labelProfileContext),
                Text(
                  '@${widget.handle}',
                  style: context.textTheme.labelSmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: _tabLabel(context.l10n.labelBlockedBy, state.blockedByCount)),
                Tab(text: _tabLabel(context.l10n.labelBlocking, state.blockingCount)),
                Tab(text: _tabLabel(context.l10n.labelLists, state.listsOnCount)),
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

class _BlockedByTab extends StatelessWidget {
  const _BlockedByTab({required this.state});

  final ProfileContextState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileContextCubit>();

    return RefreshIndicator(
      onRefresh: cubit.refreshBlockedBy,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) => _maybeLoadMore(
          notification: notification,
          status: state.blockedByStatus,
          hasMore: state.blockedByHasMore,
          cursor: state.blockedByCursor,
          onLoadMore: (cursor) => cubit.loadBlockedBy(cursor: cursor),
        ),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(context.l10n.messageBlockedByContextNotice, textAlign: TextAlign.center),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      context.l10n.formatAccountCount(state.blockedByCount),
                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    if (state.blockedByStatus == ProfileContextTabStatus.initial)
                      TextButton.icon(
                        key: const Key('blocked_by_show_accounts'),
                        onPressed: () => cubit.loadBlockedBy(),
                        icon: const Icon(Icons.expand_more),
                        label: Text(context.l10n.buttonShowAccounts),
                      ),
                  ],
                ),
              ),
            ),
            if (state.blockedByStatus == ProfileContextTabStatus.loading && state.blockedByEntries.isEmpty)
              const SliverFillRemaining(hasScrollBody: false, child: Center(child: _ShimmerList()))
            else if (state.blockedByStatus == ProfileContextTabStatus.error && state.blockedByEntries.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: _ErrorRetry(
                    message: state.blockedByError ?? context.l10n.errorFailedToLoadAccounts,
                    onRetry: () => cubit.loadBlockedBy(),
                  ),
                ),
              )
            else if (state.blockedByStatus == ProfileContextTabStatus.loaded && state.blockedByEntries.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    state.blockedByCount > 0
                        ? context.l10n.formatBlockedByAccountsUnavailable(state.blockedByCount)
                        : context.l10n.messageNoAccountsBlockedThisUser,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else ...[
              SliverList.builder(
                itemCount: state.blockedByEntries.length,
                itemBuilder: (context, index) {
                  final entry = state.blockedByEntries[index];
                  if (entry.profile != null) {
                    final profile = entry.profile!;
                    return _ProfileTile(
                      key: ValueKey('blocked_by_${profile.did}'),
                      profile: profile,
                      onTap: () => navigateToProfile(context, _profileActor(profile)),
                    );
                  }

                  return _UnavailableProfileTile(
                    key: ValueKey('blocked_by_unavailable_${entry.did}'),
                    did: entry.did,
                    reason: entry.unavailableReason ?? context.l10n.messageProfileUnavailable,
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
                      message: state.blockedByError ?? context.l10n.errorFailedToLoadMore,
                      onRetry: () => cubit.loadBlockedBy(cursor: state.blockedByCursor),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BlockingTab extends StatelessWidget {
  const _BlockingTab({required this.state});

  final ProfileContextState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileContextCubit>();

    if (!state.isOwnProfile) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(context.l10n.messageBlockingOnlyOwnProfile, textAlign: TextAlign.center),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: cubit.refreshBlocking,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) => _maybeLoadMore(
          notification: notification,
          status: state.blockingStatus,
          hasMore: state.blockingHasMore,
          cursor: state.blockingCursor,
          onLoadMore: (cursor) => cubit.loadBlocking(cursor: cursor),
        ),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  context.l10n.formatAccountCount(state.blockingCount),
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            if (state.blockingUnavailable.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: _UnavailableAccountsCard(entries: state.blockingUnavailable),
                ),
              ),
            if (state.blockingStatus == ProfileContextTabStatus.initial ||
                (state.blockingStatus == ProfileContextTabStatus.loading && state.blockingProfiles.isEmpty))
              const SliverFillRemaining(hasScrollBody: false, child: Center(child: _ShimmerList()))
            else if (state.blockingStatus == ProfileContextTabStatus.error && state.blockingProfiles.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: _ErrorRetry(
                    message: state.blockingError ?? context.l10n.errorFailedToLoadAccounts,
                    onRetry: () => cubit.loadBlocking(),
                  ),
                ),
              )
            else if (state.blockingStatus == ProfileContextTabStatus.loaded && state.blockingProfiles.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    state.blockingUnavailable.isNotEmpty
                        ? context.l10n.messageSomeBlockedAccountsUnavailable
                        : context.l10n.messageNotBlockingAnyone,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else ...[
              SliverList.builder(
                itemCount: state.blockingProfiles.length,
                itemBuilder: (context, index) {
                  final profile = state.blockingProfiles[index];
                  return _ProfileTile(
                    key: ValueKey('blocking_${profile.did}'),
                    profile: profile,
                    onTap: () => navigateToProfile(context, _profileActor(profile)),
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
                      message: state.blockingError ?? context.l10n.errorFailedToLoadMore,
                      onRetry: () => cubit.loadBlocking(cursor: state.blockingCursor),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ListsOnTab extends StatelessWidget {
  const _ListsOnTab({required this.state});

  final ProfileContextState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileContextCubit>();

    return RefreshIndicator(
      onRefresh: cubit.refreshListsOn,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) => _maybeLoadMore(
          notification: notification,
          status: state.listsOnStatus,
          hasMore: state.listsOnHasMore,
          cursor: state.listsOnCursor,
          onLoadMore: (cursor) => cubit.loadListsOn(cursor: cursor),
        ),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (state.listsOnStatus == ProfileContextTabStatus.initial ||
                (state.listsOnStatus == ProfileContextTabStatus.loading && state.listsOn.isEmpty))
              const SliverFillRemaining(hasScrollBody: false, child: Center(child: _ShimmerList()))
            else if (state.listsOnStatus == ProfileContextTabStatus.error && state.listsOn.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: _ErrorRetry(
                    message: state.listsOnError ?? context.l10n.errorFailedToLoadLists,
                    onRetry: () => cubit.loadListsOn(),
                  ),
                ),
              )
            else if (state.listsOnStatus == ProfileContextTabStatus.loaded && state.listsOn.isEmpty)
              SliverFillRemaining(hasScrollBody: false, child: Center(child: Text(context.l10n.messageNotOnAnyLists)))
            else ...[
              ..._buildListSections(
                context,
                state.listsOn,
                (list) => context.push('/list?uri=${Uri.encodeComponent(list.uri.toString())}'),
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
                      message: state.listsOnError ?? context.l10n.errorFailedToLoadMore,
                      onRetry: () => cubit.loadListsOn(cursor: state.listsOnCursor),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({super.key, required this.profile, this.onTap});

  final ProfileView profile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
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

class _UnavailableAccountsCard extends StatelessWidget {
  const _UnavailableAccountsCard({required this.entries});

  final List<UnavailableProfileRef> entries;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.warning_amber_rounded),
              title: Text(context.l10n.formatUnavailableAccounts(entries.length)),
              subtitle: Text(context.l10n.messageUnavailableAccountsDescription),
            ),
            for (final entry in entries)
              ListTile(
                dense: true,
                leading: Icon(Icons.person_off_outlined, color: colorScheme.onSurfaceVariant),
                title: Text(entry.did, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(entry.reason),
              ),
          ],
        ),
      ),
    );
  }
}

class _UnavailableProfileTile extends StatelessWidget {
  const _UnavailableProfileTile({super.key, required this.did, required this.reason});

  final String did;
  final String reason;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return ListTile(
      leading: Icon(Icons.person_off_outlined, color: colorScheme.onSurfaceVariant),
      title: Text(did, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(reason),
      enabled: false,
    );
  }
}

String _profileActor(ProfileView profile) {
  final handle = profile.handle.trim();
  return handle.isNotEmpty ? handle : profile.did;
}

bool _maybeLoadMore({
  required ScrollNotification notification,
  required ProfileContextTabStatus status,
  required bool hasMore,
  required String? cursor,
  required ValueChanged<String?> onLoadMore,
}) {
  if (notification.metrics.extentAfter > 300 ||
      status == ProfileContextTabStatus.loading ||
      !hasMore ||
      cursor == null) {
    return false;
  }

  onLoadMore(cursor);
  return false;
}

List<Widget> _buildListSections(
  BuildContext context,
  List<bsky_graph.ListView> lists,
  ValueChanged<bsky_graph.ListView> onTap,
) {
  final sections = _groupListsByPurpose(context, lists);
  return [
    for (final section in sections) ...[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(section.title, style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        ),
      ),
      SliverList.builder(
        itemCount: section.lists.length,
        itemBuilder: (context, index) {
          final list = section.lists[index];
          return _ListContextCard(key: ValueKey('list_on_${list.uri}'), list: list, onTap: () => onTap(list));
        },
      ),
    ],
  ];
}

List<({String title, List<bsky_graph.ListView> lists})> _groupListsByPurpose(
  BuildContext context,
  List<bsky_graph.ListView> lists,
) {
  final buckets = <_ListPurposeGroup, List<bsky_graph.ListView>>{
    _ListPurposeGroup.curation: [],
    _ListPurposeGroup.moderation: [],
    _ListPurposeGroup.reference: [],
    _ListPurposeGroup.other: [],
  };

  for (final list in lists) {
    buckets[_purposeGroupFor(list)]!.add(list);
  }

  return [
    (title: context.l10n.labelCurationLists, lists: buckets[_ListPurposeGroup.curation]!),
    (title: context.l10n.labelModerationLists, lists: buckets[_ListPurposeGroup.moderation]!),
    (title: context.l10n.labelReferenceLists, lists: buckets[_ListPurposeGroup.reference]!),
    (title: context.l10n.labelOtherLists, lists: buckets[_ListPurposeGroup.other]!),
  ].where((section) => section.lists.isNotEmpty).toList();
}

_ListPurposeGroup _purposeGroupFor(bsky_graph.ListView list) {
  switch (list.purpose.knownValue) {
    case bsky_graph.KnownListPurpose.appBskyGraphDefsCuratelist:
      return _ListPurposeGroup.curation;
    case bsky_graph.KnownListPurpose.appBskyGraphDefsModlist:
      return _ListPurposeGroup.moderation;
    case bsky_graph.KnownListPurpose.appBskyGraphDefsReferencelist:
      return _ListPurposeGroup.reference;
    case null:
      return _ListPurposeGroup.other;
  }
}

enum _ListPurposeGroup { curation, moderation, reference, other }

String _tabLabel(String label, int count) => count > 0 ? '$label ($count)' : label;

class _ListContextCard extends StatelessWidget {
  const _ListContextCard({super.key, required this.list, this.onTap});

  final bsky_graph.ListView list;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final description = list.description?.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: list.avatar != null ? NetworkImage(list.avatar!) : null,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      child: list.avatar == null ? Icon(Icons.list, color: colorScheme.onSurfaceVariant) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(list.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(
                            '@${list.creator.handle}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _ListPurposeBadge(purpose: list.purpose.knownValue),
                  ],
                ),
                const SizedBox(height: 12),
                _ListMetaChip(
                  icon: Icons.group_outlined,
                  label: context.l10n.formatMemberCount(list.listItemCount ?? 0),
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ListPurposeBadge extends StatelessWidget {
  const _ListPurposeBadge({required this.purpose});

  final bsky_graph.KnownListPurpose? purpose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final (label, color) = switch (purpose) {
      bsky_graph.KnownListPurpose.appBskyGraphDefsCuratelist => (context.l10n.labelCurateShort, colorScheme.primary),
      bsky_graph.KnownListPurpose.appBskyGraphDefsModlist => (context.l10n.labelModerationShort, colorScheme.error),
      bsky_graph.KnownListPurpose.appBskyGraphDefsReferencelist => (
        context.l10n.labelReferenceShort,
        colorScheme.tertiary,
      ),
      null => (context.l10n.labelList.toUpperCase(), colorScheme.secondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: color, letterSpacing: 0.6),
      ),
    );
  }
}

class _ListMetaChip extends StatelessWidget {
  const _ListMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(999)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(label, style: context.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

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
    final colorScheme = context.colorScheme;
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
        FilledButton(onPressed: onRetry, child: Text(context.l10n.buttonRetry)),
      ],
    );
  }
}
