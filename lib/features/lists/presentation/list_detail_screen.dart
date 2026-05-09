import 'package:poptart_core/poptart_core.dart' show AtUri;
import 'package:poptart_lex/app/bsky/graph/defs.dart' as bsky_graph;
import 'package:bsky_moderation/bsky_moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/core/widgets/sliver_tab_bar_delegate.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/features/lists/bloc/list_bloc.dart';
import 'package:lazurite/features/lists/bloc/list_feed_bloc.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:lazurite/features/lists/presentation/widgets/create_edit_list_dialog.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';
import 'package:lazurite/shared/presentation/widgets/confirmation_dialog.dart';
import 'package:lazurite/shared/presentation/widgets/options_sheet.dart';

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
    final confirmed = await showConfirmationDialog(
      context: context,
      title: Text(context.l10n.dialogDeleteListTitle),
      content: Text(context.l10n.dialogDeletePostContent),
      confirmLabel: context.l10n.buttonDelete,
      confirmDestructive: true,
    );

    if (confirmed && context.mounted) {
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

    showOptionsSheet<void>(
      context: context,
      items: [
        if (isOwn)
          OptionsSheetItem(
            leading: const Icon(Icons.edit_outlined),
            title: context.l10n.labelEditList,
            onTap: () => _showEditDialog(context, list),
          ),
        if (isOwn)
          OptionsSheetItem(
            leading: const Icon(Icons.person_add_outlined),
            title: context.l10n.buttonAddMembers,
            onTap: () async {
              final listUriStr = Uri.encodeComponent(list.uri.toString());
              await context.push('/list/members?uri=$listUriStr');
              if (context.mounted) {
                context.read<ListBloc>().add(const ListRefreshed());
              }
            },
          ),
        if (isOwn)
          OptionsSheetItem(
            leading: Icon(Icons.delete_outline, color: context.colorScheme.error),
            title: context.l10n.dialogDeleteListTitle,
            isDestructive: true,
            onTap: () => _confirmDelete(context),
          ),
        OptionsSheetItem(
          leading: Icon(isMuted ? Icons.volume_up_outlined : Icons.volume_off_outlined),
          title: isMuted ? context.l10n.labelUnmuteList : context.l10n.labelMuteList,
          onTap: () => context.read<ListBloc>().add(isMuted ? const ListUnmuted() : const ListMuted()),
        ),
        if (list.purpose.knownValue == bsky_graph.KnownListPurpose.appBskyGraphDefsModlist)
          OptionsSheetItem(
            leading: Icon(isBlocked ? Icons.block_flipped : Icons.block_outlined),
            title: isBlocked ? context.l10n.labelUnblockViaList : context.l10n.labelBlockViaList,
            onTap: () => context.read<ListBloc>().add(isBlocked ? const ListUnblocked() : const ListBlocked()),
          ),
      ],
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
          context.go('/profile/me');
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
                    title: Text(list?.name ?? context.l10n.labelList),
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
                        child: Center(child: Text(state.errorMessage ?? context.l10n.errorFailedToLoadList)),
                      ),
                    ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverTabBarDelegate(
                      TabBar(
                        controller: _tabController,
                        tabs: [
                          Tab(text: context.l10n.labelFeed.toUpperCase()),
                          Tab(text: context.l10n.labelMembers.toUpperCase()),
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
                  isCuration ? _buildFeedTab(context) : _buildFeedUnavailableTab(context),
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
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

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
                      context.l10n.formatListByHandle(list.creator.handle),
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.formatMemberCount(list.listItemCount ?? 0),
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
          return Center(child: Text(feedState.errorMessage ?? context.l10n.errorFailedToLoadFeed));
        }

        if (!feedState.hasPosts) {
          return Center(child: Text(context.l10n.messageNoPostsYet));
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

  Widget _buildFeedUnavailableTab(BuildContext context) {
    return Center(child: Text(context.l10n.messageFeedUnavailableForModerationLists));
  }

  Widget _buildMembersTab(BuildContext context, ListState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError && !state.hasItems) {
      return Center(child: Text(state.errorMessage ?? context.l10n.errorFailedToLoadMembers));
    }

    if (!state.hasItems) {
      return Center(child: Text(context.l10n.messageNoMembersYet));
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
              backgroundColor: context.colorScheme.surfaceContainerHighest,
              child: subject.avatar == null
                  ? Text(
                      (subject.displayName?.isNotEmpty == true ? subject.displayName! : subject.handle)
                          .substring(0, 1)
                          .toUpperCase(),
                    )
                  : null,
            ),
            title: Text(subject.displayName ?? subject.handle, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('@${subject.handle}', style: TextStyle(color: context.colorScheme.onSurfaceVariant)),
            onTap: () => navigateToProfile(context, subject.did),
            trailing: isOwn
                ? IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: context.colorScheme.error),
                    onPressed: () => context.read<ListBloc>().add(ListItemRemoved(listItemUri: item.uri)),
                  )
                : null,
          );
        },
      ),
    );
  }
}
