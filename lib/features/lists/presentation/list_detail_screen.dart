import 'package:atproto_core/atproto_core.dart' show AtUri;
import 'package:bluesky/app_bsky_graph_defs.dart' as bsky_graph;
import 'package:bluesky/moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/widgets/sliver_tab_bar_delegate.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/features/lists/bloc/list_bloc.dart';
import 'package:lazurite/features/lists/bloc/list_feed_bloc.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:lazurite/features/lists/presentation/widgets/create_edit_list_dialog.dart';

class ListDetailScreen extends StatelessWidget {
  const ListDetailScreen({super.key, required this.listUri});

  final AtUri listUri;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<ListRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ListBloc(listRepository: repository)..add(ListRequested(listUri: listUri)),
        ),
        BlocProvider(
          create: (_) => ListFeedBloc(listRepository: repository)..add(ListFeedRequested(listUri: listUri)),
        ),
      ],
      child: const _ListDetailView(),
    );
  }
}

class _ListDetailView extends StatefulWidget {
  const _ListDetailView();

  @override
  State<_ListDetailView> createState() => _ListDetailViewState();
}

class _ListDetailViewState extends State<_ListDetailView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isCurationList(bsky_graph.ListView? list) {
    return list?.purpose.knownValue == bsky_graph.KnownListPurpose.appBskyGraphDefsCuratelist;
  }

  bool _isOwnList(BuildContext context, bsky_graph.ListView? list) {
    final did = context.read<AuthBloc>().state.tokens?.did;
    return did != null && list?.creator.did == did;
  }

  Future<void> _showEditDialog(BuildContext context, bsky_graph.ListView list) async {
    final result = await showDialog<CreateEditListResult>(
      context: context,
      builder: (_) => CreateEditListDialog(
        initialName: list.name,
        initialDescription: list.description,
        initialAvatarUrl: list.avatar,
        fixedPurpose: list.purpose.toJson(),
      ),
    );

    if (result == null || !context.mounted) return;

    final userDid = context.read<AuthBloc>().state.tokens?.did;
    if (userDid == null) return;

    context.read<ListBloc>().add(
      ListUpdated(
        userDid: userDid,
        name: result.name,
        description: result.description,
        avatarBytes: result.avatarBytes,
        avatarMimeType: result.avatarMimeType,
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete list?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final userDid = context.read<AuthBloc>().state.tokens?.did;
      if (userDid != null) {
        context.read<ListBloc>().add(ListDeleted(userDid: userDid));
      }
    }
  }

  void _showMoreOptions(BuildContext context, ListState state) {
    final list = state.list;
    if (list == null) return;

    final isMuted = list.viewer?.isMuted ?? false;
    final isBlocked = list.viewer?.hasBlocked ?? false;
    final isOwn = _isOwnList(context, list);

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwn) ...[
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit list'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showEditDialog(context, list);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add_outlined),
                title: const Text('Add members'),
                onTap: () async {
                  final listUriStr = Uri.encodeComponent(list.uri.toString());
                  Navigator.pop(sheetContext);
                  await context.push('/list/members?uri=$listUriStr');
                  if (context.mounted) {
                    context.read<ListBloc>().add(const ListRefreshed());
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                title: Text('Delete list', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmDelete(context);
                },
              ),
            ],
            ListTile(
              leading: Icon(isMuted ? Icons.volume_up_outlined : Icons.volume_off_outlined),
              title: Text(isMuted ? 'Unmute list' : 'Mute list'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.read<ListBloc>().add(isMuted ? const ListUnmuted() : const ListMuted());
              },
            ),
            if (list.purpose.knownValue == bsky_graph.KnownListPurpose.appBskyGraphDefsModlist)
              ListTile(
                leading: Icon(isBlocked ? Icons.block_flipped : Icons.block_outlined),
                title: Text(isBlocked ? 'Unblock via list' : 'Block via list'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.read<ListBloc>().add(isBlocked ? const ListUnblocked() : const ListBlocked());
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListBloc, ListState>(
      listenWhen: (prev, curr) => curr.status == ListStatus.deleted,
      listener: (context, state) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/profile');
        }
      },
      child: BlocBuilder<ListBloc, ListState>(
        builder: (context, state) {
          final list = state.list;
          final isCuration = _isCurationList(list);

          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    snap: true,
                    title: Text(list?.name ?? 'List'),
                    actions: [
                      if (state.isMutating)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: state.status == ListStatus.loaded ? () => _showMoreOptions(context, state) : null,
                        ),
                    ],
                  ),
                  if (list != null)
                    SliverToBoxAdapter(child: _buildHeader(context, list))
                  else if (state.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else if (state.hasError)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(child: Text(state.errorMessage ?? 'Failed to load list')),
                      ),
                    ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverTabBarDelegate(
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'FEED'),
                          Tab(text: 'MEMBERS'),
                        ],
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
                  isCuration ? _buildFeedTab(context) : _buildFeedUnavailableTab(),
                  _buildMembersTab(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bsky_graph.ListView list) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: colorScheme.surfaceContainerHighest,
                backgroundImage: list.avatar != null ? NetworkImage(list.avatar!) : null,
                child: list.avatar == null ? Icon(Icons.list, color: colorScheme.onSurfaceVariant) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(list.name, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      'by @${list.creator.handle}',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${list.listItemCount ?? 0} members',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (list.description?.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            Text(list.description!, style: textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedTab(BuildContext context) {
    return BlocBuilder<ListFeedBloc, ListFeedState>(
      builder: (context, feedState) {
        if (feedState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (feedState.hasError) {
          return Center(child: Text(feedState.errorMessage ?? 'Failed to load feed'));
        }

        if (!feedState.hasPosts) {
          return const Center(child: Text('No posts yet'));
        }

        final accountDid = context.read<AuthBloc>().state.tokens?.did ?? '';

        return RefreshIndicator(
          onRefresh: () async => context.read<ListFeedBloc>().add(const ListFeedRefreshed()),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels > notification.metrics.maxScrollExtent - 300 &&
                  feedState.hasMore &&
                  !feedState.isLoadingMore) {
                context.read<ListFeedBloc>().add(const ListFeedLoadMoreRequested());
              }
              return false;
            },
            child: ListView.builder(
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
      },
    );
  }

  Widget _buildFeedUnavailableTab() {
    return const Center(child: Text('Feed not available for moderation lists'));
  }

  Widget _buildMembersTab(BuildContext context, ListState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError && !state.hasItems) {
      return Center(child: Text(state.errorMessage ?? 'Failed to load members'));
    }

    if (!state.hasItems) {
      return const Center(child: Text('No members yet'));
    }

    final isOwn = _isOwnList(context, state.list);

    return RefreshIndicator(
      onRefresh: () async => context.read<ListBloc>().add(const ListRefreshed()),
      child: ListView.builder(
        itemCount: state.items.length + (state.isRefreshing ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final item = state.items[index];
          final subject = item.subject;

          return ListTile(
            key: ValueKey(item.uri),
            leading: CircleAvatar(
              backgroundImage: subject.avatar != null ? NetworkImage(subject.avatar!) : null,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: subject.avatar == null
                  ? Text(
                      (subject.displayName?.isNotEmpty == true ? subject.displayName! : subject.handle)
                          .substring(0, 1)
                          .toUpperCase(),
                    )
                  : null,
            ),
            title: Text(subject.displayName ?? subject.handle, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              '@${subject.handle}',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            onTap: () => context.push('/profile/view?actor=${subject.did}'),
            trailing: isOwn
                ? IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: Theme.of(context).colorScheme.error),
                    onPressed: () => context.read<ListBloc>().add(ListItemRemoved(listItemUri: item.uri)),
                  )
                : null,
          );
        },
      ),
    );
  }
}
